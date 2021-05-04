//
//  UIViewController+ATCAdditions.swift
//  ShoppingApp
//
//  Created by Florian Marcu on 9/2/17.
//  Copyright © 2017 iOS App Templates. All rights reserved.
//

import UIKit

class ATCCollectionViewController: UICollectionViewController {
    var drawerView: UIView? = nil
    var customDrawerView: UIView? = nil

    func showBottomDrawer(with customView: UIView, customViewHeight: CGFloat) {
        let bounds = view.bounds
        let yOffset: CGFloat = 10.0
        let overlayView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
        overlayView.backgroundColor = UIColor(hexString: "#222222", alpha: 0.0)

        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissBottomDrawerOverlay))
        overlayView.addGestureRecognizer(gesture)
        gesture.delegate = self
        overlayView.addSubview(customView)
        view.addSubview(overlayView)
        customView.frame = CGRect(x: 0, y: bounds.height, width: bounds.width, height: customViewHeight + yOffset)
        UIView.animate(withDuration: 0.3) {
            customView.frame = CGRect(x: 0, y: bounds.height - customViewHeight, width: bounds.width, height: customViewHeight + yOffset)
            overlayView.backgroundColor = UIColor(hexString: "#222222", alpha: 0.7)
        }

        customView.layer.cornerRadius = 15
        customView.clipsToBounds = true

        drawerView = overlayView
        customDrawerView = customView
    }

    @objc func dismissBottomDrawerOverlay() {
        let bounds = view.bounds
        UIView.animate(withDuration: 0.3, animations: {
            let height = self.customDrawerView?.frame.height ?? 1000
            self.customDrawerView?.frame = CGRect(x: 0, y: bounds.height, width: bounds.width, height: height + 10)
            self.drawerView?.backgroundColor = UIColor(hexString: "#222222", alpha: 0.0)
        }) { (_) in
            self.drawerView?.removeFromSuperview()
            self.customDrawerView?.removeFromSuperview()
            self.drawerView = nil
            self.customDrawerView = nil
        }
    }
}

extension ATCCollectionViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let customView = customDrawerView, let touchView = touch.view {
            if touchView.isDescendant(of: customView) {
                return false
            }
        }
        return true
    }
}

extension UIViewController {

    func addChildViewControllerWithView(_ childViewController: UIViewController, toView view: UIView? = nil) {
        let view: UIView = view ?? self.view

        childViewController.removeFromParent()
        childViewController.willMove(toParent: self)
        addChild(childViewController)
        view.addSubview(childViewController.view)
        childViewController.didMove(toParent: self)
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    func removeChildViewController(_ childViewController: UIViewController) {
        childViewController.removeFromParent()
        childViewController.willMove(toParent: nil)
        childViewController.removeFromParent()
        childViewController.didMove(toParent: nil)
        childViewController.view.removeFromSuperview()
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /// Show alert with only one option
    func alert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func alertWithTwoOptions(title: String,
                             message: String?,
                             preferredStyle: UIAlertController.Style = .alert,
                             nextStepTitle: String,
                             cancelCompletionHandler: ((UIAlertAction) -> Void)? = nil,
                             nextStepCompletionHandler: @escaping ((UIAlertAction) -> Void)) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: preferredStyle)
        
        // Next step action
        let nextStepAction = UIAlertAction(title: nextStepTitle, style: .default, handler: nextStepCompletionHandler)
        alertController.addAction(nextStepAction)
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: cancelCompletionHandler)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
