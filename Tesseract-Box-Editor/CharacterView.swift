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
        strokeColor = NSColor.gray.cgColor
        fillColor = NSColor.clear.cgColor
        lineDashPattern = [1, 1]
        duration = 10.0
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib()
    {
        imageScaling = .scaleProportionallyUpOrDown
        drawSelectionHandles = true

    }


    func propagateValue(_ id: AnyObject, binding:NSString)
    {
        if let bindingInfo = self.infoForBinding(NSBindingName(rawValue: binding as String))
        {
            let bindingOptions: AnyObject = bindingInfo[NSBindingInfoKey.options] as AnyObject
            let _: ValueTransformer = bindingOptions[NSBindingOption.valueTransformer] as! ValueTransformer
        }
        else
        {
            return
        }

    }

    func updateCharacter(_ image: NSImage, cropPoint: NSPoint, rect: NSRect)
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

    override func mouseDown(with theEvent: NSEvent)
    {
        let point = convert(theEvent.locationInWindow, from: nil)
        let transform = CATransform3DGetAffineTransform(selectionLayer.transform).inverted()

        for i in 0 ..< selectionHandleLayers.count
        {
            if selectionHandleLayers[i].path?.contains(point, using: .winding, transform: transform) ?? false
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

    override func mouseUp(with theEvent: NSEvent)
    {
        startPointIndex = -1

        if (delegate != nil)
        {
            delegate!.doneDragging()
        }
    }

    override func mouseDragged(with theEvent: NSEvent)
    {
        var point = convert(theEvent.locationInWindow, from: nil)
        let transform = CATransform3DGetAffineTransform(selectionLayer.transform).inverted()
        point = point.applying(transform)
        
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
