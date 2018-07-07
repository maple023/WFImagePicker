//
//  WFPresentationController.swift
//  WFImagePicker
//
//  Created by happi on 2018/6/29.
//  Copyright © 2018年 feitan. All rights reserved.
//

import UIKit

class WFPresentationController: UIPresentationController {
    
    override var frameOfPresentedViewInContainerView: CGRect {
        var frame: CGRect = .zero
        frame.size = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerView!.bounds.size)
        frame.origin.y = containerView!.frame.height - (configuration.pickerHeight + WF_SafeAreaBottomHeight)
        return frame
    }
    
    // MARK: - Initializers
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController? ,configuration:WFImagePickerConfiguration) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        self.configuration = configuration
    }
    
    /// 配置
    var configuration:WFImagePickerConfiguration!;
    
    override func presentationTransitionWillBegin() {
        containerView?.insertSubview(visualView, at: 0)
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[visualView]|", options: [], metrics: nil, views: ["visualView": visualView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[visualView]|", options: [], metrics: nil, views: ["visualView": visualView]))
        
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            visualView.alpha = 0.0
            return
        }
        coordinator.animate(alongsideTransition: { _ in
            self.visualView.alpha = 0.0
        })
    }
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: parentSize.width, height: configuration.pickerHeight + WF_SafeAreaBottomHeight)
    }
    
    //懒加载
    // MARK: - Properties
    fileprivate lazy var visualView:UIVisualEffectView = {
        let blur = UIBlurEffect(style: .light)
        let visualView = UIVisualEffectView(effect: blur)
        visualView.alpha = 0.1
        visualView.backgroundColor = UIColor.black
        visualView.translatesAutoresizingMaskIntoConstraints = false
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        visualView.addGestureRecognizer(recognizer)
        return visualView
    }()
    
}
// MARK: - Private
private extension WFPresentationController {
    @objc dynamic func handleTap(recognizer: UITapGestureRecognizer) {
        WFUserContext.shared.items.removeAll()
        WFUserContext.shared.selectAlbum.removeAll()
        presentingViewController.dismiss(animated: true)
    }
}
