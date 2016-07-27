//
//  WebView.swift
//  WebViewEdgeSwipeTest
//
//  Created by ruwatana on 2016/07/27.
//  Copyright © 2016年 ruwatana. All rights reserved.
//

import UIKit

class WebView: UIWebView {
    @IBOutlet private weak var leftEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer!
    @IBOutlet private weak var rightEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer!
    
    private var webPageImageView: UIView?
    private(set) var isEdgeSwiping: Bool = false
    
    @IBAction func leftEdgePanGestureDetected(sender: UIScreenEdgePanGestureRecognizer) {
        switch sender.state {
        case .Began:
            isEdgeSwiping = true
            
            UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0) // 0.0 (is same to screen scale)
            if let currentContext = UIGraphicsGetCurrentContext() {
                layer.renderInContext(currentContext)
            }
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            webPageImageView?.removeFromSuperview()
            webPageImageView = UIImageView(image: image)
            webPageImageView?.frame = CGRectMake(
                frame.origin.x,
                frame.origin.y,
                frame.size.width,
                frame.size.height - 0.5)
            webPageImageView?.userInteractionEnabled = true
            
            webPageImageView?.layer.shadowOffset = CGSizeMake(-3.0, 0.0)
            webPageImageView?.layer.shadowColor = UIColor.blackColor().CGColor
            webPageImageView?.layer.shadowRadius = 5.0
            webPageImageView?.layer.shadowOpacity = 0.25
            
            if let webPageImageView = webPageImageView {
                addSubview(webPageImageView)
                hidden = true
            }
            
        case .Changed:
            webPageImageView?.frame.origin.x = sender.locationInView(sender.view).x
            
        case .Cancelled:
            webPageImageView?.removeFromSuperview()
            
        case .Ended:
            let screenWidth = UIScreen.mainScreen().bounds.size.width
            let velocity = sender.velocityInView(sender.view).x
            let translation = sender.translationInView(sender.view).x
            let finalPoint = translation + velocity * 0.1   // 0.1 is threshold
            
            print("[Debug]: \(translation, velocity, finalPoint)")
            
            UIView.animateWithDuration(
                0.1,
                animations: {
                    self.webPageImageView?.frame.origin.x = finalPoint > screenWidth / 2 ? screenWidth : 0.0
                },
                completion: { _ in
                    self.webPageImageView?.removeFromSuperview()
                    if finalPoint > screenWidth / 2 && self.canGoBack {
                        self.goBack()
                    } else {
                        self.hidden = false
                    }
                    self.isEdgeSwiping = false
                }
            )
            
        default:
            break
        }
    }
    
    @IBAction func rightEdgePanGestureDetected(sender: UIScreenEdgePanGestureRecognizer) {
        switch sender.state {
        case .Began:
            isEdgeSwiping = true
            
            webPageImageView?.removeFromSuperview()
            webPageImageView = UIView(frame:
                CGRectMake(
                    frame.size.width,
                    frame.origin.y,
                    frame.size.width,
                    frame.size.height - 0.5
                )
            )
            webPageImageView?.userInteractionEnabled = true
            webPageImageView?.backgroundColor = UIColor.whiteColor()
            
            
            webPageImageView?.layer.shadowOffset = CGSizeMake(-3.0, 0.0)
            webPageImageView?.layer.shadowColor = UIColor.blackColor().CGColor
            webPageImageView?.layer.shadowRadius = 5.0
            webPageImageView?.layer.shadowOpacity = 0.25
            
            if let webPageImageView = webPageImageView {
                addSubview(webPageImageView)
            }
            
        case .Changed:
            webPageImageView?.frame.origin.x = sender.locationInView(sender.view).x
            
        case .Cancelled:
            webPageImageView?.removeFromSuperview()
            
        case .Ended:
            let screenWidth = UIScreen.mainScreen().bounds.size.width
            let velocity = sender.velocityInView(sender.view).x
            let translation = sender.translationInView(sender.view).x
            let finalPoint = screenWidth + translation + velocity * 0.1   // 0.1 is threshold
            
            print("[Debug]: \(translation, velocity, finalPoint)")
            
            UIView.animateWithDuration(
                0.1,
                animations: {
                    self.webPageImageView?.frame.origin.x = finalPoint > screenWidth / 2 ? screenWidth : 0.0
                },
                completion: { _ in
                    self.webPageImageView?.removeFromSuperview()
                    if finalPoint < screenWidth / 2 && self.canGoForward {
                        self.hidden = true
                        self.goForward()
                    }
                    self.isEdgeSwiping = false
                }
            )
            
        default:
            break
        }
    }
}

extension WebView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === leftEdgePanGestureRecognizer && !canGoBack {
            return false
            
        } else if gestureRecognizer === rightEdgePanGestureRecognizer && !canGoForward {
            return false
        }
        
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
}
