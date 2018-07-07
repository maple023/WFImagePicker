//
//  WFToolbar.swift
//  WFImagePicker
//
//  Created by happi on 2018/6/29.
//  Copyright © 2018年 feitan. All rights reserved.
//

import UIKit
protocol WFToolbarDelegate:NSObjectProtocol {
    ///点击相册
    func wFToolbar(_ toolbar: WFToolbar, didClickPhotoAlbumButton sender: UIButton)
    ///点击相机
    func wFToolbar(_ toolbar: WFToolbar, didClickCameraAlbumButton sender: UIButton)
    ///点击确定
    func wFToolbar(_ toolbar: WFToolbar, didClickSendAlbumButton sender: UIButton)
}
class WFToolbar: UIToolbar {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    
    weak var wf_delegate: WFToolbarDelegate?
    
    /// 配置
    var configuration:WFImagePickerConfiguration!;
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
       // drawWithView()
    }
    //利构造器 前面加convenience   指定构造器什么都不用加，     系统初始化方法 要加override
    convenience init(_ configuration:WFImagePickerConfiguration) {
        self.init()
        self.configuration = configuration
        drawWithView()
    }
    
    
    
    fileprivate func drawWithView() {
        let space1 = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 44))
        let space2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        self.setItems([photoBtn,UIBarButtonItem(customView: space1),cameraBtn,space2,doneBtn], animated: true)
    }
    
    //懒加载
    // MARK: - Properties
    fileprivate lazy var photoBtn:UIBarButtonItem = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        if let image = configuration.photoImage {
            button.setImage(image, for: .normal);
        } else {
            button.setTitle(configuration.photoTitle, for: UIControlState())
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            button.setTitleColor(configuration.photoTitleColor, for: .normal)
        }
        button.addTarget(self, action: #selector(didClickPhotoAlbumButton(_:)), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }()
    
    fileprivate lazy var cameraBtn:UIBarButtonItem = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        if let image = configuration.cameraImage {
            button.setImage(image, for: .normal);
        } else {
            button.setTitle(configuration.cameraTitle, for: UIControlState())
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            button.setTitleColor(configuration.cameraTitleColor, for: .normal)
        }
        button.addTarget(self, action: #selector(didClickCameraAlbumButton(_:)), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }()
    
    lazy var doneBtn:UIBarButtonItem = {
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
}

extension WFToolbar {
    
    @objc func didClickPhotoAlbumButton(_ sender:UIButton) {
        if wf_delegate != nil {
            wf_delegate?.wFToolbar(self, didClickPhotoAlbumButton: sender)
        }
    }
    
    @objc func didClickCameraAlbumButton(_ sender :UIButton) {
        if wf_delegate != nil {
            wf_delegate?.wFToolbar(self, didClickCameraAlbumButton: sender)
        }
    }
    
    @objc func didClickSendAlbumButton(_ sender:UIButton) {
        if wf_delegate != nil {
            wf_delegate?.wFToolbar(self, didClickSendAlbumButton: sender)
        }
    }
    
}
