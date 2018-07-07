//
//  WFImagePickerController.swift
//  WFImagePicker
//
//  Created by happi on 2018/6/29.
//  Copyright © 2018年 feitan. All rights reserved.
//

import UIKit
import Photos

//相簿列表项
public struct WFImageAlbumItem {
    //相簿名称
    var title:String?
    ////相簿内的资源
    var fetchResult:PHFetchResult<PHAsset>
}

public protocol WFImagePickerControllerDelegate:NSObjectProtocol {
    ///完成
    func wFImagePickerController(_ controller: WFImagePickerController, didImagePickerDone assets: [WFAsset])
    //拍照完成
    func wFImagePickerController(_ controller: WFImagePickerController, didCameraDone image: UIImage)
    
}

public class WFImagePickerController: UIViewController {
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
    }
    
    public init(_ configuration:WFImagePickerConfiguration) {
        super.init(nibName: nil, bundle: nil)
        self.configuration = configuration
        
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override public func loadView() {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        self.view = view;
        drawWithView()
    }
    //相簿列表项集合
    public var items:[WFImageAlbumItem] = []
    
    public weak var delegate: WFImagePickerControllerDelegate?
    //当前显示的相簿
    public var item:WFImageAlbumModel?
    //带缓存的图片管理对象
    public var imageManager:PHCachingImageManager!
    
    /// 配置
    public var configuration:WFImagePickerConfiguration = WFImagePickerConfiguration();
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //申请权限
        PHPhotoLibrary.requestAuthorization({ (status) in
            if status != .authorized {
                return
            }
            
            // 列出所有系统的智能相册
            let smartOptions = PHFetchOptions()
            let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                                      subtype: .albumRegular,
                                                                      options: smartOptions)
            self.convertCollection(collection: smartAlbums)
            
            //列出所有用户创建的相册
            let userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
            self.convertCollection(collection: userCollections
                as! PHFetchResult<PHAssetCollection>)
            
            //相册按包含的照片数量排序（降序）
            self.items.sort { (item1, item2) -> Bool in
                return item1.fetchResult.count > item2.fetchResult.count
            }
            
            // 转换资源数据
            self.convertOfMyItems()
            
            
            
            //异步加载表格数据,需要在主线程中调用reloadData() 方法
            DispatchQueue.main.async{

                //初始化和重置缓存
                 self.imageManager = PHCachingImageManager()
                 self.resetCachedAssets()
                
                self.item = WFUserContext.shared.items.first
                self.collectionView.reloadData()
            }
        })
        
        
        
        // 监听更新用户数据通知
        NotificationCenter.default.addObserver(self, selector: #selector(WFImagePickerController.imagePickerCancel(_:)), name: NSNotification.Name(rawValue: WF_NotificationCancel), object: nil)
        // 监听更新用户数据通知
        NotificationCenter.default.addObserver(self, selector: #selector(WFImagePickerController.imagePickerDone(_:)), name: NSNotification.Name(rawValue: WF_NotificationDone), object: nil)
        
    }
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let button:UIButton = toolBar.doneBtn.customView as! UIButton
        if WFUserContext.shared.selectAlbum.count > 0 {
            button.setTitle("\(configuration.doneTitle)(\(WFUserContext.shared.selectAlbum.count))", for: .normal)
        } else {
            button.setTitle(configuration.doneTitle, for: .normal)
        }
        self.collectionView.reloadData()
        self.scrollViewDidScroll(collectionView)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: WF_NotificationCancel), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: WF_NotificationDone), object: nil)
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //重置缓存
    func resetCachedAssets(){
        self.imageManager.stopCachingImagesForAllAssets()
    }
    //转化处理获取到的相簿
    private func convertCollection(collection:PHFetchResult<PHAssetCollection>){
        for i in 0..<collection.count{
            //获取出但前相簿内的图片
            let resultsOptions = PHFetchOptions()
            resultsOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",
                                                               ascending: false)]
            resultsOptions.predicate = NSPredicate(format: "mediaType = %d",
                                                   PHAssetMediaType.image.rawValue)
            let c = collection[i]
            let assetsFetchResult:PHFetchResult<PHAsset> = PHAsset.fetchAssets(in: c , options: resultsOptions)
            //没有图片的空相簿不显示
            if assetsFetchResult.count > 0 {
                let title = titleOfAlbumForChinse(title: c.localizedTitle)
                items.append(WFImageAlbumItem(title: title,
                                              fetchResult: assetsFetchResult))
            }
        }
    }
    
    //由于系统返回的相册集名称为英文，我们需要转换为中文
    private func titleOfAlbumForChinse(title:String?) -> String? {
        if title == "Slo-mo" {
            return "慢动作"
        } else if title == "Recently Added" {
            return "最近添加"
        } else if title == "Favorites" {
            return "个人收藏"
        } else if title == "Recently Deleted" {
            return "最近删除"
        } else if title == "Videos" {
            return "视频"
        } else if title == "All Photos" {
            return "所有照片"
        } else if title == "Selfies" {
            return "自拍"
        } else if title == "Screenshots" {
            return "屏幕快照"
        } else if title == "Camera Roll" {
            return "相机胶卷"
        }
        return title
    }
    
    // 转换资源数据
    private func convertOfMyItems() {
        for item in items {
            let model:WFImageAlbumModel = WFImageAlbumModel()
            model.title = item.title
            
            var list:[WFAsset] = []
            for i in 0..<item.fetchResult.count{
                let wfa = WFAsset()
                wfa.asset = item.fetchResult[i]
                wfa.count = 0
                list.append(wfa)
            }
            model.fetchResult = list
            WFUserContext.shared.items.append(model)
        }
        
    }
    
    
    
    
    
    fileprivate func drawWithView() {
        
        let contentView = UIView()
        contentView.backgroundColor = UIColor.white
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:[contentView(==\(configuration.pickerHeight + WF_SafeAreaBottomHeight))]|", options: [], metrics: nil, views: ["contentView": contentView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentView]|", options: [], metrics: nil, views: ["contentView": contentView]))
        
        contentView.addSubview(toolBar)
        //左边约束
        let left:NSLayoutConstraint = NSLayoutConstraint(item: toolBar, attribute: NSLayoutAttribute.left, relatedBy:NSLayoutRelation.equal, toItem:contentView, attribute:NSLayoutAttribute.left, multiplier:1.0, constant: 0)
        toolBar.superview!.addConstraint(left)
        //右边约束
        let right:NSLayoutConstraint = NSLayoutConstraint(item: toolBar, attribute: NSLayoutAttribute.right, relatedBy:NSLayoutRelation.equal, toItem:contentView, attribute:NSLayoutAttribute.right, multiplier:1.0, constant: 0)
        toolBar.superview!.addConstraint(right)
        //下边约束
        let bottom:NSLayoutConstraint = NSLayoutConstraint(item: toolBar, attribute: NSLayoutAttribute.bottom, relatedBy:NSLayoutRelation.equal, toItem:contentView, attribute:NSLayoutAttribute.bottom, multiplier:1.0, constant: -WF_SafeAreaBottomHeight)
        toolBar.superview!.addConstraint(bottom)
        //高度
        let height:NSLayoutConstraint = NSLayoutConstraint(item: toolBar, attribute: NSLayoutAttribute.height, relatedBy:NSLayoutRelation.equal, toItem:nil, attribute:.notAnAttribute, multiplier:1.0, constant: WF_TOOLBAR_HEIGHT)
        toolBar.addConstraint(height)
        
        contentView.addSubview(collectionView)
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(5)-[collectionView][toolBar]", options: [], metrics: nil, views: ["collectionView": collectionView,"toolBar":toolBar]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[collectionView]|", options: [], metrics: nil, views: ["collectionView": collectionView]))
        
    }

    
    
    //下方工具栏
    //懒加载
    // MARK: - Properties
    fileprivate lazy var toolBar:WFToolbar = {
        let toolBar = WFToolbar(configuration)
        toolBar.wf_delegate = self
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        return toolBar
    }()
    
    /// 内容载体
    let contentIdentifier = "contentIdentifier"
    fileprivate lazy var collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = configuration.itemSpacing
        layout.minimumLineSpacing = configuration.itemSpacing
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white
        collectionView.autoresizingMask = .flexibleWidth
        //collectionView.allowsMultipleSelection = true//允许多选
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(WFImagePickerCollectionViewCell.self, forCellWithReuseIdentifier: self.contentIdentifier)
        return collectionView
    }()
    
}

