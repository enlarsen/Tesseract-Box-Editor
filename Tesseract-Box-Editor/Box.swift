//
//  Box.swift
//  Tesseract-Box-Editor
//
//  Created by Erik Larsen on 6/6/14.
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

class Box: NSObject
{
    var x: Int = 0
    var y: Int = 0
    var x2: Int = 0
    var y2: Int = 0
    var page: Int = 0
    var character: String = " "

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

    class func boxToNSRect(box: Box) -> NSRect
    {
        return NSRect(x: box.x, y: box.y, width: box.width, height: box.height)
    }

    func boxToNSRect() -> NSRect
    {
        return Box.boxToNSRect(self)
    }

    func formatForWriting() -> String
    {
        return NSString(format: "%@ %d %d %d %d %d\n", character,
                            x, y, x2, y2, page) as String
    }
}
