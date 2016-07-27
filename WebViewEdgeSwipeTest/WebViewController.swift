//
//  WebViewController.swift
//  WebViewEdgeSwipeTest
//
//  Created by ruwatana on 2016/05/28.
//  Copyright © 2016年 ruwatana. All rights reserved.
//

import UIKit

final class WebViewController: UIViewController {
    @IBOutlet private weak var webView: WebView!
    
    private weak var delegate: UIGestureRecognizerDelegate?
    
    deinit {
        delegate = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = navigationController?.interactivePopGestureRecognizer?.delegate
        
        let request = NSURLRequest(URL: NSURL(string: "http://www.yahoo.co.jp")!)
        webView.loadRequest(request)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.delegate = delegate
    }
}

extension WebViewController: UIWebViewDelegate {
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        if let webView = webView as? WebView {
            webView.hidden = webView.isEdgeSwiping
        }
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        guard let error = error else {
            return
        }
        
        print("[Error]* \(error)")
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        var message: String?
        switch error.code {
        case -999:
            return
        case -1009:
            message = "インターネット接続がオフラインのようです。"
        default:
            break
        }
        
        if let webView = webView as? WebView {
            webView.hidden = webView.isEdgeSwiping
        }
        
        let alertController = UIAlertController(title: "Error", message: message ?? "\(error)", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
}

extension WebViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === navigationController?.interactivePopGestureRecognizer && webView.canGoBack {
            return false
        }
        return true
    }
}


