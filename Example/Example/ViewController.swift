//
//  ViewController.swift
//  Example
//
//  Created by happi on 2018/7/7.
//  Copyright © 2018年 feitan. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addImage(_ sender: UIButton) {
        
        
        let config = WFImagePickerConfiguration()
            .setPhotoTitle("相簿")
            .setPhotoTitleColor(UIColor.red)
            .setPhotoImage(UIImage(named: "photo"))//如果设置的图标 则标题文字失效
            .setCameraTitle("拍照")
            .setCameraTitleColor(UIColor.blue)
            .setCameraImage(UIImage(named: "camera"))//如果设置的图标 则标题文字失效
            .setDoneTitle("OK")
            .setDoneTitleColor(UIColor.red)
            .setDoneBackgroundColor(UIColor.brown)
            .setItemSpacing(3)//图片间隔
            .setPickerHeight(350)//选择器高度 默认246
        
        //let vc = WFImagePickerController(config)
        let vc = WFImagePickerController()
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    
}
extension ViewController : WFImagePickerControllerDelegate {
    ///调用系统相机 拍照返回的图片
    func wFImagePickerController(_ controller: WFImagePickerController, didCameraDone image: UIImage) {
        print("-->\(image)")
    }
    
    /// 选择相册返回的图片
    func wFImagePickerController(_ controller: WFImagePickerController, didImagePickerDone assets: [WFAsset]) {
        
        for asset in assets {
            //同步获取图片
            let option = PHImageRequestOptions()
            option.isSynchronous = true
            option.resizeMode = .exact
            PHImageManager.default().requestImage(for: asset.asset!, targetSize: PHImageManagerMaximumSize,
                                                  contentMode: .aspectFill, options: option) {
                                                    (image, nfo) in
                                                    if let image = image {
                                                        print("---\(asset.count)    \(image)")
                                                    }
                                                    
            }
        }
    }
    
    
}
