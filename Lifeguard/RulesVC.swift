//
//  RulesVC.swift
//  Lifeguard
//
//  Created by jim kardach on 6/26/19.
//  Copyright © 2019 Forkbeardlabs. All rights reserved.
//

import UIKit
import WebKit

class RulesVC: UIViewController, WKUIDelegate {

    var webView: WKWebView!
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Rules"
        let myURL = URL(string:"https://sites.google.com/site/saratogaswimclub/pool-rules")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }

}
