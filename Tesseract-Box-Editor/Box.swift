//
//  Box.swift
//  Tesseract-Box-Editor
//
//  Created by Erik Larsen on 6/6/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

import Foundation

class Box: NSObject
{
    var x: Int
    var y: Int
    var x2: Int
    var y2: Int
    var page: Int
    var character: String
//    var character: unichar

    var width: Int
    {
        get
        {
            return x2 - x
        }
        set(newValue)
        {
            x2 = x + newValue
        }
    }

    var height: Int
    {
        get
        {
            return y2 - y
        }
        set(newValue)
        {
            y2 = y + newValue
        }
    }

    init()
    {
        x = 0
        y = 0
        x2 = 0
        y2 = 0
        page = 0
        character = " "
    }

    class func boxToNSRect(box: Box) -> NSRect
    {
        return NSRect(x: box.x, y: box.y, width: box.width, height: box.height)
    }

    func boxToNSRect() -> NSRect
    {
        return Box.boxToNSRect(self)
    }
}
