//
//  WFConfig.swift
//  WFImagePicker
//
//  Created by happi on 2018/6/30.
//  Copyright © 2018年 feitan. All rights reserved.
//

import Foundation
import UIKit

let WF_SCREEN_BOUNDS = UIScreen.main.bounds
let WF_SCREEN_WIDTH = WF_SCREEN_BOUNDS.width
let WF_SCREEN_HEIGHT = WF_SCREEN_BOUNDS.height
let WF_SCALE_SCREEN = UIScreen.main.scale


let WF_TOOLBAR_HEIGHT:CGFloat = 44//选择器底部工具栏高度
let WF_CountLabelWidth:CGFloat = 20 //选择按钮大小

let WF_NotificationCancel = "WF_NotificationCancel"//取消通知
let WF_NotificationDone = "WF_NotificationDone"//完成通知

/// iPhone X
let WF_iPhoneX = (WF_SCREEN_WIDTH == 375.0 && WF_SCREEN_HEIGHT == 812.0 ? true : false)

/// 顶部安全距离
let WF_SafeAreaTopHeight:CGFloat = (WF_iPhoneX ? 44.0 : 20.0)

/// 底部安全距离
let WF_SafeAreaBottomHeight:CGFloat = (WF_iPhoneX ? 34.0 : 0.0)

/// 加上导航栏顶部安全距离
let WF_NavSafeAreaTopHeight:CGFloat = (WF_iPhoneX ? 88.0 : 64.0)

/// 加上tab底部部安全距离
let WF_TabSafeAreaBottomHeight:CGFloat = (WF_iPhoneX ? 49.0 + 34.0 : 49.0)



extension UIView {
    
    func getCurrentViewController() -> UIViewController? {
        var next = self.next;
        repeat {
            if next is UIViewController {
                return (next as! UIViewController)
            }
            next = next?.next
        } while (next != nil)
        
        return nil
    }
    
}
