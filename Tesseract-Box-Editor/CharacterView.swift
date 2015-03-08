//
//  CharacterView.swift
//  Tesseract-Box-Editor
//
//  Created by Erik Larsen on 6/4/14.
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

import Cocoa
import QuartzCore

class CharacterView: ImageViewWithSelectionRect
{

    var width: CGFloat = 0.0
    var height:CGFloat = 0.0
    var startPointIndex = -1
    var scaleFactor = 1.0
    var delegate: BoxResizeDelegate? = nil

    override init(frame frameRect: NSRect)
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


    func propagateValue(id: AnyObject, binding:NSString)
    {
        if let bindingInfo = self.infoForBinding(binding)
        {
            if let bindingOptions : AnyObject = bindingInfo[NSOptionsKey]
            {
                let transformer: NSValueTransformer = bindingOptions[NSValueTransformerBindingOption] as NSValueTransformer
            }
        }
        else
        {
            return
        }

    }

    func updateCharacter(image: NSImage, cropPoint: NSPoint, rect: NSRect)
    {
        self.image = image

        self.cropPoint = cropPoint

        self.selectionRect = rect
        removeAnimatedSelection()
        setupAnimatedSelectionRect(self.selectionRect)

//        NSLog("image size: %@", NSStringFromSize(image.size));
//        NSLog("characterView frame: %@", NSStringFromRect(self.frame));
//        NSLog("crop point: %@", NSStringFromPoint(cropPoint));

        width = image.size.width
        height = image.size.height

    }

    override func mouseDown(theEvent: NSEvent)
    {
        let point = convertPoint(theEvent.locationInWindow, fromView: nil)
        var transform = CGAffineTransformInvert(CATransform3DGetAffineTransform(selectionLayer.transform))

        for var i = 0; i < selectionHandleLayers.count; i++
        {
            if CGPathContainsPoint(selectionHandleLayers[i].path, &transform, point, false)
            {
                self.startPointIndex = i
                break
            }

        }
        if (delegate != nil)
        {
            delegate!.beganDragging()
        }

        // TODO: also check whether the click was within the selection rectangle in prep for a move
    }

    override func mouseUp(theEvent: NSEvent)
    {
        startPointIndex = -1

        if (delegate != nil)
        {
            delegate!.doneDragging()
        }
    }

    override func mouseDragged(theEvent: NSEvent)
    {
        var point = convertPoint(theEvent.locationInWindow, fromView: nil)
        var transform = CGAffineTransformInvert(CATransform3DGetAffineTransform(selectionLayer.transform))
        point = CGPointApplyAffineTransform(point, transform)
        
        let newRect = computeResizedSelectionRectangle(self.startPointIndex, dragPoint: point)
//        NSLog("newRect: \(newRect)")
        drawSelectionRect(newRect)
        drawHandles(newRect)
        
        selectionRect = newRect
//        window.documentEdited = true
        if (delegate != nil)
        {
            delegate!.boxDidResize(newRect)
        }

    }

}