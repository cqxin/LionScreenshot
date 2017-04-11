//
//  WebViewController.swift
//  LionScreenshot
//
//  Created by hcy on 2017/4/5.
//  Copyright © 2017年 hongcaiyu. All rights reserved.
//

import UIKit
import LionScreenshot

class WebViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    private var screenShot: LionScreenshot!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = Bundle.main.url(forResource: "Apple", withExtension: "webarchive")!
        
        self.webView.loadRequest(URLRequest(url: url))
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.screenShot = LionScreenshot(view: self.webView)
        
        let layer = self.screenShot.layer
        layer.frame = CGRect(x: 10, y: 74, width: 90, height: 160)
        self.view.layer.addSublayer(layer)
        self.screenShot.begin()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.screenShot?.begin()
    }
    
    @IBAction func shot(_ sender: UIBarButtonItem) {
        if let image = self.screenShot?.end(){
            self.navigationController?.pushViewController(SingleImageViewController(image: image), animated: true)
        }
    }

}
