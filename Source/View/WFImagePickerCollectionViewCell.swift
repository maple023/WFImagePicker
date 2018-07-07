//
//  WFImagePickerCollectionViewCell.swift
//  WFImagePicker
//
//  Created by happi on 2018/6/29.
//  Copyright © 2018年 feitan. All rights reserved.
//

import UIKit

protocol WFImagePickerCollectionViewCellDelegate:NSObjectProtocol {
    ///选择的内容
    func wFImagePickerCollectionViewCell(_ view: WFImagePickerCollectionViewCell, didSelectAsset asset:WFAsset?)
    
}

class WFImagePickerCollectionViewCell: UICollectionViewCell {
    // MARK: - 构造函数
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        drawWithView()
    }
    
    weak var delegate: WFImagePickerCollectionViewCellDelegate?
    
    // MARK: - 准备UI
    fileprivate func drawWithView() {
        contentView.backgroundColor = UIColor.clear
        
        addSubview(imageView)
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]|", options: [], metrics: nil, views: ["imageView": imageView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", options: [], metrics: nil, views: ["imageView": imageView]))
        
        addSubview(seletedButton)
    }
    
    var asset:WFAsset? {
        didSet {
            guard let asset = asset else {
                return
            }
            
            pointSeleteButton(asset.offset)
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
    
    
    @objc func seletedButtonDidSelected(_ sender:UIButton) {
        if delegate != nil {
            delegate?.wFImagePickerCollectionViewCell(self, didSelectAsset: asset)
        }
    }
    
    //播放动画，是否选中的图标改变时使用
    func playAnimate() {
        //图标先缩小，再放大
        UIView.animateKeyframes(withDuration: 0.4, delay: 0, options: .allowUserInteraction,
                                animations: {
                                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2,
                                                       animations: {
                                                        self.seletedButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                                    })
                                    UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.4,
                                                       animations: {
                                                        self.seletedButton.transform = CGAffineTransform.identity
                                    })
        }, completion: nil)
    }
    
    func pointSeleteButton(_ offset:CGPoint?) {
        if let offset = offset {
            let rightPoint = CGPoint(x: offset.x + WF_SCREEN_WIDTH, y:WF_CountLabelWidth)
            let rightPoint_x = offset.x + WF_SCREEN_WIDTH
            if self.frame.contains(rightPoint) {
                var newCenter = CGPoint(x: rightPoint_x - self.frame.origin.x - WF_CountLabelWidth * 0.5 - 3, y: WF_CountLabelWidth * 0.5 + 3)
                if newCenter.x < (WF_CountLabelWidth * 0.5 + 3) {
                    newCenter = CGPoint(x: WF_CountLabelWidth * 0.5 + 3, y: WF_CountLabelWidth * 0.5 + 3)
                }
                self.seletedButton.center = newCenter
            } else {
                self.seletedButton.center = CGPoint(x: self.frame.size.width - WF_CountLabelWidth * 0.5 - 3, y: WF_CountLabelWidth * 0.5 + 3)
            }
        } else {
            self.seletedButton.center = CGPoint(x: self.frame.size.width - WF_CountLabelWidth * 0.5 - 3, y: WF_CountLabelWidth * 0.5 + 3)
        }
        
    }
    
    
    
    
    //显示缩略图
    lazy var imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
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
       // button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
}
