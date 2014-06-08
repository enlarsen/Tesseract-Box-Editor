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
    var startPoint = CGPointZero
    var cropPoint = CGPointZero
    var scaleFactor = 1.0
    var box: NSRect?


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
        setupAnimatedSelectionRect(self.box!, cropPoint: cropPoint)

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