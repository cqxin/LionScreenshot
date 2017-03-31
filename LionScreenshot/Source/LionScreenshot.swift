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
    
    private var previewLayer: CALayer?
    
    private let processView: UIView

    private var shotImageInfos = [ShotImageInfo]()
    
    private var minPoint = CGPoint.zero
    private var maxPoint = CGPoint.zero
    
    private var originPoint: CGPoint
    
    
    
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
    
    public init(view: UIScrollView) {
        self.processView = view
        self.originPoint = self.processView.layer.bounds.origin
    }
    
    public func begin() {
        
        if self.shotImageInfos.isEmpty {
            self.processView.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
        }else{
            self.shotImageInfos.removeAll()
            self.previewLayer?.contents = nil
        }

        let layerPoint = self.processView.layer.bounds.origin
        let layerSize = self.processView.layer.bounds.size
        self.minPoint = layerPoint
        self.maxPoint = layerPoint
        
        let offset = CGPoint(x: -layerPoint.x, y: -layerPoint.y)
        
        if let shotImage = self.screenshotFormLayer(offset: offset, size: layerSize) {
            self.appendImageInfo(info: ShotImageInfo(origin: layerPoint, image: shotImage))
        }
        
    }
    
    public func end() -> UIImage? {
        
        if self.shotImageInfos.isEmpty {
            return nil
        }else{
            let image = self.renderWholeImage()
            self.shotImageInfos.removeAll()
            self.processView.removeObserver(self, forKeyPath: "contentOffset")
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
            
            if layerPoint.x < self.minPoint.x {
                let width = self.minPoint.x - layerPoint.x
                size = CGSize(width: width, height: layerSize.height)
                offset = CGPoint(x: -layerPoint.x, y: -layerPoint.y)
                self.minPoint.x = layerPoint.x
            }else if layerPoint.x > self.maxPoint.x {
                let width = layerPoint.x - self.maxPoint.x
                size = CGSize(width: width, height: layerSize.height)
                offset = CGPoint(x: -(layerPoint.x + layerSize.width - width), y: -layerPoint.y)
                self.maxPoint.x = layerPoint.x
            }
            if size != CGSize.zero {
                if let shotImage = self.screenshotFormLayer(offset: offset, size: size) {
                    let origin = CGPoint(x: -offset.x, y: -offset.y)
                    self.appendImageInfo(info: ShotImageInfo(origin: origin, image: shotImage))
                    
                }
            }
            
            size = CGSize.zero
            
            if layerPoint.y < self.minPoint.y {
                let height = self.minPoint.y - layerPoint.y
                size = CGSize(width: layerSize.width, height: height)
                offset = CGPoint(x: -layerPoint.x, y: -layerPoint.y)
                minPoint.y = layerPoint.y
            }else if layerPoint.y > self.maxPoint.y {
                let height = layerPoint.y - maxPoint.y
                size = CGSize(width: layerSize.width, height: height)
                offset = CGPoint(x: -layerPoint.x, y: -(layerPoint.y + layerSize.height - height))
                maxPoint.y = layerPoint.y
            }
            if size != CGSize.zero {
                if let shotImage = self.screenshotFormLayer(offset: offset, size: size) {
                    let origin = CGPoint(x: -offset.x, y: -offset.y)
                    self.appendImageInfo(info: ShotImageInfo(origin: origin, image: shotImage))
                    
                }
            }
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
    
    
    private func screenshotFormLayer(offset: CGPoint, size: CGSize) -> UIImage?{
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
