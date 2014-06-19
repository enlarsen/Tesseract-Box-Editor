//
//  ImageViewWithSelectionRect.swift
//  Tesseract-Box-Editor
//
//  Created by Erik Larsen on 6/8/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//
//  MIT LICENSE
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation
import Cocoa
import QuartzCore

// Base class for CharacterView and ImageView

class ImageViewWithSelectionRect: NSImageView
{
    var selectionLayer: CAShapeLayer!
    var selectionHandleLayers: CAShapeLayer[] = []
    var drawSelectionHandles = false

//    var leftHandle = NSZeroPoint
//    var rightHandle = NSZeroPoint
//    var topHandle = NSZeroPoint
//    var bottomHandle = NSZeroPoint

    var selectionRect = NSZeroRect
    var strokeColor = NSColor.blackColor().CGColor
    var fillColor = NSColor.clearColor().CGColor
    var lineDashPattern = [10, 15]
    var duration = 0.75
    var numberHandles = 4

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

        if drawSelectionHandles
        {
            drawHandles(rect)
        }

        drawSelectionRect(rect)
        return
    }

    func drawSelectionRect(rect: NSRect)
    {
        let path = CGPathCreateMutable()

        CGPathMoveToPoint(path, nil, rect.origin.x, rect.origin.y)
        CGPathAddLineToPoint(path, nil, rect.origin.x, rect.origin.y + rect.size.height)
        CGPathAddLineToPoint(path, nil, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height)
        CGPathAddLineToPoint(path, nil, rect.origin.x + rect.size.width, rect.origin.y)
        CGPathCloseSubpath(path)

        selectionLayer.path = path
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
        dashAnimation.duration = duration
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
        else
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

        return transform
    }

    func drawHandles(rect: NSRect)
    {
        var handles: NSPoint[] = []


        let left = CGFloat(rect.origin.x)
        let bottom = CGFloat(rect.origin.y)
        let right = CGFloat(rect.origin.x + rect.size.width)
        let top = CGFloat(rect.origin.y + rect.size.height)


        handles += NSPoint(x: left, y: bottom + (top - bottom) / 2.0)  // left
        handles += NSPoint(x: right, y: bottom + (top - bottom) / 2.0) // right
        handles += NSPoint(x: left + (right - left) / 2.0, y: top) // top
        handles += NSPoint(x: (left + (right - left) / 2.0), y: bottom) // bottom

        if selectionHandleLayers.count == 0
        {
            setupSelectionHandleLayers()
        }
        
        for var i = 0; i < handles.count; i++
        {
            drawHandle(handles[i], layer: selectionHandleLayers[i])
        }

    }

    func drawHandle(point: NSPoint, layer: CAShapeLayer)
    {
        let size = 0.5
        let path = CGPathCreateMutable()

        CGPathMoveToPoint(path, nil, point.x - size, point.y - size)
        CGPathAddLineToPoint(path, nil, point.x - size, point.y + size)
        CGPathAddLineToPoint(path, nil, point.x + size, point.y + size)
        CGPathAddLineToPoint(path, nil, point.x + size, point.y - size)
        CGPathCloseSubpath(path)

        layer.path = path

    }

    func setupSelectionHandleLayers()
    {
        for var i = 0; i < numberHandles; i++
        {
            let layer = CAShapeLayer()
            layer.lineWidth = 0.1
            layer.strokeColor = NSColor.blueColor().CGColor
            layer.fillColor = NSColor.blueColor().CGColor
            layer.transform = selectionLayer.transform

            selectionHandleLayers += layer
            self.layer.addSublayer(layer)


        }
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

    func computeResizedSelectionRectangle(index: Int, dragPoint: NSPoint) -> NSRect
    {
        var left = selectionRect.origin.x
        var right = selectionRect.origin.x + selectionRect.size.width
        var top = selectionRect.origin.y + selectionRect.size.height
        var bottom = selectionRect.origin.y

        switch index
        {
            case 0:
                left = dragPoint.x
            case 1:
                right = dragPoint.x
            case 2:
                top = dragPoint.y
            default:
                bottom = dragPoint.y
        }

        return NSRect(x: left, y: bottom, width: right - left, height: top - bottom)
    }
}
