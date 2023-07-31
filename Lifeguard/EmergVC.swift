//
//  EmergVC.swift
//  Lifeguard
//
//  Created by jim kardach on 4/28/21.
//  Copyright © 2021 Forkbeardlabs. All rights reserved.
//

import UIKit
import WebKit

class EmergVC: UIViewController, WKUIDelegate {
    var url: String = ""
    var webView: WKWebView!
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Emergency Action Plan"
        let myURL = URL(string:"https://sites.google.com/view/ssclifeguards/emergency-action-plan?authuser=1")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }

}
