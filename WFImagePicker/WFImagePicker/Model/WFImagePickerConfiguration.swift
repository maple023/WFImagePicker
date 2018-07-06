//
//  WFImagePickerConfiguration.swift
//  WFImagePicker
//
//  Created by happi on 2018/7/5.
//  Copyright © 2018年 feitan. All rights reserved.
//

import UIKit

class WFImagePickerConfiguration: NSObject {

    /// 相册标题
    var photoTitle:String = "相册"
    /// 相册标题 颜色
    var photoTitleColor:UIColor = UIColor(red: 0.09, green: 0.56, blue: 0.92, alpha: 1.0)
    /// 相册图标
    var photoImage:UIImage? //如果图片不为空 这不显示文字
    
    /// 相机标题
    var cameraTitle:String = "相机"
    /// 相机标题 颜色
    var cameraTitleColor:UIColor = UIColor(red: 0.09, green: 0.56, blue: 0.92, alpha: 1.0)
    /// 相册图标
    var cameraImage:UIImage? //如果图片不为空 这不显示文字
    
    /// 确定标题
    var doneTitle:String = "确定"
    /// 确定标题 颜色
    var doneTitleColor:UIColor = UIColor.white
    /// 确定背景颜色
    var doneBackgroundColor = UIColor(red: 0.12, green: 0.52, blue: 0.98, alpha: 1.0)
    
    /// 图片间距
    var itemSpacing:CGFloat = 3
    /// 选择器高度
    var pickerHeight:CGFloat = 246
    
}
extension WFImagePickerConfiguration {
    
    func setPhotoTitle(_ title:String) -> WFImagePickerConfiguration {
        self.photoTitle = title
        return self
    }
    func setPhotoTitleColor(_ color:UIColor) -> WFImagePickerConfiguration {
        self.photoTitleColor = color
        return self
    }
    func setPhotoImage(_ image:UIImage?) -> WFImagePickerConfiguration {
        self.photoImage = image
        return self
    }
    
    
    func setCameraTitle(_ title:String) -> WFImagePickerConfiguration {
        self.cameraTitle = title
        return self
    }
    func setCameraTitleColor(_ color:UIColor) -> WFImagePickerConfiguration {
        self.cameraTitleColor = color
        return self
    }
    func setCameraImage(_ image:UIImage?) -> WFImagePickerConfiguration {
        self.cameraImage = image
        return self
    }
    
    
    func setDoneTitle(_ title:String) -> WFImagePickerConfiguration {
        self.doneTitle = title
        return self
    }
    func setDoneTitleColor(_ color:UIColor) -> WFImagePickerConfiguration {
        self.doneTitleColor = color
        return self
    }
    func setDoneBackgroundColor(_ color:UIColor) -> WFImagePickerConfiguration {
        self.doneBackgroundColor = color
        return self
    }
    
    func setItemSpacing(_ spacing:CGFloat) -> WFImagePickerConfiguration {
        self.itemSpacing = spacing
        return self
    }
    func setPickerHeight(_ height:CGFloat) -> WFImagePickerConfiguration {
        self.pickerHeight = height
        return self
    }
}
