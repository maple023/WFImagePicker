//
//  WFPhotoCollectionViewController.swift
//  WFImagePicker
//
//  Created by happi on 2018/7/2.
//  Copyright © 2018年 feitan. All rights reserved.
//

import UIKit
import Photos

class WFPhotoCollectionViewController: UIViewController {
    init(_ configuration:WFImagePickerConfiguration) {
        super.init(nibName: nil, bundle: nil)
        self.configuration = configuration
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let view = UIView()
        view.backgroundColor = UIColor.white
        self.view = view;
        drawWithView()
    }
    
    /// 配置
    var configuration:WFImagePickerConfiguration!;
    
    //相簿
    var item:WFImageAlbumModel?
    
    //缩略图大小
    var assetGridThumbnailSize:CGSize!
    //带缓存的图片管理对象
    var imageManager:PHCachingImageManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //初始化和重置缓存
        self.imageManager = PHCachingImageManager()
        self.resetCachedAssets()
        
        if let item = item {
            title = item.title
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //根据单元格的尺寸计算我们需要的缩略图大小
        let cellSize = (self.collectionView.collectionViewLayout as!
            UICollectionViewFlowLayout).itemSize
        assetGridThumbnailSize = CGSize(width: cellSize.width*WF_SCALE_SCREEN ,
                                        height: cellSize.height*WF_SCALE_SCREEN)
        
        let button:UIButton = sendBtn.customView as! UIButton
        if WFUserContext.shared.selectAlbum.count > 0 {
            button.setTitle("\(configuration.doneTitle)(\(WFUserContext.shared.selectAlbum.count))", for: .normal)
        } else {
            button.setTitle(configuration.doneTitle, for: .normal)
        }
        
        self.collectionView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    fileprivate func drawWithView() {
        //添加导航栏右侧的取消按钮
        let rightBarItem = UIBarButtonItem(title: "取消", style: .plain, target: self,
                                           action:#selector(cancel) )
        self.navigationItem.rightBarButtonItem = rightBarItem
        
        view.addSubview(toolBar)
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:[toolBar(==\(WF_TOOLBAR_HEIGHT))]-(\(WF_SafeAreaBottomHeight))-|", options: [], metrics: nil, views: ["toolBar":toolBar]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[toolBar]|", options: [], metrics: nil, views: ["toolBar": toolBar]))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([space,sendBtn], animated: true)
        
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[collectionView][toolBar]", options: [], metrics: nil, views: ["collectionView": collectionView,"toolBar":toolBar]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[collectionView]|", options: [], metrics: nil, views: ["collectionView": collectionView]))
    }

    
    //重置缓存
    func resetCachedAssets(){
        self.imageManager.stopCachingImagesForAllAssets()
    }
    
    
    //下方工具栏
    //懒加载
    fileprivate lazy var toolBar:UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        return toolBar
    }()
    fileprivate lazy var sendBtn:UIBarButtonItem = {
        let button = UIButton(type: .custom)
        //button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(configuration.doneTitle, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setTitleColor(configuration.doneTitleColor, for: .normal)
        button.backgroundColor = configuration.doneBackgroundColor
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 2
        button.frame.size = CGSize(width: 50, height: 25)
        button.addTarget(self, action: #selector(didClickSendAlbumButton(_:)), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }()
    
    /// 内容载体
    let photoIdentifier = "photoIdentifier"
    fileprivate lazy var collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (WF_SCREEN_WIDTH - 3 * configuration.itemSpacing) / 4,
                                 height: (WF_SCREEN_WIDTH - 3 * configuration.itemSpacing) / 4)
        layout.minimumInteritemSpacing = configuration.itemSpacing
        layout.minimumLineSpacing = configuration.itemSpacing
        
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white
        collectionView.autoresizingMask = .flexibleWidth
        collectionView.allowsMultipleSelection = true//允许多选
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(WFImagePickerCollectionViewCell.self, forCellWithReuseIdentifier: self.photoIdentifier)
        return collectionView
    }()
    
}

///MARK: - UICollectionViewDelegate,UICollectionViewDataSource
extension WFPhotoCollectionViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    //每个分区含有的 item 个数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.item?.fetchResult?.count ?? 0;
    }
    
    //返回 cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoIdentifier, for: indexPath) as! WFImagePickerCollectionViewCell;
        
        cell.asset = self.item?.fetchResult?[indexPath.row]
        cell.delegate = self
        if let asset = self.item?.fetchResult?[indexPath.row].asset {
            //获取缩略图
            self.imageManager.requestImage(for: asset, targetSize: assetGridThumbnailSize,
                                           contentMode: .aspectFill, options: nil) {
                                            (image, nfo) in
                                            cell.imageView.image = image
            }
        }
        
        return cell;
    }
    
    //item 对应的点击事件
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let assets = self.item?.fetchResult {
            let vc = WFPhotoBrowserViewController(configuration, selectIndex: indexPath.row, assets: assets)
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    
}

extension WFPhotoCollectionViewController : WFImagePickerCollectionViewCellDelegate {
    
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
        
        let button:UIButton = sendBtn.customView as! UIButton
        if WFUserContext.shared.selectAlbum.count > 0 {
            button.setTitle("\(configuration.doneTitle)(\(WFUserContext.shared.selectAlbum.count))", for: .normal)
        } else {
            button.setTitle(configuration.doneTitle, for: .normal)
        }
        collectionView.reloadData()
    }
}

extension WFPhotoCollectionViewController {
    //取消按钮点击
    @objc func cancel() {
        //退出当前视图控制器
        //self.navigationController?.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: WF_NotificationCancel), object: nil)
    }
    //确定
    @objc func didClickSendAlbumButton(_ sender:UIButton) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: WF_NotificationDone), object: nil)
    }
}