///MARK: - UICollectionViewDelegate,UICollectionViewDataSource
extension WFImagePickerController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    //每个分区含有的 item 个数
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.item?.fetchResult?.count ?? 0;
    }
    
    //返回 cell
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contentIdentifier, for: indexPath) as! WFImagePickerCollectionViewCell;
        
        let asset = self.item?.fetchResult?[indexPath.row]
        asset?.offset = collectionView.contentOffset
        
        cell.asset = asset
        cell.delegate = self
        
        if let asset = asset?.asset {
            //更具原图比例计算缩略图大小
            let contentHeight = (configuration.pickerHeight - WF_TOOLBAR_HEIGHT - 5)
            let thumbnailSize = CGSize(width: CGFloat(asset.pixelWidth) * (contentHeight) / CGFloat(asset.pixelHeight), height: contentHeight)
            //获取缩略图
            self.imageManager.requestImage(for: asset, targetSize: thumbnailSize,
                                           contentMode: .aspectFill, options: nil) {
                                            (image, nfo) in
                                            cell.imageView.image = image
            }
        }
        return cell;
    }
    
    //每个cell 尺寸
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let asset = self.item?.fetchResult?[indexPath.row].asset {
            //更具原图比例计算缩略图大小
            let contentHeight = (configuration.pickerHeight - WF_TOOLBAR_HEIGHT - 5)
            let thumbnailSize = CGSize(width: CGFloat(asset.pixelWidth) * contentHeight / CGFloat(asset.pixelHeight), height: contentHeight)
            return thumbnailSize
        }
        return CGSize(width: 0, height: 0)
    }
   
    //item 对应的点击事件
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let assets = self.item?.fetchResult {
            let vc = WFPhotoBrowserViewController(configuration, selectIndex: indexPath.row, assets: assets)
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let cells = collectionView.visibleCells
        for cell in cells {
            let cell1 = cell as! WFImagePickerCollectionViewCell
            if let asset = self.item?.fetchResult?[(collectionView.indexPath(for: cell)?.item)!] {
                asset.offset = scrollView.contentOffset
                cell1.asset = asset
            }
        }
    }
    
    
}



