//
//  WFPhotoBrowserViewController.swift
//  WFImagePicker
//
//  Created by happi on 2018/7/3.
//  Copyright © 2018年 feitan. All rights reserved.
//

import UIKit
import Photos

class WFPhotoBrowserViewController: UIViewController {
    
    override func loadView() {
        let view = UIView()
        view.backgroundColor = UIColor.black
        self.view = view;
        drawWithView()
    }
    
    /// 配置
    var configuration:WFImagePickerConfiguration!;
    
    //相簿
    var assets:[WFAsset] = []
    var currentPage:Int = 0
    
    //带缓存的图片管理对象
    var imageManager:PHCachingImageManager!
    
    //3 相册
    init(_ configuration:WFImagePickerConfiguration, selectIndex: Int, assets: [WFAsset]) {
        super.init(nibName: nil, bundle: nil)
        self.configuration = configuration
        self.currentPage = selectIndex
        self.assets = assets
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //初始化和重置缓存
        self.imageManager = PHCachingImageManager()
        self.imageManager.stopCachingImagesForAllAssets()
        
        
        titleLabel.text = "\(currentPage + 1)/\(self.assets.count)"
        let asset = assets[currentPage]
        if asset.count > 0 {
            seletedButton.isSelected = true
            seletedButton.backgroundColor = UIColor(red: 46/255, green: 178/255, blue: 243/255, alpha: 1)
            seletedButton.setTitle("\(asset.count)", for: .selected)
        } else {
            seletedButton.isSelected = false
            seletedButton.backgroundColor = UIColor.clear
            seletedButton.setTitle("", for: .normal)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let indexPath = IndexPath(item: currentPage, section: 0)
        DispatchQueue.main.async {
            if indexPath.row <= (self.assets.count - 1){
                self.collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
            }
        }
       
        if WFUserContext.shared.selectAlbum.count > 0 {
            sendBtn.setTitle("\(configuration.doneTitle)(\(WFUserContext.shared.selectAlbum.count))", for: .normal)
        } else {
            sendBtn.setTitle(configuration.doneTitle, for: .normal)
        }
        self.collectionView.reloadData()
    }
    
    //需要修改的约束
    var topTop:NSLayoutConstraint?
    var bottomBottom:NSLayoutConstraint?
    var isToolBarShow = true//工具栏是否显示
    
    fileprivate func drawWithView() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[collectionView]|", options: [], metrics: nil, views: ["collectionView": collectionView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[collectionView]|", options: [], metrics: nil, views: ["collectionView": collectionView]))
        
        
        
        view.addSubview(topToolBar)
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[topToolBar]|", options: [], metrics: nil, views: ["topToolBar": topToolBar]))
        let topHeight:NSLayoutConstraint = NSLayoutConstraint(item: topToolBar, attribute: NSLayoutAttribute.height, relatedBy:NSLayoutRelation.equal, toItem:nil, attribute:.notAnAttribute, multiplier:1.0, constant: WF_TOOLBAR_HEIGHT + WF_SafeAreaTopHeight)
        topToolBar.addConstraint(topHeight)
        topTop = NSLayoutConstraint(item: topToolBar, attribute: NSLayoutAttribute.top, relatedBy:NSLayoutRelation.equal, toItem:view, attribute:NSLayoutAttribute.top, multiplier:1.0, constant: 0)
        topToolBar.superview!.addConstraint(topTop!)
        
        
        
        
        let navView = UIView()
        navView.translatesAutoresizingMaskIntoConstraints = false
        topToolBar.addSubview(navView)
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[navView]|", options: [], metrics: nil, views: ["navView": navView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:[navView(==\(WF_TOOLBAR_HEIGHT))]|", options: [], metrics: nil, views: ["navView": navView]))
        
        let backBtn = UIButton(type: .custom)
        backBtn.setTitle("照片", for: UIControlState())
        backBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        backBtn.setTitleColor(UIColor.white, for: UIControlState())
        backBtn.setTitleColor(UIColor.white, for: .highlighted)
        backBtn.contentHorizontalAlignment = .left
        backBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        backBtn.setImage(UIImage(named: WFBundlePath("wf_back_left")), for: UIControlState())
        backBtn.setImage(UIImage(named: WFBundlePath("wf_back_left")), for: .highlighted)
        backBtn.addTarget(self, action: #selector(didClickBackButton(_:)), for: .touchUpInside)
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        navView.addSubview(backBtn)
        let left1:NSLayoutConstraint = NSLayoutConstraint(item: backBtn, attribute: NSLayoutAttribute.left, relatedBy:NSLayoutRelation.equal, toItem:navView, attribute:NSLayoutAttribute.left, multiplier:1.0, constant: 10)
        backBtn.superview!.addConstraint(left1)
        let centerY1:NSLayoutConstraint = NSLayoutConstraint(item: backBtn, attribute: NSLayoutAttribute.centerY, relatedBy:NSLayoutRelation.equal, toItem:navView, attribute:NSLayoutAttribute.centerY, multiplier:1.0, constant: 0)
        backBtn.superview!.addConstraint(centerY1)
        let width1:NSLayoutConstraint = NSLayoutConstraint(item: backBtn, attribute: NSLayoutAttribute.width, relatedBy:NSLayoutRelation.equal, toItem:nil, attribute:.notAnAttribute, multiplier:1.0, constant: 50)
        backBtn.addConstraint(width1)
        
        navView.addSubview(titleLabel)
        let centerY2:NSLayoutConstraint = NSLayoutConstraint(item: titleLabel, attribute: NSLayoutAttribute.centerY, relatedBy:NSLayoutRelation.equal, toItem:navView, attribute:NSLayoutAttribute.centerY, multiplier:1.0, constant: 0)
        titleLabel.superview!.addConstraint(centerY2)
        let centerX2:NSLayoutConstraint = NSLayoutConstraint(item: titleLabel, attribute: NSLayoutAttribute.centerX, relatedBy:NSLayoutRelation.equal, toItem:navView, attribute:NSLayoutAttribute.centerX, multiplier:1.0, constant: 0)
        titleLabel.superview!.addConstraint(centerX2)
        
        navView.addSubview(seletedButton)
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:[seletedButton(==\(WF_CountLabelWidth))]-(10)-|", options: [], metrics: nil, views: ["seletedButton": seletedButton]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:[seletedButton(==\(WF_CountLabelWidth))]", options: [], metrics: nil, views: ["seletedButton": seletedButton]))
        let centerY3:NSLayoutConstraint = NSLayoutConstraint(item: seletedButton, attribute: NSLayoutAttribute.centerY, relatedBy:NSLayoutRelation.equal, toItem:navView, attribute:NSLayoutAttribute.centerY, multiplier:1.0, constant: 0)
        seletedButton.superview!.addConstraint(centerY3)
        
        
        
        
        
        view.addSubview(bottomToolBar)
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomToolBar]|", options: [], metrics: nil, views: ["bottomToolBar": bottomToolBar]))
        let bottomHeight:NSLayoutConstraint = NSLayoutConstraint(item: bottomToolBar, attribute: NSLayoutAttribute.height, relatedBy:NSLayoutRelation.equal, toItem:nil, attribute:.notAnAttribute, multiplier:1.0, constant: WF_TOOLBAR_HEIGHT + WF_SafeAreaBottomHeight)
        bottomToolBar.addConstraint(bottomHeight)
        bottomBottom = NSLayoutConstraint(item: bottomToolBar, attribute: NSLayoutAttribute.bottom, relatedBy:NSLayoutRelation.equal, toItem:view, attribute:NSLayoutAttribute.bottom, multiplier:1.0, constant: 0)
        bottomToolBar.superview!.addConstraint(bottomBottom!)
        
        
        let navBottomView = UIView()
        navBottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomToolBar.addSubview(navBottomView)
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[navBottomView]|", options: [], metrics: nil, views: ["navBottomView": navBottomView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[navBottomView(==\(WF_TOOLBAR_HEIGHT))]", options: [], metrics: nil, views: ["navBottomView": navBottomView]))
        
        navBottomView.addSubview(sendBtn)
        let right4:NSLayoutConstraint = NSLayoutConstraint(item: sendBtn, attribute: NSLayoutAttribute.right, relatedBy:NSLayoutRelation.equal, toItem:navBottomView, attribute:NSLayoutAttribute.right, multiplier:1.0, constant: -10)
        sendBtn.superview!.addConstraint(right4)
        let centerY4:NSLayoutConstraint = NSLayoutConstraint(item: sendBtn, attribute: NSLayoutAttribute.centerY, relatedBy:NSLayoutRelation.equal, toItem:navBottomView, attribute:NSLayoutAttribute.centerY, multiplier:1.0, constant: 0)
        sendBtn.superview!.addConstraint(centerY4)
        let width4:NSLayoutConstraint = NSLayoutConstraint(item: sendBtn, attribute: NSLayoutAttribute.width, relatedBy:NSLayoutRelation.equal, toItem:nil, attribute:.notAnAttribute, multiplier:1.0, constant: 50)
        sendBtn.addConstraint(width4)
        let height4:NSLayoutConstraint = NSLayoutConstraint(item: sendBtn, attribute: NSLayoutAttribute.height, relatedBy:NSLayoutRelation.equal, toItem:nil, attribute:.notAnAttribute, multiplier:1.0, constant: 25)
        sendBtn.addConstraint(height4)
    }

    
    //懒加载
    //顶部工具栏
    fileprivate lazy var topToolBar:UIView = {
        let toolBar = UIView()
        toolBar.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        return toolBar
    }()
    
    fileprivate lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.white
        label.text = "0/0"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //选择按钮
    fileprivate lazy var seletedButton:UIButton = {
        let button = UIButton()
        button.bounds = CGRect(x: 0, y: 0, width: WF_CountLabelWidth, height: WF_CountLabelWidth)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = WF_CountLabelWidth / 2
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(seletedButtonDidSelected(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //顶部工具栏
    fileprivate lazy var bottomToolBar:UIView = {
        let toolBar = UIView()
        toolBar.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        return toolBar
    }()
    fileprivate lazy var sendBtn:UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(configuration.doneTitle, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setTitleColor(configuration.doneTitleColor, for: .normal)
        button.backgroundColor = configuration.doneBackgroundColor
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 2
        button.addTarget(self, action: #selector(didClickSendAlbumButton(_:)), for: .touchUpInside)
        return button
    }()
    
    
    /// 内容载体
    let browserIdentifier = "browserIdentifier"
    fileprivate lazy var collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: WF_SCREEN_WIDTH,
                                 height: WF_SCREEN_HEIGHT)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(WFPhotoBrowserCollectionViewCell.self, forCellWithReuseIdentifier: self.browserIdentifier)
        return collectionView
    }()
    
}

///MARK: - UICollectionViewDelegate,UICollectionViewDataSource
extension WFPhotoBrowserViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    //每个分区含有的 item 个数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count;
    }
    
    //返回 cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: browserIdentifier, for: indexPath) as! WFPhotoBrowserCollectionViewCell;
        
        cell.scrollView.setZoomScale(1, animated: false)
        //获取原图
        if let asset = assets[indexPath.row].asset {
            //获取原图 PHImageManagerMaximumSize
            let option = PHImageRequestOptions()
            option.isSynchronous = true
            option.resizeMode = .exact
            self.imageManager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize,
                                           contentMode: .aspectFill, options: option) {
                                            (image, nfo) in
                                            if let image = image {
                                                cell.backImg.image = image
                                                cell.getImageSize(image: image)
                                            }
                                            
            }
        }
        cell.tap.addTarget(self, action: #selector(backImgTap1(recognizer:)))
        
        return cell;
    }
    
    //单击
    @objc private func backImgTap1(recognizer: UITapGestureRecognizer){
        
        if isToolBarShow {
            //隐藏工具栏
            UIView.animateKeyframes(withDuration: 0.4, delay: 0, options: .allowUserInteraction,
                                    animations: {
                                        self.topTop?.constant = -(WF_TOOLBAR_HEIGHT + WF_SafeAreaTopHeight)
                                        self.bottomBottom?.constant = (WF_TOOLBAR_HEIGHT + WF_SafeAreaBottomHeight)
                                        self.view.layoutIfNeeded()
            }, completion: nil)
            isToolBarShow = false
        } else {
            //显示工具栏
            UIView.animateKeyframes(withDuration: 0.4, delay: 0, options: .allowUserInteraction,
                                    animations: {
                                        self.topTop?.constant = 0
                                        self.bottomBottom?.constant = 0
                                        self.view.layoutIfNeeded()
            }, completion: nil)
            isToolBarShow = true
        }
    }
    
    
    //item 对应的点击事件
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentPage = Int(scrollView.contentOffset.x / WF_SCREEN_WIDTH)
        
        titleLabel.text = "\(currentPage + 1)/\(self.assets.count)"
        let asset = assets[currentPage]
        if asset.count > 0 {
            seletedButton.isSelected = true
            seletedButton.backgroundColor = UIColor(red: 46/255, green: 178/255, blue: 243/255, alpha: 1)
            seletedButton.setTitle("\(asset.count)", for: .selected)
        } else {
            seletedButton.isSelected = false
            seletedButton.backgroundColor = UIColor.clear
            seletedButton.setTitle("", for: .normal)
        }
    }
    
}

extension WFPhotoBrowserViewController {
    @objc func didClickBackButton(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func didClickSendAlbumButton(_ sender:UIButton) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: WF_NotificationDone), object: nil)
    }
    
    @objc func seletedButtonDidSelected(_ sender:UIButton) {
        let asset = assets[currentPage]
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
        
        if asset.count > 0 {
            seletedButton.isSelected = true
            seletedButton.backgroundColor = UIColor(red: 46/255, green: 178/255, blue: 243/255, alpha: 1)
            seletedButton.setTitle("\(asset.count)", for: .selected)
        } else {
            seletedButton.isSelected = false
            seletedButton.backgroundColor = UIColor.clear
            seletedButton.setTitle("", for: .normal)
        }
        
        
        if WFUserContext.shared.selectAlbum.count > 0 {
            sendBtn.setTitle("\(configuration.doneTitle)(\(WFUserContext.shared.selectAlbum.count))", for: .normal)
        } else {
            sendBtn.setTitle(configuration.doneTitle, for: .normal)
        }
    }
}
