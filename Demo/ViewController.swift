//
//  ViewController.swift
//  Demo
//
//  Created by hcy on 2017/3/31.
//  Copyright © 2017年 hongcaiyu. All rights reserved.
//

import UIKit
import LionScreenshot

class ViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var coclors = [UIColor]()
    var screenShot: LionScreenshot!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 1...100 {
            self.coclors.append(UIColor(red:   CGFloat(arc4random()) / CGFloat(UInt32.max),
                                        green: CGFloat(arc4random()) / CGFloat(UInt32.max),
                                        blue:  CGFloat(arc4random()) / CGFloat(UInt32.max),
                                        alpha: 1))
        }
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ColorCell")
        self.screenShot = LionScreenshot(view: self.tableView)
        
        let layer = self.screenShot.layer
        layer.frame = CGRect(x: 10, y: 74, width: 90, height: 160)
        self.view.layer.addSublayer(layer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.screenShot.begin()
    }

    @IBAction func shot(_ sender: UIBarButtonItem) {
        if let image = self.screenShot.end(){
            self.navigationController?.pushViewController(SingleImageViewController(image: image), animated: true)
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.coclors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ColorCell", for: indexPath)
        cell.backgroundColor = self.coclors[indexPath.row]
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }

}

