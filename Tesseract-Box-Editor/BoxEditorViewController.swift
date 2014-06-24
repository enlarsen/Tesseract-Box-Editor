//
//  BoxEditorViewController.swift
//  Tesseract-Box-Editor
//
//  Created by Erik Larsen on 6/6/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//
//  MIT LICENSE
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

protocol BoxResizeDelegate
{
    func boxDidResize(rect: NSRect)
    func doneDragging()
    func beganDragging()
}

class BoxEditorViewController: NSViewController, BoxResizeDelegate
{
    @IBOutlet var characterView: CharacterView
    @IBOutlet var mainImageView: ImageView
    @IBOutlet var window: NSWindow
    @IBOutlet var boxesTableView: NSTableView
    @IBOutlet var tableArrayController: NSArrayController

    var selectionLayer: CAShapeLayer!
    var selectionHandleLayers: CAShapeLayer[] = []
    var currentFileUrl: NSURL?

    var cropPoint = CGPointZero
    var observing = false

    var pagesFromImage: NSBitmapImageRep[] = []
    var currentTiffPage: Int?

    var boxes: Box[] = []

    override func awakeFromNib()
    {
        mainImageView.imageScaling = .ImageScaleProportionallyUpOrDown
        characterView.delegate = self
    }


    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: NSDictionary!, context: CMutableVoidPointer)
    {
        if tableArrayController.selectedObjects.count > 0
        {
            let box = tableArrayController.selectedObjects[0] as Box
            if box.page != currentTiffPage
            {
                if currentTiffPage < pagesFromImage.count
                {
                    var size = pagesFromImage[box.page].size
                    var image = NSImage(size:size)
                    image.addRepresentation(pagesFromImage[box.page])
                    mainImageView.image = trimImage(image)
                    currentTiffPage = box.page

                }
            }
            updateSelectedCharacterDisplays()
        }
        else
        {
            mainImageView.removeAnimatedSelection()
        }
    }

    func updateSelectedCharacterDisplays()
    {
        let box = tableArrayController.selectedObjects[0] as Box
        updateCharacterView(box)
        mainImageView.removeAnimatedSelection()
        mainImageView.setupAnimatedSelectionRect(box.boxToNSRect(), cropPoint: cropPoint)

    }

    // Someday do everything as straight up bindings.
    // Problems with direct binding: need image and crop as well as the box down in the CharacterView
    func resizeBox(rect: NSRect, index: Int)
    {
        var box = boxes[index]
        box.x = Int(rect.origin.x)
        box.y = Int(rect.origin.y)
        box.width = Int(rect.size.width)
        box.height = Int(rect.size.height)
        if self.window.undoManager.undoing && index == tableArrayController.selectionIndex
        {
            updateSelectedCharacterDisplays()
        }
    }

    func boxDidResize(rect: NSRect)
    {
        let selectionIndex = tableArrayController.selectionIndex
        resizeBox(rect, index: selectionIndex)
    }

    func beganDragging()
    {
        let box = tableArrayController.selectedObjects[0] as Box
        let selectionIndex = tableArrayController.selectionIndex
        let currentRect = box.boxToNSRect()
        let undo = self.window.undoManager

        self.window.undoManager.prepareWithInvocationTarget(self).resizeBox(currentRect, index: selectionIndex)
        if !self.window.undoManager.undoing
        {
            self.window.undoManager.setActionName("Resize Box")
        }

    }

    func doneDragging()
    {
        updateSelectedCharacterDisplays()
    }

    func insertBox(box: Box, index: Int)
    {
        self.window.undoManager.prepareWithInvocationTarget(self).removeBox(index)

        if !self.window.undoManager.undoing
        {
            self.window.undoManager.setActionName("Insert Box")
        }
        boxes.insert(box, atIndex: index)
    }

    func removeBox(index: Int)
    {
        let box = boxes[index]
        self.window.undoManager.prepareWithInvocationTarget(self).insertBox(box, index: index)

        if !self.window.undoManager.undoing
        {
            self.window.undoManager.setActionName("Delete Box")
        }
        boxes.removeAtIndex(index)

    }

    func mergeBoxes(index: Int)
    {

    }

    func splitBoxes(index: Int)
    {
        
    }

    @IBAction func openMenu(sender: NSMenuItem)
    {

        let openPanel = NSOpenPanel()
        openPanel.allowedFileTypes = ["box", "BOX"]
        openPanel.canSelectHiddenExtension = true
        if observing
        {
            self.tableArrayController.removeObserver(self, forKeyPath: "selection")
            observing = false
        }
        openPanel.beginSheetModalForWindow(window, completionHandler: {result in
            if result == NSFileHandlingPanelOKButton
            {
                let boxUrl = openPanel.URL
                let tiffUrl = boxUrl.URLByDeletingPathExtension.URLByAppendingPathExtension("tif")
                let imageFromFile = NSImage(byReferencingURL: tiffUrl)
                self.pagesFromImage = imageFromFile.representations as NSBitmapImageRep[]
                self.mainImageView.image = self.trimImage(imageFromFile)
                self.parseBoxFile(boxUrl.path)
                self.currentTiffPage = 0

                self.tableArrayController.addObserver(self, forKeyPath: "selection", options: nil, context: nil)
                self.observing = true
                self.currentFileUrl = boxUrl
                self.tableArrayController.setSelectionIndex(1)
                self.tableArrayController.setSelectionIndex(0) // Move the selection so the observer sees the change and updates the display

            }
        })

    }

    @IBAction func saveMenu(sender: NSMenuItem)
    {
        if currentFileUrl
        {
            saveBoxFile(currentFileUrl!.path)
        }
    }


    // Coordinates are inverted in this function. (0, 0) is the upper left and y increases down
    func trimImage(image: NSImage) -> NSImage
    {
        let imageRef = image.CGImageForProposedRect(nil, context: nil, hints: nil).takeUnretainedValue()
        let width = CGImageGetWidth(imageRef)
        let height = CGImageGetHeight(imageRef)
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let bytesPerPixel: UInt = 4
        let bytesPerComponent: UInt = 8
        let rawData = calloc(height * width * bytesPerPixel, 1)
        let pointer = UnsafePointer<UInt8>(rawData)
        let bytesPerRow = bytesPerPixel * width
        let bitmapInfo = CGBitmapInfo.fromRaw(CGImageAlphaInfo.PremultipliedLast.toRaw() | CGBitmapInfo.ByteOrder32Big.toRaw())!
        let context = CGBitmapContextCreate(rawData, width, height, bytesPerComponent, bytesPerRow, colorSpace, bitmapInfo)

        CGContextDrawImage(context, CGRect(x: 0, y: 0, width: Int(width), height: Int(height)), imageRef)

        var top = 0
        var left = 0
        var right = Int(width)
        var bottom = Int(height)

        for var x = 0; x < Int(width); x++
        {
            if scanColumn(x, height: Int(height), width: Int(width), pointer: pointer)
            {
                left = x
                break
            }
        }

        for var x = Int(width) - 1; x >= 0; x--
        {
            if scanColumn(x, height: Int(height), width: Int(width), pointer: pointer)
            {
                right = x
                break
            }
        }

        for var y = 0; y < Int(height); y++
        {
            if scanRow(y, width: Int(width), pointer: pointer)
            {
                top = y
                break
            }
        }

        for var y = Int(height) - 1; y >= 0; y--
        {
            if scanRow(y, width: Int(width), pointer: pointer)
            {
                bottom = y
                break
            }
        }


        // Flip the coordinates to be Mac coordinates and add a border around the cropped image
        let cropRect = NSRect(x: left - 5, y: Int(height) - bottom - 6, width: right - left + 10, height: bottom - top + 10)
//        let target = NSImage(size: cropRect.size)
//        target.lockFocus()
//
//        image.drawInRect(NSRect(x: 0, y: 0, width: cropRect.size.width, height: cropRect.size.height), fromRect: cropRect, operation: .CompositeCopy, fraction: 1.0)
//        target.unlockFocus()

        free(rawData)

        image.lockFocus()
        let bitmapRep = NSBitmapImageRep(focusedViewRect: cropRect)
        image.unlockFocus()


        let croppedImage = NSImage(data: bitmapRep.representationUsingType(.NSPNGFileType, properties: nil))
        cropPoint = cropRect.origin
        return croppedImage


    }

    func scanRow(y: Int, width:Int, pointer: UnsafePointer<UInt8>) -> Bool
    {
        for var x = 0; x < width; x++
        {
            if pointer[(x + y * width) * 4] != 0xff // only check red, could cause trouble
            {
                return true
            }
        }
        return false
    }

    func scanColumn(x: Int, height: Int, width: Int, pointer: UnsafePointer<UInt8>) -> Bool
    {
        for var y = 0; y < height; y++
        {
            if pointer[(x + y * width) * 4] != 0xff // only check red
            {
                return true
            }
        }
        return false
    }

    func updateCharacterView(box: Box)
    {
        let image = NSImage(data: pagesFromImage[box.page].representationUsingType(.NSPNGFileType, properties: nil))
        image.lockFocus()
        let bitmapRep = NSBitmapImageRep(focusedViewRect: NSRect(x: box.x - 5, y: box.y - 5,
            width: box.width + 10, height: box.height + 10))
        image.unlockFocus()

        let croppedImage = NSImage(data: bitmapRep.representationUsingType(.NSPNGFileType, properties: nil))
        characterView.updateCharacter(croppedImage, cropPoint: NSPoint(x: box.x - 5, y: box.y - 5), rect: box.boxToNSRect())
    }

    // TODO: This needs vastly improved error handling and value checking
    func parseBoxFile(path: String)
    {
        var error: NSError? = nil
        var boxes: Box[] = []
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

    func saveBoxFile(path: String)
    {
        var output = ""
        var error: NSError? = nil;

        let outputPath = path.stringByAppendingPathExtension("tmp")

        for box in boxes
        {
            output = output.stringByAppendingString(box.formatForWriting())
        }

        output.writeToFile(outputPath, atomically: true, encoding: NSUTF8StringEncoding, error: &error)
        if let uwError = error
        {
            NSLog("writeToFile error: \(uwError.localizedDescription)")
            return;
        }
        NSFileManager.defaultManager().moveItemAtPath(path, toPath: path.stringByAppendingPathExtension("old"), error: &error)
        if let uwError = error
        {
            NSLog("moveItemAtPath error: \(uwError.localizedDescription)")
            return;
        }
        NSFileManager.defaultManager().moveItemAtPath(outputPath, toPath: path, error: &error)
        if let uwError = error
        {
            NSLog("moveItemAtPath error: \(uwError.localizedDescription)")
            return;
        }
        NSFileManager.defaultManager().removeFileAtPath(path.stringByAppendingPathExtension("old"), handler: nil)

        window.documentEdited = false

    }

    func mergeCharacters()
    {

    }

    func splitCharacters()
    {

    }

    func getNextIntValue(scanner: NSScanner) -> Int
    {
        var intValue: CInt = 0
        
        scanner.scanInt(&intValue)
        return Int(intValue)
    }
    


}

