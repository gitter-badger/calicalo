//
//  FAQViewControler.swift
//  Calories In Calories Out
//
//  Created by Ryan Klein on 3/2/17.
//  Copyright © 2017 Base11 Studios. All rights reserved.
//

import UIKit
import WebKit

class FAQViewController: UIViewController, WKUIDelegate {
    
    var webView: WKWebView!
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myURL = URL(string: "https://base11studios.com")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
}
