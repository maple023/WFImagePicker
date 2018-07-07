//
//  WFPhotoBrowserCollectionViewCell.swift
//  WFImagePicker
//
//  Created by happi on 2018/7/3.
//  Copyright © 2018年 feitan. All rights reserved.
//

import UIKit
import Photos

class WFPhotoBrowserCollectionViewCell: UICollectionViewCell,UIGestureRecognizerDelegate ,UIScrollViewDelegate {
    var imageRect = CGRect(x: 0 , y:0, width: WF_SCREEN_WIDTH  , height:  WF_SCREEN_HEIGHT )
    
   // var dismissClosure: (( )->())?
    
    
    var totalScale : CGFloat = 1.0
    var maxScale : CGFloat = 5.0
    var minScale : CGFloat = 1
    
    
    //大图尺寸
    func getImageSize(image: UIImage){
       
        
        let imageSize = image.size
        let imageW = imageSize.width
        let imageH = imageSize.height
        let actualImageW = WF_SCREEN_WIDTH
        let actualImageH = actualImageW/imageW * imageH
        
        
        imageRect = CGRect(x: 0, y: (WF_SCREEN_HEIGHT - actualImageH)/2, width: actualImageW, height: actualImageH)
        
        if actualImageH > WF_SCREEN_HEIGHT {
            imageRect = CGRect(x: 0, y: 0, width: WF_SCREEN_WIDTH, height: WF_SCREEN_HEIGHT)
        }
        
        
        self.scrollView.contentSize = CGSize(width: imageRect.size.width, height: imageRect.size.height)
        
        self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        self.scrollView.contentInset = UIEdgeInsets(top: imageRect.origin.y, left: 0, bottom: 0, right: 0)
        
        backImg.frame = CGRect(x: 0, y: 0, width: imageRect.size.width, height: imageRect.size.height)
        
        backImg.layoutIfNeeded()
        scrollView.layoutIfNeeded()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
        self.contentView.addSubview(scrollView)
        
        scrollView.addSubview(backImg)
        
        scrollView.delegate = self
        addGesture()
    }
    
    let tap = UITapGestureRecognizer()
    private func addGesture(){
        //单击
        //let tap = UITapGestureRecognizer(target: self, action: #selector(backImgTap1(recognizer:)))
        tap.numberOfTouchesRequired = 1
        tap.numberOfTapsRequired = 1
        tap.delegate = self
        backImg.addGestureRecognizer(tap)
        self.scrollView.addGestureRecognizer(tap)
        
        //双击
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(backImgTap2(recognizer:)))
        tap2.numberOfTapsRequired = 2
        tap2.numberOfTouchesRequired = 1
        tap2.delegate = self
        backImg.addGestureRecognizer(tap2)
        tap.require(toFail: tap2)
        self.scrollView.addGestureRecognizer(tap2)
        
        
        //啮合手势
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchDid(recognizer:)))
        pinch.delegate = self
        backImg.addGestureRecognizer(pinch)
        
        //拖拽
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panDid(recognizer:)))
        pan.maximumNumberOfTouches = 1  //一个手指拖动
        pan.delegate = self
        backImg.addGestureRecognizer(pan)
    }
    
    
    //拖拽
    @objc private func panDid(recognizer:UIPanGestureRecognizer) {
        let backImageVi = recognizer.view as! UIImageView
        let point = recognizer.translation(in: self.contentView)
        backImageVi.transform.translatedBy(x: point.x, y: point.y)
        recognizer.setTranslation(CGPoint(x: 0, y: 0), in: backImageVi)
    }
    
    //单击
    @objc private func backImgTap1(recognizer: UITapGestureRecognizer){

        
    }
    
    //双击
    @objc private func backImgTap2(recognizer: UITapGestureRecognizer){
        let backImageVi = self.backImg
        let touchPoint = recognizer.location(in: backImageVi)
        
        UIView.animate(withDuration: 0.25) {
            if backImageVi.frame.size.width > self.imageRect.width{//缩小
                self.scrollView.contentInset = UIEdgeInsets(top: self.imageRect.origin.y, left: 0, bottom: 0, right: 0)
                let zoomRect = self.zoomRectFor(scale: 1, center: touchPoint)
                self.scrollView.zoom(to:zoomRect, animated: true)
                self.scrollView.layoutIfNeeded()
            }else{//放大
                let bili = WF_SCREEN_HEIGHT/self.imageRect.height
                
                if bili > 2{
                    let zoomRect = self.zoomRectFor(scale: bili, center: touchPoint)
                    self.scrollView.zoom(to:zoomRect, animated: true)
                }else{
                    let  zoomRect1 = self.zoomRectFor(scale: 2, center: touchPoint)
                    self.scrollView.zoom(to:zoomRect1, animated: true)
                }
                
                self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                self.scrollView.layoutIfNeeded()
            }
        }
    }
    
    //捏合
    @objc private func pinchDid(recognizer: UIPinchGestureRecognizer){
        self.scrollView.contentInset = UIEdgeInsets(top: self.imageRect.origin.y, left: 0, bottom: 0, right: 0)
        
        let scale = recognizer.scale
        self.totalScale *= scale
        recognizer.scale = 1.0;
        
        if totalScale > maxScale {
            return
        }
        if totalScale < minScale{
            return
        }
        
        self.scrollView.setZoomScale(totalScale, animated: true)
        self.scrollView.layoutIfNeeded()
    }
    
    func zoomRectFor(scale: CGFloat,center: CGPoint) -> CGRect{
        let imgW = imageRect.size.width
        let imgH = imageRect.size.height
        var zoomRect: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
        zoomRect.size.height = imgH / scale
        zoomRect.size.width  = imgW / scale
        zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0)
        return zoomRect;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //允许多个手势存在
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool{
        return true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView){
    }
    
    
    // 告诉scrollview要缩放的是哪个子控件
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.backImg
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if totalScale >= maxScale {
            totalScale = maxScale
        }else if totalScale < minScale{
            totalScale = minScale
        }
    }
    
    
    // ------懒加载------
    lazy var backImg : UIImageView = {
        var img = UIImageView()
        img.isUserInteractionEnabled = true
        img.contentMode = .scaleAspectFit
        img.frame = CGRect(x: 0, y: 0, width: WF_SCREEN_WIDTH , height: WF_SCREEN_HEIGHT )
        img.backgroundColor = UIColor.black
        return img
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor.black
        scrollView.minimumZoomScale = 1;
        scrollView.maximumZoomScale = 5;
        
        scrollView.frame = CGRect(x: 0, y: 0, width: WF_SCREEN_WIDTH, height: WF_SCREEN_HEIGHT)
        scrollView.contentSize = CGSize(width: WF_SCREEN_WIDTH, height: WF_SCREEN_HEIGHT)
        
        scrollView.isUserInteractionEnabled = true
        scrollView.setZoomScale(1, animated: false)
        scrollView.alwaysBounceHorizontal = true
        return scrollView
    }()
}
