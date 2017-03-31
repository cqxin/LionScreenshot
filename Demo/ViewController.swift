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
    
    private struct ColorValue{
        let red:    CGFloat
        let green:  CGFloat
        let blue:   CGFloat
    }

    @IBOutlet weak var tableView: UITableView!
    private var colorValues = [ColorValue]()
    private var screenShot: LionScreenshot!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 1...100 {
            self.colorValues.append(ColorValue(red:   CGFloat(arc4random()) / CGFloat(UInt32.max),
                                          green: CGFloat(arc4random()) / CGFloat(UInt32.max),
                                          blue:  CGFloat(arc4random()) / CGFloat(UInt32.max)))
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
        return self.colorValues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ColorCell", for: indexPath)
        let colorValue = self.colorValues[indexPath.row]
        cell.backgroundColor = UIColor(red:     colorValue.red,
                                       green:   colorValue.green,
                                       blue:    colorValue.blue,
                                       alpha:   1)
        cell.textLabel?.text = "\(indexPath.row)"
        let negativeColorValue = self.negativeColorValue(value: colorValue)
        cell.textLabel?.textColor = UIColor(red:    negativeColorValue.red,
                                            green:  negativeColorValue.green,
                                            blue:   negativeColorValue.blue,
                                            alpha:  1)
        return cell
    }
    
    private func negativeColorValue(value: ColorValue) -> ColorValue {
        return ColorValue(red: 1.0 - value.red, green: 1.0 - value.green, blue: 1.0 - value.blue)
    }

}

