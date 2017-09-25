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


    override var windowNibName: NSNib.Name?
    {
        return NSNib.Name(rawValue: "Document")
    }

    // TODO: This needs vastly improved error handling and value checking
    func readBoxFile(_ path: String)
    {
        var error: NSError? = nil
        var boxes: [Box] = []
        let fileText: NSString?
        do {
            fileText = try NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue)
        } catch let error1 as NSError {
            error = error1
            fileText = nil
        }

        if let mError = error
        {
            NSLog("Error: \(mError.localizedDescription)")
        }

        fileText!.enumerateLines({line, stop in
            let box = Box()
//            var intValue: CInt = 0
            var characterAsString: NSString?

            let scanner = Scanner(string: line)
            scanner.caseSensitive = true
            scanner.charactersToBeSkipped = nil

            scanner.scanUpTo(" ", into: &characterAsString)

            if let character = characterAsString
            {
                box.character = character as String
            }

            scanner.charactersToBeSkipped = CharacterSet.whitespaces

            box.x = self.getNextIntValue(scanner)
            box.y = self.getNextIntValue(scanner)
            box.x2 = self.getNextIntValue(scanner)
            box.y2 = self.getNextIntValue(scanner)
            box.page = self.getNextIntValue(scanner)
            boxes.append(box)
            })
        self.boxes = boxes

    }


    func getNextIntValue(_ scanner: Scanner) -> Int
    {
        var intValue: CInt = 0
        
        scanner.scanInt32(&intValue)
        return Int(intValue)
    }

    func createPageIndex()
    {
        pageIndex.removeAll(keepingCapacity: true)
        var current = -1

        for i in 0 ..< boxes.count
        {
            if current != boxes[i].page
            {
                current = boxes[i].page
                pageIndex[current] = i
            }
        }

    }

    override func read(from url: URL, ofType typeName: String) throws
    {
        readBoxFile(url.path)
    }

    override func write(to url: URL, ofType typeName: String) throws
    {
        var outError: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
        var output = ""

        for box in boxes
        {
            output = output + box.formatForWriting()
        }

        do {
            try output.write(toFile: url.path, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            outError = error
        }

//        NSLog("\(outError.memory?.localizedDescription)")

        if outError == nil
        {
            return
        }
        else
        {
            throw outError
        }
    }

    override func makeWindowControllers()
    {
        let windowController = DocumentWindowController(windowNibName: NSNib.Name(rawValue: self.windowNibName!.rawValue))
        addWindowController(windowController)
    }


}

