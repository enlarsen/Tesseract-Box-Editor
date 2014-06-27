//
//  BoxResizeDelegateProtocol.swift
//  Tesseract-Box-Editor
//
//  Created by Erik Larsen on 6/27/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

import Foundation

protocol BoxResizeDelegate
{
    func boxDidResize(rect: NSRect)
    func doneDragging()
    func beganDragging()
}