extension WFImagePickerController : WFImagePickerCollectionViewCellDelegate {
    
    func wFImagePickerCollectionViewCell(_ view: WFImagePickerCollectionViewCell, didSelectAsset asset: WFAsset?) {
        guard let asset = asset else {
            return
        }
        
        if WFUserContext.shared.selectAlbum.contains(asset) {
            asset.count = 0
            WFUserContext.shared.selectAlbum.remove(at: WFUserContext.shared.selectAlbum.index(of: asset)!)
        } else {
            WFUserContext.shared.selectAlbum.append(asset)
        }
        
        for i in 0 ..< WFUserContext.shared.selectAlbum.count{
            let model = WFUserContext.shared.selectAlbum[i]
            model.count = i + 1
        }
        
        let button:UIButton = toolBar.doneBtn.customView as! UIButton
        if WFUserContext.shared.selectAlbum.count > 0 {
            button.setTitle("\(configuration.doneTitle)(\(WFUserContext.shared.selectAlbum.count))", for: .normal)
        } else {
            button.setTitle(configuration.doneTitle, for: .normal)
        }
        collectionView.reloadData()
        self.scrollViewDidScroll(collectionView)
    }
}

extension WFImagePickerController : WFToolbarDelegate {
    func wFToolbar(_ toolbar: WFToolbar, didClickPhotoAlbumButton sender: UIButton) {
        let vc  = WFPhotoListController(configuration)
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
    }
    
    func wFToolbar(_ toolbar: WFToolbar, didClickCameraAlbumButton sender: UIButton) {
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            print("摄像头不可用")
            return
        }
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .camera
        DispatchQueue.main.async {
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    func wFToolbar(_ toolbar: WFToolbar, didClickSendAlbumButton sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: WF_NotificationDone), object: nil)
    }
}


extension WFImagePickerController {
    // MARK: - Notification
    /**
     选择取消
     */
    @objc func imagePickerCancel(_ notification: Notification) {
        WFUserContext.shared.items.removeAll()
        WFUserContext.shared.selectAlbum.removeAll()
        self.presentingViewController?.dismiss(animated: true)
    }
    /**
     选择完成
     */
    @objc func imagePickerDone(_ notification: Notification) {
        self.presentingViewController?.dismiss(animated: true)
        if delegate != nil {
            delegate?.wFImagePickerController(self, didImagePickerDone: WFUserContext.shared.selectAlbum)
        }
        WFUserContext.shared.items.removeAll()
        WFUserContext.shared.selectAlbum.removeAll()
       
    }
}

extension WFImagePickerController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //当用户选择一个图片以后，有可能调用两种不同的函数，根据版本的不同。所以，如果要同时支持高版本和低版本的兼容性，那么就要处理两种函数。
    
    //3.x  用户选中图片后的回调
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: false, completion: nil)
        
        let image:UIImage? = info[UIImagePickerControllerOriginalImage] as? UIImage //原图
        //let image:UIImage? = info[UIImagePickerControllerEditedImage] as? UIImage //裁剪后的
        if image != nil {
            if delegate != nil {
                delegate?.wFImagePickerController(self, didCameraDone: image!)
            }
            WFUserContext.shared.items.removeAll()
            WFUserContext.shared.selectAlbum.removeAll()
            self.presentingViewController?.dismiss(animated: true)
        }
        
    }
    
    //2.x  用户选中图片之后的回调
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        picker.dismiss(animated: false, completion: nil)
        
        if delegate != nil {
            delegate?.wFImagePickerController(self, didCameraDone: image)
        }
        WFUserContext.shared.items.removeAll()
        WFUserContext.shared.selectAlbum.removeAll()
        self.presentingViewController?.dismiss(animated: true)
        
    }
    
    // 用户选择取消
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


extension WFImagePickerController : UIViewControllerTransitioningDelegate {
    /**
     presentedViewController     将要跳转到的目标控制器
     presentingViewController    跳转前的原控制器
     */
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return WFPresentationController(presentedViewController: presented, presenting: presenting,configuration: configuration)
    }
}
