//
//  Document.swift
//  Tesseract-Box-Editor
//
//  Created by Erik Larsen on 6/27/14.
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
import Cocoa
import QuartzCore

class Document: NSDocument
{
    var pagesFromImage: [NSBitmapImageRep] = []
    var boxes: [Box] = []
    var pageIndex = Dictionary<Int, Int>()


    override var windowNibName: String
    {
        return "Document"
    }

    // TODO: This needs vastly improved error handling and value checking
    func readBoxFile(path: String)
    {
        var error: NSError? = nil
        var boxes: [Box] = []
        let fileText = NSString.stringWithContentsOfFile(path, encoding: NSUTF8StringEncoding, error: &error)

        if let mError = error
        {
            NSLog("Error: \(mError.localizedDescription)")
        }

        fileText.enumerateLinesUsingBlock({line, stop in
            var box = Box()
            var intValue: CInt = 0
            var characterAsString: NSString?

            let scanner = NSScanner(string: line)
            scanner.caseSensitive = true
            scanner.charactersToBeSkipped = nil

            scanner.scanUpToString(" ", intoString: &characterAsString)

            if let character = characterAsString
            {
                box.character = character
            }

            scanner.charactersToBeSkipped = NSCharacterSet.whitespaceCharacterSet()

            box.x = self.getNextIntValue(scanner)
            box.y = self.getNextIntValue(scanner)
            box.x2 = self.getNextIntValue(scanner)
            box.y2 = self.getNextIntValue(scanner)
            box.page = self.getNextIntValue(scanner)
            boxes.append(box)
            })
        self.boxes = boxes

    }


    func getNextIntValue(scanner: NSScanner) -> Int
    {
        var intValue: CInt = 0
        
        scanner.scanInt(&intValue)
        return Int(intValue)
    }

    func createPageIndex()
    {
        pageIndex.removeAll(keepCapacity: true)
        var current = -1

        for var i = 0; i < boxes.count; i++
        {
            if current != boxes[i].page
            {
                current = boxes[i].page
                pageIndex[current] = i
            }
        }

    }

    override func readFromURL(url: NSURL!, ofType typeName: String!, error outError: NSErrorPointer) -> Bool
    {
        readBoxFile(url.path)

        return true
    }

    override func writeToURL(url: NSURL!, ofType typeName: String!, error outError: NSErrorPointer) -> Bool
    {
        var output = ""

        for box in boxes
        {
            output = output.stringByAppendingString(box.formatForWriting())
        }

        output.writeToFile(url.path, atomically: true, encoding: NSUTF8StringEncoding, error: outError)

//        NSLog("\(outError.memory?.localizedDescription)")

        if outError.memory == nil
        {
            return true
        }
        else
        {
            return false
        }
    }

    override func makeWindowControllers()
    {
        let windowController = DocumentWindowController(windowNibName: self.windowNibName)
        addWindowController(windowController)
    }


}

