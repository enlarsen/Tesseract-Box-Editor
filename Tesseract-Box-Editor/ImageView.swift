//
//  ImageView.swift
//  Tesseract-Box-Editor
//
//  Created by Erik Larsen on 6/6/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

import Foundation
import Cocoa

class ImageView: ImageViewWithSelectionRect
{

    init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        self.fillColor = NSColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.5).CGColor
    }
    
}