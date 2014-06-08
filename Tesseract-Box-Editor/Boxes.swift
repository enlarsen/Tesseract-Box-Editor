//
//  Boxes.swift
//  Tesseract-Box-Editor
//
//  Created by Erik Larsen on 6/5/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

import Foundation

class Boxes: NSObject
{
    var path = ""
    var boxes: Box[] = []

    init(file path: String)
    {
        super.init()

        self.path = path
        parseBoxFile()
    }

    subscript(index: Int) -> Box
        {
        get
        {
            return boxes[index]
        }
        set(newValue)
        {
            boxes[index] = newValue
        }
    }


    // TODO: This needs vastly improved error handling and value checking
    func parseBoxFile()
    {
        let fileText = NSString.stringWithContentsOfFile(path, encoding: NSUTF8StringEncoding, error: nil)

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
            self.boxes += box
            })


    }

    func getNextIntValue(scanner: NSScanner) -> Int
    {
        var intValue: CInt = 0

        scanner.scanInt(&intValue)
        return Int(intValue)
    }

}