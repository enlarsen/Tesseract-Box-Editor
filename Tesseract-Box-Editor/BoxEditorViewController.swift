//
//  BoxEditorViewController.swift
//  Tesseract-Box-Editor
//
//  Created by Erik Larsen on 6/6/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

import Foundation
import Cocoa
import QuartzCore

class BoxEditorViewController: NSViewController
{
    @IBOutlet var characterView: CharacterView
    @IBOutlet var mainImageView: ImageView
    @IBOutlet var window: NSWindow
    @IBOutlet var boxesTableView: NSTableView
    @IBOutlet var tableArrayController: NSArrayController

    var selectionLayer: CAShapeLayer!
    var selectionHandleLayers: CAShapeLayer[] = []

    var cropPoint = CGPointZero
//    var topHandle = CGPointZero
//    var bottomHandle = CGPointZero
//    var leftHandle = CGPointZero
//    var rightHandle = CGPointZero
    var observing = false

    var pagesFromImage: NSBitmapImageRep[] = []
    var currentRepresentation: Int?

    var boxes: Box[] = []

    override func awakeFromNib()
    {
        mainImageView.imageScaling = .ImageScaleProportionallyUpOrDown

    }


    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: NSDictionary!, context: CMutableVoidPointer)
    {
        if tableArrayController.selectedObjects.count > 0
        {
            let box = tableArrayController.selectedObjects[0] as Box
            if box.page != currentRepresentation
            {
                if currentRepresentation < pagesFromImage.count
                {
                    var size = pagesFromImage[box.page].size
                    var image = NSImage(size:size)
                    image.addRepresentation(pagesFromImage[box.page])
                    mainImageView.image = trimImage(image)
                    currentRepresentation = box.page

                }
            }
        updateCharacterView(box)
        mainImageView.removeAnimatedSelection()
        mainImageView.setupAnimatedSelectionRect(box.boxToNSRect(), cropPoint: cropPoint)
        }
        else
        {
            mainImageView.removeAnimatedSelection()
        }
    }

 

    @IBAction func openMenu(sender: NSMenuItem)
    {

        let openPanel = NSOpenPanel()
        openPanel.allowedFileTypes = ["tiff", "tif", "TIFF", "TIF", "jpg", "jpeg", "JPG", "JPEG"]
        openPanel.canSelectHiddenExtension = true
        if observing
        {
            self.tableArrayController.removeObserver(self, forKeyPath: "selection")
            observing = false
        }
        openPanel.beginSheetModalForWindow(window, completionHandler: {result in
            if result == NSFileHandlingPanelOKButton
            {
                let url = openPanel.URL
                let boxUrl = url.URLByDeletingPathExtension.URLByAppendingPathExtension("box")
                let imageFromFile = NSImage(byReferencingURL: url)
                self.pagesFromImage = imageFromFile.representations as NSBitmapImageRep[]
                self.mainImageView.image = self.trimImage(imageFromFile)
                self.parseBoxFile(boxUrl.path)
                self.currentRepresentation = 0

                self.tableArrayController.addObserver(self, forKeyPath: "selection", options: nil, context: nil)
                self.observing = true

            }
        })

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
        let target = NSImage(size: cropRect.size)
        target.lockFocus()

        image.drawInRect(NSRect(x: 0, y: 0, width: cropRect.size.width, height: cropRect.size.height), fromRect: cropRect, operation: .CompositeCopy, fraction: 1.0)
        target.unlockFocus()

        free(rawData)

        image.lockFocus()
        let bitmapRep = NSBitmapImageRep(focusedViewRect: cropRect)
        image.unlockFocus()


        let croppedImage = NSImage(data: bitmapRep.representationUsingType(.NSPNGFileType, properties: nil))
        cropPoint = NSPoint(x: left - 5, y: Int(height) - bottom - 6)
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
        characterView.updateCharacter(croppedImage, withCropPoint: NSPoint(x: box.x - 5, y: box.y - 5), andCharacterRect: box.boxToNSRect())
    }
    
    // TODO: This needs vastly improved error handling and value checking
    func parseBoxFile(path: String)
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
            self.boxes.append(box)
            })


    }

    func getNextIntValue(scanner: NSScanner) -> Int
    {
        var intValue: CInt = 0
        
        scanner.scanInt(&intValue)
        return Int(intValue)
    }
    
    func writeBoxFile(path: String)
    {
        
    }

}