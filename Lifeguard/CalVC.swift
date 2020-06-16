//
//  CalVC.swift
//  Lifeguard
//
//  Created by jim kardach on 6/27/19.
//  Copyright © 2019 Forkbeardlabs. All rights reserved.
//

import UIKit
import WebKit

class CalVC: UIViewController, WKUIDelegate  {

    var webView: WKWebView!
    
    override func loadView() {
        self.title = "uiwebCalendar"
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myURL = URL(string:"https://calendar.google.com/calendar/b/1?cid=c3NjbGlmZWd1YXJkQGdtYWlsLmNvbQ")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
}
