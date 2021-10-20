//
//  DimmedPresentation.swift
//  Dimmed Presentation Example
//
//  Created by Huy Trinh Duc on 10/20/21.
//

import Foundation
import UIKit

class DimmedPresentationController: UIPresentationController {

    private let dimmedBackgroundView = UIView()
    var height: CGFloat = 0
    private var hasSetPointOrigin = false
    private var pointOrigin: CGPoint?
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        presentedView?.addGestureRecognizer(panGestureRecognizer)
        dimmedBackgroundView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func containerViewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = presentedView?.frame.origin
        }
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        var frame = CGRect.zero
        if let containerBounds = containerView?.bounds {
            frame = CGRect(x: 0,
                           y: containerBounds.height - height,
                           width: containerBounds.width,
                           height: height)
        }
        return frame
    }

    override func presentationTransitionWillBegin() {
        if let containerView = self.containerView, let coordinator = presentingViewController.transitionCoordinator {
            containerView.addSubview(dimmedBackgroundView)
            dimmedBackgroundView.backgroundColor = .black
            dimmedBackgroundView.frame = containerView.bounds
            dimmedBackgroundView.alpha = 0
            coordinator.animate(alongsideTransition: { [weak self] _ in
                self?.dimmedBackgroundView.alpha = 0.5
            }, completion: nil)
        }
    }
    
    override func dismissalTransitionWillBegin() {
        if let coordinator = self.presentingViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { [weak self] _ in
                self?.dimmedBackgroundView.alpha = 0
            }, completion: nil)
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        self.dimmedBackgroundView.removeFromSuperview()
    }
    
    @objc private func backgroundTapped() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: presentedView)
        
        // Khong cho phep vuot len
        guard translation.y >= 0 else { return }
        
        // Set x = 0 de user chi co the vuot len hoac xuong
        presentedView?.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)
        
        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: presentedView)
            
            //Neu y hien tai cua view > y goc 1 khoang = 100 thi dismiss view
            if presentedView?.frame.origin.y ?? 0 - (pointOrigin?.y ?? 0) > ((pointOrigin?.y ?? 0) + 100){
                backgroundTapped()
            }
            
            if dragVelocity.y >= 1000 {
                // Van toc du nhanh de dismiss view
                backgroundTapped()
            }
            else {
                // Set ve vi tri cu
                UIView.animate(withDuration: 0.3) { [weak self] in
                    self?.presentedView?.frame.origin = self?.pointOrigin ?? CGPoint(x: 0, y: 400)
                }
            }
        }
    }
    
}
class DimmedTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    var height: CGFloat = 0
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let overlay = DimmedPresentationController(presentedViewController: presented, presenting: presenting)
        overlay.height = self.height
        return overlay
    }
    
}
extension UIViewController {
    func presentDimmed(popupViewController: UIViewController, height: CGFloat) {
        let overlayTransitioningDelegate = DimmedTransitioningDelegate()
        overlayTransitioningDelegate.height = height
        popupViewController.transitioningDelegate = overlayTransitioningDelegate
        popupViewController.modalPresentationStyle = .custom
        present(popupViewController, animated: true, completion: nil)
    }
}
