//
//  CharacterView.swift
//  Tesseract-Box-Editor
//
//  Created by Erik Larsen on 6/4/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

import Cocoa
import QuartzCore

class CharacterView: NSImageView
{

    var width: CGFloat = 0.0
/*    {
        return image.size.width
    } */

    var height:CGFloat = 0.0
/*    {
        return image.size.width
    } */
    var selectionHandleLayers: Array<CAShapeLayer> = []
    var selectionLayer: CAShapeLayer!
    var startPoint = CGPointZero
    var cropPoint = CGPointZero
    var scaleFactor = 1.0
    var box: NSRect?
    var leftHandle: NSPoint?
    var rightHandle: NSPoint?
    var topHandle: NSPoint?
    var bottomHandle: NSPoint?


    override func awakeFromNib()
    {
        imageScaling = .ImageScaleProportionallyUpOrDown

    }

    func updateCharacter(image: NSImage, withCropPoint cropPoint: NSPoint, andCharacterRect box: NSRect)
    {
        self.image = image

        self.cropPoint = cropPoint

        self.box = box
        removeAnimatedSelection()
        setupAnimatedSelectionWithRect(self.box!)

        NSLog("image size: %@", NSStringFromSize(image.size));
        NSLog("characterView frame: %@", NSStringFromRect(self.frame));
        NSLog("crop point: %@", NSStringFromPoint(cropPoint));

        width = image.size.width
        height = image.size.height

    }

    /* TODO: rename box to something else, rect, eg */

    func setupAnimatedSelectionWithRect(box: NSRect)
    {
        var verticalPadding = 0.0
        var horizontalPadding = 0.0
        var untransformedVerticalPadding = 0.0
        var untransformedHorizontalPadding = 0.0
        scaleFactor = 1.0
        let horizontalScaleFactor = frame.size.width / image.size.width
        let verticalScaleFactor = frame.size.height / image.size.height

        NSLog("horizontal scale: \(horizontalScaleFactor) vertical scale: \(verticalScaleFactor)")

        if verticalScaleFactor - horizontalScaleFactor < 0
        {
            scaleFactor = verticalScaleFactor

            let width = image.size.width * scaleFactor
            horizontalPadding = (frame.size.width - width) / 2.0
            untransformedHorizontalPadding = (frame.size.width - image.size.width) / 2.0
        }

        if horizontalScaleFactor - verticalScaleFactor < 0
        {
            scaleFactor = horizontalScaleFactor

            let height = image.size.height * scaleFactor
            verticalPadding = (frame.size.height - height) / 2.0
            untransformedVerticalPadding = (frame.size.height - image.size.height) / 2.0

        }

        NSLog("Horizontal padding: \(horizontalPadding), vertical padding: \(verticalPadding)")
        NSLog("Untransformed horizontal padding: \(untransformedHorizontalPadding), untransformed vertical padding: \(untransformedVerticalPadding)")

        selectionLayer = CAShapeLayer()
        selectionLayer.lineWidth = 0.2
        selectionLayer.strokeColor = NSColor.grayColor().CGColor
        selectionLayer.fillColor = NSColor.clearColor().CGColor
        selectionLayer.lineDashPattern = [1, 1]
        layer.addSublayer(selectionLayer)

        let dashAnimation = CABasicAnimation(keyPath: "lineDashPhase")
        dashAnimation.fromValue = 0.0
        dashAnimation.toValue = 15.0
        dashAnimation.duration = 10.0
        dashAnimation.repeatCount = 10000 /* HUGE_VALF */
        selectionLayer.addAnimation(dashAnimation, forKey: "linePhase")

        var transform = CATransform3DIdentity
        transform = CATransform3DTranslate(transform, horizontalPadding, verticalPadding, 0.0)
        transform = CATransform3DScale(transform, scaleFactor, scaleFactor, 1.0)
        transform = CATransform3DTranslate(transform, -cropPoint.x, -cropPoint.y, 0.0)

        let left = box.origin.x
        let bottom = box.origin.y
        let right = box.origin.x + box.size.width
        let top = box.origin.y + box.size.height

        NSLog("Cropped point: \(cropPoint)")

        leftHandle = NSPoint(x: left, y: bottom + (top - bottom) / 2.0)
        rightHandle = NSPoint(x: right, y: bottom + (top - bottom) / 2.0)
        topHandle = NSPoint(x: left + (right - left) / 2.0, y: top)
        bottomHandle = NSPoint(x: (left + (right - left) / 2.0), y: bottom)

        NSLog("Left handle: \(leftHandle)")
        NSLog("Right handle: \(rightHandle)")
        NSLog("Top handle: \(topHandle)")
        NSLog("Bottom Handle: \(bottomHandle)")

        selectionLayer.transform = transform
        NSLog("Transformation: \(transform.m11) \(transform.m22) \(transform.m41) \(transform.m42)")
        NSLog("Left handle transformed: %@", NSStringFromPoint(CGPointApplyAffineTransform(leftHandle!, CATransform3DGetAffineTransform(transform))))

        drawHandle(leftHandle!)
        drawHandle(rightHandle!)
        drawHandle(topHandle!)
        drawHandle(bottomHandle!)

        let path = CGPathCreateMutable()

        CGPathMoveToPoint(path, nil, left, bottom)
        CGPathAddLineToPoint(path, nil, left, top)
        CGPathAddLineToPoint(path, nil, right, top)
        CGPathAddLineToPoint(path, nil, right, bottom)
        CGPathCloseSubpath(path)

        selectionLayer.path = path

        return
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

        self.layer.addSublayer(layer)

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

    override func mouseDown(theEvent: NSEvent!)
    {
        let point = convertPoint(theEvent.locationInWindow, fromView: nil)
        var transform = CGAffineTransformInvert(CATransform3DGetAffineTransform(selectionLayer.transform))

        for layer in selectionHandleLayers
        {
            if CGPathContainsPoint(layer.path, &transform, point, false)
            {
                self.startPoint = CGPointApplyAffineTransform(point, transform)
            }

        }
    }

    override func mouseUp(theEvent: NSEvent!)
    {
        startPoint = CGPointZero
    }

    override func mouseDragged(theEvent: NSEvent!)
    {
        let point = convertPoint(theEvent.locationInWindow, fromView: nil)
        var transform = CGAffineTransformInvert(CATransform3DGetAffineTransform(selectionLayer.transform))

        for layer in selectionHandleLayers
        {
            if CGPathContainsPoint(layer.path, &transform, point, false)
            {
                NSLog("Found handle")
            }

        }

    }

}