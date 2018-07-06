//
//  WFImagePickerListController.swift
//  WFImagePicker
//
//  Created by happi on 2018/6/30.
//  Copyright © 2018年 feitan. All rights reserved.
//

import UIKit

class WFPhotoListController: UIViewController {
    
    init(_ configuration:WFImagePickerConfiguration) {
        super.init(nibName: nil, bundle: nil)
        self.configuration = configuration
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func loadView() {
        let view = UIView()
        view.backgroundColor = UIColor.white
        self.view = view;
        drawWithView()
    }
    
    /// 配置
    var configuration:WFImagePickerConfiguration!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //设置标题
        title = "相簿"
        //添加导航栏右侧的取消按钮
        let rightBarItem = UIBarButtonItem(title: "取消", style: .plain, target: self,
                                           action:#selector(cancel) )
        self.navigationItem.rightBarButtonItem = rightBarItem
        
        if WFUserContext.shared.items.count > 0 {
            let vc = WFPhotoCollectionViewController(configuration)
            vc.item = WFUserContext.shared.items.first
            self.navigationController?.pushViewController(vc, animated: false)
        }
        
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    fileprivate func drawWithView() {
        //添加导航栏右侧的取消按钮
        let rightBarItem = UIBarButtonItem(title: "取消", style: .plain, target: self,
                                           action:#selector(cancel) )
        self.navigationItem.rightBarButtonItem = rightBarItem
        
        view.addSubview(mTableView)
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[mTableView]-(\(WF_SafeAreaBottomHeight))-|", options: [], metrics: nil, views: ["mTableView": mTableView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[mTableView]|", options: [], metrics: nil, views: ["mTableView": mTableView]))
    }

    //MARK: 懒加载
    let listIdentifier = "listIdentifier"
    fileprivate lazy var mTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = 56
        tableView.backgroundColor = UIColor.clear
        tableView.register(WFPhotoListTableViewCell.self, forCellReuseIdentifier: self.listIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
}
// MARK: - UITableViewDataSource, UITableViewDelegate
extension WFPhotoListController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WFUserContext.shared.items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: listIdentifier) as! WFPhotoListTableViewCell
        cell.item = WFUserContext.shared.items[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = WFPhotoCollectionViewController(configuration)
        vc.item = WFUserContext.shared.items[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension WFPhotoListController {
    //取消按钮点击
    @objc func cancel() {
        //退出当前视图控制器
        NotificationCenter.default.post(name: Notification.Name(rawValue: WF_NotificationCancel), object: nil)
    }
}
