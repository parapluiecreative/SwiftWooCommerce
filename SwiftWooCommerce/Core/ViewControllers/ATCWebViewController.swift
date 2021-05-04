//
//  ATCWebViewController.swift
//  ATC Core
//
//  Created by Florian Marcu on 1/13/18.
//  Copyright © 2018 Florian Marcu. All rights reserved.
//

import UIKit
import WebKit

class ATCWebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    let url: URL

    init(url: URL, title: String) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
        self.title = title
        webView.uiDelegate = self
        webView.navigationDelegate = self
        hidesBottomBarWhenPushed = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        let guide = view.safeAreaLayoutGuide
//        webView.snp.makeConstraints { (maker) in
//            maker.top.equalTo(self.topLayoutGuide.snp.bottom)
//            maker.left.right.equalTo(view)
//            maker.bottom.equalTo(self.bottomLayoutGuide.snp.top)
////        }
        webView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        webView.leftAnchor.constraint(equalTo: guide.leftAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: guide.rightAnchor).isActive = true
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.title = webView.title
    }
}
