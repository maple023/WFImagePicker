# WFImagePicker
Swift仿QQ图片选择器


![](https://github.com/maple023/WFImagePicker/blob/master/ios.gif)


### 导入方法
- 方法一、直接把Source文件夹拖入到您的工程中.

```swift
一定要将 Model 目录下 的  WFConfig.swift  文件里的  let Release = true 改为 false    不然资源图片无法加载
``` 

-方法二、 Cocoapods安装

```swift
pod search WFImagePicker
pod 'WFImagePicker'
```

如果没有发现WFImagePicker,然后执行pod repo update --verbose命令更新本地spec缓存（可能需要几分钟），然后再搜索就可以了.




### 调用方法

-  创建
```swift

		///一些可修改的 样式配置  不传则显示默认的样式
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
```

- 实现协议
```swift
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
```

#### Example中导入MLeaksFinder框架 只是用于测试内存泄露，并不妨碍项目本身，使用时无需关心。

