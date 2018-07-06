//
//  WFImagePickerListTableViewCell.swift
//  WFImagePicker
//
//  Created by happi on 2018/6/30.
//  Copyright © 2018年 feitan. All rights reserved.
//

import UIKit

class WFPhotoListTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    // MARK: - 初始化cell
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = UIColor.white
        drawWithView()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func drawWithView() {
        
        contentView.addSubview(title)
        let left1:NSLayoutConstraint = NSLayoutConstraint(item: title, attribute: NSLayoutAttribute.left, relatedBy:NSLayoutRelation.equal, toItem:self.contentView, attribute:NSLayoutAttribute.left, multiplier:1.0, constant: 15)
        title.superview!.addConstraint(left1)
        let centerY1:NSLayoutConstraint = NSLayoutConstraint(item: title, attribute: NSLayoutAttribute.centerY, relatedBy:NSLayoutRelation.equal, toItem:self.contentView, attribute:NSLayoutAttribute.centerY, multiplier:1.0, constant: 0)
        title.superview!.addConstraint(centerY1)
        
        contentView.addSubview(numTitle)
        let left2:NSLayoutConstraint = NSLayoutConstraint(item: numTitle, attribute: NSLayoutAttribute.left, relatedBy:NSLayoutRelation.equal, toItem:title, attribute:NSLayoutAttribute.right, multiplier:1.0, constant: 10)
        numTitle.superview!.addConstraint(left2)
        let centerY2:NSLayoutConstraint = NSLayoutConstraint(item: numTitle, attribute: NSLayoutAttribute.centerY, relatedBy:NSLayoutRelation.equal, toItem:self.contentView, attribute:NSLayoutAttribute.centerY, multiplier:1.0, constant: 0)
        numTitle.superview!.addConstraint(centerY2)
    }
    
    var item:WFImageAlbumModel? {
        didSet {
            guard let item = item else {
                return
            }
            title.text = item.title
            numTitle.text = "(\(item.fetchResult?.count ?? 0))"
        }
    }
    
    
    
    
    lazy var title:UILabel = { ()-> UILabel in
        let lable:UILabel = UILabel()
        lable.textColor = UIColor.black
        lable.font = UIFont.systemFont(ofSize: 15)
        lable.translatesAutoresizingMaskIntoConstraints = false
        return lable
    }()
    lazy var numTitle:UILabel = { ()-> UILabel in
        let lable:UILabel = UILabel()
        lable.textColor = UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1.0)
        lable.font = UIFont.systemFont(ofSize: 14)
        lable.translatesAutoresizingMaskIntoConstraints = false
        return lable
    }()
}
