//
//  SingleImageViewController.swift
//  LionScreenshot
//
//  Created by hcy on 2017/3/31.
//  Copyright © 2017年 hongcaiyu. All rights reserved.
//

import UIKit

class SingleImageViewController: UIViewController, UIScrollViewDelegate{
    
    private var image: UIImage?
    private var imageView: UIImageView!
    
    init(image: UIImage?){
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Image"
        self.view.backgroundColor = UIColor.white
        
        if let image = self.image {
            self.imageView = UIImageView(frame: CGRect(x: 0, y: 64,
                                                       width: self.view.frame.size.width,
                                                       height: self.view.frame.size.height - 64))
            self.imageView.contentMode = .scaleAspectFit
            self.imageView.image = image
            self.view.addSubview(imageView)
        }
    }

}
