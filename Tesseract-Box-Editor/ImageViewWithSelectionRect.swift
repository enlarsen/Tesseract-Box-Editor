//
//  ImageViewWithSelectionRect.swift
//  Tesseract-Box-Editor
//
//  Created by Erik Larsen on 6/8/14.
//
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
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
    var selectionHandleLayers: [CAShapeLayer] = []
    var drawSelectionHandles = false

    var cropPoint = CGPointZero

    var selectionRect = NSZeroRect
    var strokeColor = NSColor.blackColor().CGColor
    var fillColor = NSColor.clearColor().CGColor
    var lineDashPattern = [10, 15]
    var duration = 0.75
    var numberHandles = 4

    func setupAnimatedSelectionRect(rect: NSRect)
    {

        selectionLayer = createAnimationLayer()
        layer!.addSublayer(selectionLayer)

        selectionLayer.addAnimation(createAnimation(), forKey: "linePhase")


        selectionLayer.transform = createTransform(self.cropPoint)

//        NSLog("Cropped point: \(cropPoint)")

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
        let shapeLayer = CAShapeLayer()
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
        dashAnimation.repeatCount = HUGE

        return dashAnimation
    }


    func createTransform(cropPoint: NSPoint) -> CATransform3D
    {
        var verticalPadding: CGFloat = 0.0
        var horizontalPadding: CGFloat = 0.0
        var scaleFactor: CGFloat = 1.0
        let horizontalScaleFactor = frame.size.width / image!.size.width
        let verticalScaleFactor = frame.size.height / image!.size.height

//        NSLog("horizontal scale: \(horizontalScaleFactor) vertical scale: \(verticalScaleFactor)")

        if verticalScaleFactor - horizontalScaleFactor < 0
        {
            scaleFactor = verticalScaleFactor

            let width = image!.size.width * scaleFactor
            horizontalPadding = (frame.size.width - width) / 2.0
        }
        else
        {
            scaleFactor = horizontalScaleFactor

            let height = image!.size.height * scaleFactor
            verticalPadding = (frame.size.height - height) / 2.0
        }

//        NSLog("Horizontal padding: \(horizontalPadding), vertical padding: \(verticalPadding)")

        var transform = CATransform3DIdentity
        transform = CATransform3DTranslate(transform, horizontalPadding, verticalPadding, 0.0)
        transform = CATransform3DScale(transform, scaleFactor, scaleFactor, 1.0)
        transform = CATransform3DTranslate(transform, -cropPoint.x, -cropPoint.y, 0.0)

//        NSLog("Transformation: \(transform.m11) \(transform.m22) \(transform.m41) \(transform.m42)")

        return transform
    }

    func drawHandles(rect: NSRect)
    {
        var handles: [NSPoint] = []


        let left = CGFloat(rect.origin.x)
        let bottom = CGFloat(rect.origin.y)
        let right = CGFloat(rect.origin.x + rect.size.width)
        let top = CGFloat(rect.origin.y + rect.size.height)

        handles.append(NSPoint(x: left, y: bottom + (top - bottom) / 2.0))  // left
        handles.append(NSPoint(x: right, y: bottom + (top - bottom) / 2.0)) // right
        handles.append(NSPoint(x: left + (right - left) / 2.0, y: top)) // top
        handles.append(NSPoint(x: (left + (right - left) / 2.0), y: bottom)) // bottom

        if selectionHandleLayers.count == 0 {
            setupSelectionHandleLayers()
        }
        
        for i in 0 ..< handles.count {
            drawHandle(handles[i], layer: selectionHandleLayers[i])
        }

    }

    func drawHandle(point: NSPoint, layer: CAShapeLayer)
    {
        let size: CGFloat = 0.5
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
        for _ in 0 ..< numberHandles {
            let layer = CAShapeLayer()
            layer.lineWidth = 0.1
            layer.strokeColor = NSColor.blueColor().CGColor
            layer.fillColor = NSColor.blueColor().CGColor
            layer.transform = selectionLayer.transform

            selectionHandleLayers.append(layer)
            self.layer!.addSublayer(layer)
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
        var left = Int(selectionRect.origin.x)
        var right = Int(selectionRect.origin.x + selectionRect.size.width)
        var top = Int(selectionRect.origin.y + selectionRect.size.height)
        var bottom = Int(selectionRect.origin.y)

        switch index
        {
            case 0:
                left = Int(dragPoint.x)
            case 1:
                right = Int(dragPoint.x)
            case 2:
                top = Int(dragPoint.y)
            default:
                bottom = Int(dragPoint.y)
        }

        return NSRect(x: left, y: bottom, width: right - left, height: top - bottom)
    }

    // Coordinates are inverted in this function. (0, 0) is the upper left and y increases down
    func trimImage(image: NSImage)
    {
        let imageRef = image.CGImageForProposedRect(nil, context: nil, hints: nil)
        let width = CGImageGetWidth(imageRef)
        let height = CGImageGetHeight(imageRef)
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let bytesPerPixel: Int = 4
        let bytesPerComponent: Int = 8
        let rawData = calloc(height * width * bytesPerPixel, 1)
        let pointer = UnsafePointer<UInt8>(rawData)
        let bytesPerRow = bytesPerPixel * width
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue | CGBitmapInfo.ByteOrder32Big.rawValue)
        let context = CGBitmapContextCreate(rawData, width, height, bytesPerComponent, bytesPerRow, colorSpace, bitmapInfo.rawValue)

        CGContextDrawImage(context, CGRect(x: 0, y: 0, width: Int(width), height: Int(height)), imageRef)

        var top = 0
        var left = 0
        var right = Int(width)
        var bottom = Int(height)

        for x in 0 ..< Int(width) {
            if scanColumn(x, height: Int(height), width: Int(width), pointer: pointer) {
                left = x
                break
            }
        }
		let xend = Int(width) - 1
        for x in (0 ... xend).reverse() {
            if scanColumn(x, height: Int(height), width: Int(width), pointer: pointer) {
                right = x
                break
            }
        }

        for y  in 0 ..< Int(height) {
            if scanRow(y, width: Int(width), pointer: pointer) {
                top = y
                break
            }
        }
		let yend = Int(height) - 1
        for y in (0 ... yend).reverse() {
            if scanRow(y, width: Int(width), pointer: pointer) {
                bottom = y
                break
            }
        }


        // Flip the coordinates to be Mac coordinates and add a border around the cropped image
        let cropRect = NSRect(x: left - 5, y: Int(height) - bottom - 6, width: right - left + 10, height: bottom - top + 10)

        free(rawData)

        image.lockFocus()
        let bitmapRep = NSBitmapImageRep(focusedViewRect: cropRect)
        image.unlockFocus()

        let croppedImage = NSImage(data: bitmapRep!.representationUsingType(.NSPNGFileType, properties: [:])!)
        cropPoint = cropRect.origin
        self.image = croppedImage
    }

    func scanRow(y: Int, width:Int, pointer: UnsafePointer<UInt8>) -> Bool
    {
        for x in 0 ..< width {
			// only check red, could cause trouble
            if pointer[(x + y * width) * 4] != 0xff {
                return true
            }
        }
        return false
    }

    func scanColumn(x: Int, height: Int, width: Int, pointer: UnsafePointer<UInt8>) -> Bool
    {
        for y in 0 ..< height {
			// only check red
            if pointer[(x + y * width) * 4] != 0xff {
                return true
            }
        }
        return false
    }
}
