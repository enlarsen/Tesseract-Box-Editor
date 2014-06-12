//
//  CharacterView.swift
//  Tesseract-Box-Editor
//
//  Created by Erik Larsen on 6/4/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

import Cocoa
import QuartzCore

class CharacterView: ImageViewWithSelectionRect
{

    var width: CGFloat = 0.0
    var height:CGFloat = 0.0
    var startPointIndex = -1
    var cropPoint = NSZeroPoint
    var scaleFactor = 1.0

    init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        strokeColor = NSColor.grayColor().CGColor
        fillColor = NSColor.clearColor().CGColor
        lineDashPattern = [1, 1]
        duration = 10.0
    }

    override func awakeFromNib()
    {
        imageScaling = .ImageScaleProportionallyUpOrDown
        drawSelectionHandles = true

    }

    func updateCharacter(image: NSImage, withCropPoint cropPoint: NSPoint, andCharacterRect box: NSRect)
    {
        self.image = image

        self.cropPoint = cropPoint

        self.selectionRect = box
        removeAnimatedSelection()
        setupAnimatedSelectionRect(self.selectionRect, cropPoint: cropPoint)

        NSLog("image size: %@", NSStringFromSize(image.size));
        NSLog("characterView frame: %@", NSStringFromRect(self.frame));
        NSLog("crop point: %@", NSStringFromPoint(cropPoint));

        width = image.size.width
        height = image.size.height

    }

    override func mouseDown(theEvent: NSEvent!)
    {
        let point = convertPoint(theEvent.locationInWindow, fromView: nil)
        var transform = CGAffineTransformInvert(CATransform3DGetAffineTransform(selectionLayer.transform))

        for var i = 0; i < selectionHandleLayers.count; i++
        {
            if CGPathContainsPoint(selectionHandleLayers[i].path, &transform, point, false)
            {
                self.startPointIndex = i
            }

        }
    }

    override func mouseUp(theEvent: NSEvent!)
    {
        startPointIndex = -1
    }

    override func mouseDragged(theEvent: NSEvent!)
    {
        var point = convertPoint(theEvent.locationInWindow, fromView: nil)
        var transform = CGAffineTransformInvert(CATransform3DGetAffineTransform(selectionLayer.transform))
        point = CGPointApplyAffineTransform(point, transform)
        
        let newRect = computeResizedSelectionRectangle(self.startPointIndex, dragPoint: point)
        NSLog("newRect: \(newRect)")
        drawSelectionRect(newRect)
        drawHandles(newRect)
        
        selectionRect = newRect
        

    }

}