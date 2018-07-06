//
//  WFImageAlbumModel.swift
//  WFImagePicker
//
//  Created by happi on 2018/7/2.
//  Copyright © 2018年 feitan. All rights reserved.
//

import UIKit
import Photos

class WFImageAlbumModel: NSObject {
    //相簿名称
    var title:String?
    ////相簿内的资源
    var fetchResult:[WFAsset]?
}
class WFAsset: NSObject {
    ///选中的下标
    var count:Int = 0
    
    var asset:PHAsset?
    
    ///记录collection的contOffset
    var offset:CGPoint?
}
