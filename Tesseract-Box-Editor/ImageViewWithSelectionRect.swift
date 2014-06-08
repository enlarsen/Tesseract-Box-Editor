//
//  ImageViewWithSelectionRect.swift
//  Tesseract-Box-Editor
//
//  Created by Erik Larsen on 6/8/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

import Foundation
import Cocoa
import QuartzCore

// Base class for CharacterView and ImageView

class ImageViewWithSelectionRect: NSImageView
{
    var selectionLayer: CAShapeLayer!
    var selectionHandleLayers: CAShapeLayer[] = []
    var drawSelectionHandles = false

    var leftHandle = NSZeroPoint
    var rightHandle = NSZeroPoint
    var topHandle = NSZeroPoint
    var bottomHandle = NSZeroPoint

    var selectionRect = NSZeroRect
    var strokeColor = NSColor.blackColor().CGColor
    var fillColor = NSColor.clearColor().CGColor
    var lineDashPattern = [10, 15]

    init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
    }

    func setupAnimatedSelectionRect(rect: NSRect, cropPoint: NSPoint)
    {

        selectionLayer = createAnimationLayer()
        layer.addSublayer(selectionLayer)

        selectionLayer.addAnimation(createAnimation(), forKey: "linePhase")


        selectionLayer.transform = createTransform(cropPoint)

        NSLog("Cropped point: \(cropPoint)")
        computeHandles(rect)

        if drawSelectionHandles
        {
            drawHandle(leftHandle)
            drawHandle(rightHandle)
            drawHandle(topHandle)
            drawHandle(bottomHandle)
        }

        let path = CGPathCreateMutable()

        CGPathMoveToPoint(path, nil, rect.origin.x, rect.origin.y)
        CGPathAddLineToPoint(path, nil, rect.origin.x, rect.origin.y + rect.size.height)
        CGPathAddLineToPoint(path, nil, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height)
        CGPathAddLineToPoint(path, nil, rect.origin.x + rect.size.width, rect.origin.y)
        CGPathCloseSubpath(path)

        selectionLayer.path = path

        return
    }

    func createAnimationLayer() -> CAShapeLayer
    {
        var shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = 0.5
        shapeLayer.strokeColor = strokeColor
        shapeLayer.fillColor = fillColor
        shapeLayer.lineDashPattern = lineDashPattern

        return shapeLayer
        
    }

    func createAnimation() -> CABasicAnimation
    {
        let dashAnimation = CABasicAnimation(keyPath: "lineDashPhase")
        dashAnimation.fromValue = 0.0
        dashAnimation.toValue = 15.0
        dashAnimation.duration = 0.75
        dashAnimation.cumulative = true
        dashAnimation.repeatCount = 10000 /* HUGE_VALF undefined */

        return dashAnimation
    }


    func createTransform(cropPoint: NSPoint) -> CATransform3D
    {

        var verticalPadding = 0.0
        var horizontalPadding = 0.0
        var scaleFactor = 1.0
        let horizontalScaleFactor = frame.size.width / image.size.width
        let verticalScaleFactor = frame.size.height / image.size.height

        NSLog("horizontal scale: \(horizontalScaleFactor) vertical scale: \(verticalScaleFactor)")

        if verticalScaleFactor - horizontalScaleFactor < 0
        {
            scaleFactor = verticalScaleFactor

            let width = image.size.width * scaleFactor
            horizontalPadding = (frame.size.width - width) / 2.0
        }

        if horizontalScaleFactor - verticalScaleFactor < 0
        {
            scaleFactor = horizontalScaleFactor

            let height = image.size.height * scaleFactor
            verticalPadding = (frame.size.height - height) / 2.0
        }

        NSLog("Horizontal padding: \(horizontalPadding), vertical padding: \(verticalPadding)")

        var transform = CATransform3DIdentity
        transform = CATransform3DTranslate(transform, horizontalPadding, verticalPadding, 0.0)
        transform = CATransform3DScale(transform, scaleFactor, scaleFactor, 1.0)
        transform = CATransform3DTranslate(transform, -cropPoint.x, -cropPoint.y, 0.0)

        NSLog("Transformation: \(transform.m11) \(transform.m22) \(transform.m41) \(transform.m42)")
        NSLog("Left handle transformed: %@", NSStringFromPoint(CGPointApplyAffineTransform(leftHandle, CATransform3DGetAffineTransform(transform))))

        return transform
    }

    func computeHandles(rect: NSRect)
    {
        let left = CGFloat(rect.origin.x)
        let bottom = CGFloat(rect.origin.y)
        let right = CGFloat(rect.origin.x + rect.size.width)
        let top = CGFloat(rect.origin.y + rect.size.height)


        leftHandle = NSPoint(x: left, y: bottom + (top - bottom) / 2.0)
        rightHandle = NSPoint(x: right, y: bottom + (top - bottom) / 2.0)
        topHandle = NSPoint(x: left + (right - left) / 2.0, y: top)
        bottomHandle = NSPoint(x: (left + (right - left) / 2.0), y: bottom)

        NSLog("Left handle: \(leftHandle)")
        NSLog("Right handle: \(rightHandle)")
        NSLog("Top handle: \(topHandle)")
        NSLog("Bottom Handle: \(bottomHandle)")
        

    }

    func drawHandle(point: NSPoint)
    {
        let size = 0.5
        let path = CGPathCreateMutable()

        let layer = CAShapeLayer()
        layer.lineWidth = 0.1
        layer.strokeColor = NSColor.blueColor().CGColor
        layer.fillColor = NSColor.blueColor().CGColor
        layer.transform = selectionLayer.transform

        layer.addSublayer(layer)

        CGPathMoveToPoint(path, nil, point.x - size, point.y - size)
        CGPathAddLineToPoint(path, nil, point.x - size, point.y + size)
        CGPathAddLineToPoint(path, nil, point.x + size, point.y + size)
        CGPathAddLineToPoint(path, nil, point.x + size, point.y - size)
        CGPathCloseSubpath(path)

        layer.path = path

        selectionHandleLayers += layer
        return
    }

    func removeAnimatedSelection()
    {
        selectionLayer?.removeFromSuperlayer()
        for layer in selectionHandleLayers
        {
            layer.removeFromSuperlayer()
        }
        
        selectionHandleLayers.removeAll(keepCapacity: true)
        selectionLayer = nil
        
    }
}
