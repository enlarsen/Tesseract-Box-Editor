//
//  BoxEditorViewController.swift
//  Tesseract-Box-Editor
//
//  Created by Erik Larsen on 6/6/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

import Foundation
import Cocoa
import QuartzCore

class BoxEditorViewController: NSViewController
{
    @IBOutlet var characterView: CharacterView
    @IBOutlet var mainImageView: ImageView
    @IBOutlet var window: NSWindow
    @IBOutlet var boxesTableView: NSTableView
    @IBOutlet var tableArrayController: NSArrayController

    var selectionLayer: CAShapeLayer!
    var selectionHandleLayers: CAShapeLayer[] = []

    var cropPoint = CGPointZero
    var topHandle = CGPointZero
    var bottomHandle = CGPointZero
    var leftHandle = CGPointZero
    var rightHandle = CGPointZero

    var pagesFromImage: NSBitmapImageRep[] = []
    var currentRepresentation: Int?

    var boxes: Boxes?

    override func awakeFromNib()
    {
        mainImageView.imageScaling = .ImageScaleProportionallyUpOrDown
    }

//    init()
//    {
//        super.init()
//    }
//
//    init(coder: NSCoder!)
//    {
//        super.init()
//    }
//
//    init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!)
//    {
//        super.init()
//    }

    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: NSDictionary!, context: CMutableVoidPointer)
    {
        if tableArrayController.selectedObjects.count > 0
        {
            let box = tableArrayController.selectedObjects[0] as Box
            if box.page != currentRepresentation
            {
                if currentRepresentation < pagesFromImage.count
                {
                    var size = pagesFromImage[box.page].size
                    var image = NSImage(size:size)
                    image.addRepresentation(pagesFromImage[box.page])
                    mainImageView.image = trimImage(image)
                    currentRepresentation = box.page

                }
            }
            updateCharacterView(box)
            removeAnimatedSelection()
            setupAnimatedSelectionWithBox(box)
        }
        else
        {
            removeAnimatedSelection()
        }
    }

    func setupAnimatedSelectionWithBox(box: Box)
    {
        var verticalPadding = 0.0
        var horizontalPadding = 0.0
        var untransformedVerticalPadding = 0.0
        var untransformedHorizontalPadding = 0.0
        var scaleFactor = 1.0
        let horizontalScaleFactor = mainImageView.frame.size.width / mainImageView.image.size.width
        let verticalScaleFactor = mainImageView.frame.size.height / mainImageView.image.size.height

        NSLog("horizontal scale: \(horizontalScaleFactor) vertical scale: \(verticalScaleFactor)")

        if verticalScaleFactor - horizontalScaleFactor < 0
        {
            scaleFactor = verticalScaleFactor

            let width = mainImageView.image.size.width * scaleFactor
            horizontalPadding = (mainImageView.frame.size.width - width) / 2.0
            untransformedHorizontalPadding = (mainImageView.frame.size.width - mainImageView.image.size.width) / 2.0
        }

        if horizontalScaleFactor - verticalScaleFactor < 0
        {
            scaleFactor = horizontalScaleFactor

            let height = mainImageView.image.size.height * scaleFactor
            verticalPadding = (mainImageView.frame.size.height - height) / 2.0
            untransformedVerticalPadding = (mainImageView.frame.size.height - mainImageView.image.size.height) / 2.0

        }

        NSLog("Horizontal padding: \(horizontalPadding), vertical padding: \(verticalPadding)")
        NSLog("Untransformed horizontal padding: \(untransformedHorizontalPadding), untransformed vertical padding: \(untransformedVerticalPadding)")

        selectionLayer = CAShapeLayer()
        selectionLayer.lineWidth = 0.5
        selectionLayer.strokeColor = NSColor.redColor().CGColor
        selectionLayer.fillColor = NSColor(deviceRed: 1.0, green: 1.0, blue: 0.0, alpha: 0.5).CGColor
        selectionLayer.lineDashPattern = [10, 15]
        mainImageView.layer.addSublayer(selectionLayer)

        let dashAnimation = CABasicAnimation(keyPath: "lineDashPhase")
        dashAnimation.fromValue = 0.0
        dashAnimation.toValue = 15.0
        dashAnimation.duration = 10.0
        dashAnimation.repeatCount = 10000 /* HUGE_VALF undefined */
        selectionLayer.addAnimation(dashAnimation, forKey: "linePhase")

        var transform = CATransform3DIdentity
        transform = CATransform3DTranslate(transform, horizontalPadding, verticalPadding, 0.0)
        transform = CATransform3DScale(transform, scaleFactor, scaleFactor, 1.0)
        transform = CATransform3DTranslate(transform, cropPoint.x, cropPoint.y, 0.0)

        let left = CGFloat(box.x)
        let bottom = CGFloat(box.y)
        let right = CGFloat(box.x + box.width)
        let top = CGFloat(box.y + box.height)

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
        NSLog("Left handle transformed: %@", NSStringFromPoint(CGPointApplyAffineTransform(leftHandle, CATransform3DGetAffineTransform(transform))))

        drawHandle(leftHandle)
        drawHandle(rightHandle)
        drawHandle(topHandle)
        drawHandle(bottomHandle)

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

        mainImageView.layer.addSublayer(layer)

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

    @IBAction func openMenu(sender: NSMenuItem)
    {

        let openPanel = NSOpenPanel()
        openPanel.allowedFileTypes = ["tiff", "tif", "TIFF", "TIF", "jpg", "jpeg", "JPG", "JPEG"]
        openPanel.canSelectHiddenExtension = true

        openPanel.beginSheetModalForWindow(window, completionHandler: {result in
            if result == NSFileHandlingPanelOKButton
            {
                let url = openPanel.URL
                let boxUrl = url.URLByDeletingPathExtension.URLByAppendingPathExtension("box")
                let imageFromFile = NSImage(byReferencingURL: url)
                self.pagesFromImage = imageFromFile.representations as NSBitmapImageRep[]
                self.mainImageView.image = self.trimImage(imageFromFile)
                self.boxes = Boxes(file: boxUrl.path)
                self.currentRepresentation = 0
            }
        })

    }

    func trimImage(image: NSImage) -> NSImage
    {
        let imageRef = image.CGImageForProposedRect(nil, context: nil, hints: nil).takeUnretainedValue()
        let width = CGImageGetWidth(imageRef)
        let height = CGImageGetHeight(imageRef)
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let bytesPerPixel: UInt = 4
        let bytesPerComponent: UInt = 8
        let rawData = calloc(height * width * bytesPerPixel, 1)
        let pointer = UnsafePointer<UInt8>(rawData)
        let bytesPerRow = bytesPerPixel * width


        let bitmapInfo = CGBitmapInfo.fromRaw(CGImageAlphaInfo.PremultipliedLast.toRaw() | CGBitmapInfo.ByteOrder32Big.toRaw())!


        let context = CGBitmapContextCreate(rawData, width, height, bytesPerComponent, bytesPerRow, colorSpace, bitmapInfo)


//        CGColorSpaceRelease(colorSpace)
        CGContextDrawImage(context, CGRect(x: 0, y: 0, width: Int(width), height: Int(height)), imageRef)

//        CGContextRelease(context)


        var top = 0
        var left = 0
        var right = 0
        var bottom = 0

        var stop = false

        for var x = 0; x < Int(width); x++
        {
            if stop
            {
                break
            }
            for var y = 0; y < Int(height); y++
            {
                var loc = x + (y * Int(width))
                loc *= 4
                if pointer[loc] != 0xff
                {
                    left = x
                    stop = true
                    break
                }
            }

        }

        stop = false

        for var y = 0; y < Int(height); y++
        {
            if stop
            {
                break
            }

            for var x = 0; x < Int(width); x++
            {
                var loc = x + (y * Int(width))
                loc *= 4
                if pointer[loc] != 0xff
                {
                    top = y
                    stop = true
                    break
                }
            }
        }

        stop = false

        for var y = Int(height) - 1; y >= 0; y--
        {
            if stop
            {
                break
            }

            for var x = Int(width) - 1; x >= 0; x--
            {
                var loc = x + (y * Int(width))
                loc *= 4
                if pointer[loc] != 0xff
                {
                    bottom = y
                    stop = true
                    break
                }
            }
        }

        stop = false

        for var x = Int(width) - 1; x >= 0; x--
        {
            if stop
            {
                break
            }

            for var y = Int(height) - 1; y >= 0; y--
            {
                var loc = x + (y * Int(width))
                loc *= 4
                if pointer[loc] != 0xff
                {
                    right = x
                    stop = true
                    break
                }
            }
        }


        let cropRect = NSRect(x: left - 5, y: Int(height) - bottom - 6, width: right - left + 10, height: bottom - top + 10)
        let target = NSImage(size: cropRect.size)
        target.lockFocus()

        image.drawInRect(NSRect(x: 0, y: 0, width: cropRect.size.width, height: cropRect.size.height), fromRect: cropRect, operation: .CompositeCopy, fraction: 1.0)
        target.unlockFocus()

        free(rawData)

        image.lockFocus()
        let bitmapRep = NSBitmapImageRep(focusedViewRect: cropRect)
        image.unlockFocus()


        let croppedImage = NSImage(data: bitmapRep.representationUsingType(.NSPNGFileType, properties: nil))
        cropPoint = NSPoint(x: left - 5, y: Int(height) - bottom - 6)
        return croppedImage


    }

    func updateCharacterView(box: Box)
    {
        let image = NSImage(data: pagesFromImage[box.page].representationUsingType(.NSPNGFileType, properties: nil))
        image.lockFocus()
        let bitmapRep = NSBitmapImageRep(focusedViewRect: NSRect(x: box.x - 5, y: box.y - 5,
            width: box.width + 10, height: box.height + 10))
        image.unlockFocus()

        let croppedImage = NSImage(data: bitmapRep.representationUsingType(.NSPNGFileType, properties: nil))
        characterView.updateCharacter(croppedImage, withCropPoint: NSPoint(x: box.x - 5, y: box.y - 5), andCharacterRect: box.boxToNSRect())
    }


}