//
//  WFUserContext.swift
//  WFImagePicker
//
//  Created by happi on 2018/7/3.
//  Copyright © 2018年 feitan. All rights reserved.
//

import UIKit

class WFUserContext: NSObject {
    // 用户  单列
    static let shared = WFUserContext();
    
    //我们需要的源数据
    var items:[WFImageAlbumModel] = []
    
    //选择的图片
    var selectAlbum:[WFAsset] = []
    
    
}
