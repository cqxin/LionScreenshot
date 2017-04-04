//
//  LionScreenshot.swift
//  LionScreenshot
//
//  Created by hcy on 2017/3/28.
//  Copyright © 2017年 hongcaiyu. All rights reserved.
//

import UIKit

public class LionScreenshot: NSObject {
    
    private struct ShotImageInfo{
        let origin: CGPoint
        let image: UIImage
    }
    
    /// 预览截图的层
    private var previewLayer: CALayer?
    
    /// 被处理的视图
    private let processView: UIView
    
    /// 存放截出图片信息的数组
    private var shotImageInfos = [ShotImageInfo]()
    
    private var minPoint = CGPoint.zero
    private var maxPoint = CGPoint.zero
    private var lastPoint = CGPoint.zero
    
    private var horizontalScrollIndicatorStatus: Bool = true
    private var verticalScrollIndicatorStatus: Bool = true
    
    /// 如果是图只是单个方向的滚动最好将此设为false效率较高，如果是有多个方向的滚动请将此设为true才能完整的截图！
    public var repetition: Bool
    
    public var layer: CALayer{
        get{
            if let layer = self.previewLayer{
                return layer
            }else{
                let layer = CALayer()
                layer.contentsGravity = kCAGravityResizeAspect
                layer.shadowOpacity = 0.382
                layer.shadowOffset = CGSize.zero
                self.previewLayer = layer
                if !self.shotImageInfos.isEmpty {
                    layer.contents = self.renderWholeImage()?.cgImage
                }
                return layer
            }
        }
    }

    
    public init(view: UIView) {    
        if let webView = view as? UIWebView{
            self.processView = webView.scrollView
            self.repetition = true
        }else{
            self.processView = view
            self.repetition = false
        }
    }
    
    public func begin() {
        
        if self.shotImageInfos.isEmpty {
            if let scrollView = self.processView as? UIScrollView{
                self.horizontalScrollIndicatorStatus = scrollView.showsHorizontalScrollIndicator
                self.verticalScrollIndicatorStatus = scrollView.showsVerticalScrollIndicator
                scrollView.showsVerticalScrollIndicator = false
                scrollView.showsHorizontalScrollIndicator = false
                scrollView.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
            }
        }else{
            self.shotImageInfos.removeAll()
            self.previewLayer?.contents = nil
        }
        
        let layerOrigin = self.processView.layer.bounds.origin
        let layerSize = self.processView.layer.bounds.size
        self.minPoint = layerOrigin
        self.maxPoint = layerOrigin
        self.lastPoint = layerOrigin
        
        let offset = CGPoint(x: -layerOrigin.x, y: -layerOrigin.y)
        
        if let shotImage = self.screenshotFormProcessView(offset: offset, size: layerSize) {
            self.appendImageInfo(info: ShotImageInfo(origin: layerOrigin, image: shotImage))
        }
        
    }
    
    public func end() -> UIImage? {
        
        

        if self.shotImageInfos.isEmpty {
            return nil
        }else{
            if let scrollView = self.processView as? UIScrollView{
                scrollView.showsHorizontalScrollIndicator = self.horizontalScrollIndicatorStatus
                scrollView.showsVerticalScrollIndicator = self.verticalScrollIndicatorStatus
                scrollView.removeObserver(self, forKeyPath: "contentOffset")
            }
            let image = self.renderWholeImage()
            self.shotImageInfos.removeAll()
            self.previewLayer?.contents = nil
            return image
        }
    }


    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            
            let layerPoint = self.processView.layer.bounds.origin
            let layerSize = self.processView.layer.bounds.size
            var offset = CGPoint.zero
            var size = CGSize.zero
            
            let compareMinX: CGFloat
            let compareMaxX: CGFloat
            let compareMinY: CGFloat
            let compareMaxY: CGFloat
            
            if self.repetition {
                compareMinY = self.lastPoint.y
                compareMaxY = self.lastPoint.y
                compareMinX = self.lastPoint.x
                compareMaxX = self.lastPoint.x
            }else{
                compareMinY = self.minPoint.y
                compareMaxY = self.maxPoint.y
                compareMinX = self.minPoint.x
                compareMaxX = self.maxPoint.x
            }
            
            if layerPoint.x < compareMinX {
                let width = compareMinX - layerPoint.x
                size = CGSize(width: width, height: layerSize.height)
                offset = CGPoint(x: -layerPoint.x, y: -layerPoint.y)
            }else if layerPoint.x > compareMaxX {
                let width = layerPoint.x - compareMaxX
                size = CGSize(width: width, height: layerSize.height)
                offset = CGPoint(x: -(layerPoint.x + layerSize.width - width), y: -layerPoint.y)
            }
            if size != CGSize.zero {
                if let shotImage = self.screenshotFormProcessView(offset: offset, size: size) {
                    let origin = CGPoint(x: -offset.x, y: -offset.y)
                    self.appendImageInfo(info: ShotImageInfo(origin: origin, image: shotImage))
                }
            }
            
            size = CGSize.zero
            
            if layerPoint.y < compareMinY {
                let height = compareMinY - layerPoint.y
                size = CGSize(width: layerSize.width, height: height)
                offset = CGPoint(x: -layerPoint.x, y: -layerPoint.y)
                
            }else if layerPoint.y > compareMaxY {
                let height = layerPoint.y - compareMaxY
                size = CGSize(width: layerSize.width, height: height)
                offset = CGPoint(x: -layerPoint.x, y: -(layerPoint.y + layerSize.height - height))
                
            }
            if size != CGSize.zero {
                if let shotImage = self.screenshotFormProcessView(offset: offset, size: size) {
                    let origin = CGPoint(x: -offset.x, y: -offset.y)
                    self.appendImageInfo(info: ShotImageInfo(origin: origin, image: shotImage))
                    
                }
            }
            
            if layerPoint.x < self.minPoint.x {
                self.minPoint.x = layerPoint.x
            }else if layerPoint.x > self.maxPoint.x {
                self.maxPoint.x = layerPoint.x
            }
            
            if layerPoint.y < self.minPoint.y {
                minPoint.y = layerPoint.y
            }else if layerPoint.y > self.maxPoint.y {
                maxPoint.y = layerPoint.y
            }
            self.lastPoint = layerPoint
        }
    }
    
    private func appendImageInfo(info: ShotImageInfo){
        self.shotImageInfos.append(info)
        if let previewLayer = self.previewLayer{
            previewLayer.contents = self.renderWholeImage()?.cgImage
        }
    }
    
    private func renderWholeImage() -> UIImage?{
        let layerSize = self.processView.layer.bounds.size
        let contextSize = CGSize(width:    maxPoint.x - minPoint.x + layerSize.width,
                                 height:   maxPoint.y - minPoint.y + layerSize.height)
        
        UIGraphicsBeginImageContextWithOptions(contextSize, false, UIScreen.main.scale)
        
        if let context = UIGraphicsGetCurrentContext(){
            context.translateBy(x: -minPoint.x, y: -minPoint.y)
            for info in self.shotImageInfos{
                info.image.draw(at: info.origin)
            }
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }else{
            UIGraphicsEndImageContext()
            return nil
        }
    }
    
    
    private func screenshotFormProcessView(offset: CGPoint, size: CGSize) -> UIImage?{
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            context.translateBy(x: offset.x, y: offset.y)
            self.processView.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }else{
            UIGraphicsEndImageContext()
            return nil
        }
    }

}
