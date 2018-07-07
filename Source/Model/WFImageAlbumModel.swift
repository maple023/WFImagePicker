//
//  WFImageAlbumModel.swift
//  WFImagePicker
//
//  Created by happi on 2018/7/2.
//  Copyright © 2018年 feitan. All rights reserved.
//

import UIKit
import Photos

public class WFImageAlbumModel: NSObject {
    //相簿名称
    public var title:String?
    ////相簿内的资源
    public var fetchResult:[WFAsset]?
}
public class WFAsset: NSObject {
    ///选中的下标
    public var count:Int = 0
    
    public var asset:PHAsset?
    
    ///记录collection的contOffset
    public var offset:CGPoint?
}
