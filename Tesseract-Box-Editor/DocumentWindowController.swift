//
//  DocumentWindowController.swift
//  Tesseract-Box-Editor
//
//  Created by Erik Larsen on 6/28/14.
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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class DocumentWindowController: NSWindowController, BoxResizeDelegate
{
    @IBOutlet var mainImageView: ImageView!
    @IBOutlet var characterView: CharacterView!
    @IBOutlet var tableArrayController: NSArrayController!
    @IBOutlet var tableView: NSTableView!

    override var windowNibName: NSNib.Name?
    {
        return NSNib.Name(rawValue: "Document")
    }

    var currentDocument: Document
    {
        get
        {
            return document as! Document
        }
    }

    // Used by Cocoa bindings because they won't take a key path to "currentDocument.boxes"
    var boxes: [Box]
    {
        get
        {
            return currentDocument.boxes
        }
        set(newValue)
        {
            currentDocument.boxes = newValue
        }
    }

    var selectionLayer: CAShapeLayer!
    var selectionHandleLayers: [CAShapeLayer] = []

    var observing = false

    var pagesFromImage: [NSBitmapImageRep] = []
    var currentTiffPage: Int = -1
    {
        willSet
        {
            self.willChangeValue(forKey: "isThereAPreviousPage")
            self.willChangeValue(forKey: "isThereANextPage")
        }
        didSet
        {
            self.didChangeValue(forKey: "isThereAPreviousPage")
            self.didChangeValue(forKey: "isThereANextPage")
        }
    }

    var isThereAPreviousPage: Bool
    {
        get
        {
            if currentTiffPage - 1 < 0
            {
                return false
            }
            else
            {
                return true
            }
        }
    }

    var isThereANextPage: Bool
    {
        get
        {
            if currentTiffPage + 1 >= pagesFromImage.count
            {
                return false
            }
            else
            {
                return true
            }
        }
    }


    override class func automaticallyNotifiesObservers(forKey key: String) -> Bool
    {

        if key == "isThereAPreviousPage" || key == "isThereANextPage"
        {
            return false
        }
        else
        {
            return true
        }

    }


    override func awakeFromNib()
    {
        mainImageView.imageScaling = .scaleProportionallyUpOrDown
        characterView.delegate = self
    }

    func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [String : Any]?, context: UnsafeMutableRawPointer?)
    {
        if tableArrayController.selectedObjects.count > 0
        {
            updateSelectedCharacterDisplays()
        }
        else
        {
            mainImageView.removeAnimatedSelection()
        }
    }


    func updateSelectedCharacterDisplays()
    {

        if tableArrayController?.selectedObjects?.count > 0
        {
            if let box = tableArrayController?.selectedObjects[0] as? Box
            {
                if box.page != currentTiffPage
                {
                    if currentTiffPage < pagesFromImage.count
                    {
                        let size = pagesFromImage[box.page].size
                        let image = NSImage(size:size)
                        image.addRepresentation(pagesFromImage[box.page])
                        mainImageView.trimImage(image)
                        currentTiffPage = box.page

                    }
                }

                updateCharacterView(box)
                mainImageView.removeAnimatedSelection()
                mainImageView.setupAnimatedSelectionRect(box.boxToNSRect())
            }
        }

    }

    // Someday do everything as straight up bindings.
    // Problems with direct binding: need image and crop as well as the box down in the CharacterView,
    // unless I move the image down to the viewer classes and then let them crop the image.
    @objc func resizeBox(_ rect: NSRect, index: Int)
    {
        let box = boxes[index]
        box.x = Int(rect.origin.x)
        box.y = Int(rect.origin.y)
        box.width = Int(rect.size.width)
        box.height = Int(rect.size.height)
        if self.window!.undoManager!.isUndoing && index == tableArrayController.selectionIndex
        {
            updateSelectedCharacterDisplays()
        }
    }

    @objc func changeCharacter(_ char: String, index: Int)
    {
        let box = boxes[index]
        (self.window!.undoManager!.prepare(withInvocationTarget: self) as AnyObject).changeCharacter(box.character, index: index)
        if !self.window!.undoManager!.isUndoing
        {
            self.window!.undoManager!.setActionName("Change \"\(box.character)\" to \"\(char)\"")
        }
        box.character = char
    }

    func boxDidResize(_ rect: NSRect)
    {
        let selectionIndex = tableArrayController.selectionIndex
        resizeBox(rect, index: selectionIndex)
    }

    func beganDragging()
    {
        let box = tableArrayController.selectedObjects[0] as! Box
        let selectionIndex = tableArrayController.selectionIndex
        let currentRect = box.boxToNSRect()

        (self.window!.undoManager!.prepare(withInvocationTarget: self) as AnyObject).resizeBox(currentRect, index: selectionIndex)
        if !self.window!.undoManager!.isUndoing
        {
            self.window!.undoManager!.setActionName("Resize Box")
        }

    }

    func doneDragging()
    {
        updateSelectedCharacterDisplays()
    }

    @objc func insertBox(_ box: Box, index: Int)
    {
        (self.window!.undoManager!.prepare(withInvocationTarget: self) as AnyObject).removeBox(index)

        if !self.window!.undoManager!.isUndoing
        {
            self.window!.undoManager!.setActionName("Insert Box")
        }
        boxes.insert(box, at: index)
    }

    @objc func removeBox(_ index: Int)
    {
        let box = boxes[index]
        (self.window!.undoManager!.prepare(withInvocationTarget: self) as AnyObject).insertBox(box, index: index)

        if !self.window!.undoManager!.isUndoing
        {
            self.window!.undoManager!.setActionName("Delete Box")
        }
        boxes.remove(at: index)

    }

    func mergeBoxes(_ index: Int)
    {
        let firstBox = boxes[index]

        if index + 1 < boxes.count
        {
            let secondBox = boxes[index + 1]
            self.window!.undoManager!.beginUndoGrouping()

            (self.window!.undoManager!.prepare(withInvocationTarget: self) as AnyObject).insertBox(secondBox, index: index + 1)
            (self.window!.undoManager!.prepare(withInvocationTarget: self) as AnyObject).resizeBox(firstBox.boxToNSRect(), index: index)

            if !self.window!.undoManager!.isUndoing
            {
                self.window!.undoManager!.setActionName("Merge Boxes")
            }
            self.window!.undoManager!.endUndoGrouping()

            // This is a simplistic merge. Should create a rectangle that encloses both characters, but
            // have to test whether the character is at the end of the line and do something reasonable then.
            firstBox.width += secondBox.width
            removeBox(index + 1)
            currentDocument.createPageIndex()
            updateSelectedCharacterDisplays()
        }
        else
        {
            return
        }

    }

    func splitBoxes(_ index: Int)
    {
        let box = boxes[index]

        self.window!.undoManager!.beginUndoGrouping()

        (self.window!.undoManager!.prepare(withInvocationTarget: self) as AnyObject).removeBox(index + 1)
        (self.window!.undoManager!.prepare(withInvocationTarget: self) as AnyObject).resizeBox(box.boxToNSRect(), index:index)

        if !self.window!.undoManager!.isUndoing
        {
            self.window!.undoManager!.setActionName("Split Box")
        }
        self.window!.undoManager!.endUndoGrouping()

        let newBox = Box()
        newBox.page = box.page
        newBox.character = "?"
        newBox.y = box.y
        newBox.y2 = box.y2
        newBox.x = Int(box.x + (box.width / 2))
        newBox.x2 = box.x2
        box.x2 = newBox.x - 2

        boxes.insert(newBox, at: index + 1)

        currentDocument.createPageIndex()
        updateSelectedCharacterDisplays()

    }

    @IBAction func mergeToolbarItem(_ sender: NSToolbarItem)
    {

        mergeBoxes(tableArrayController.selectionIndex)
    }

    @IBAction func splitToolbarItem(_ sender: NSToolbarItem)
    {
        splitBoxes(tableArrayController.selectionIndex)
    }

    func deleteToolbarItem(_ sender: NSToolbarItem)
    {
        removeBox(tableArrayController.selectionIndex)
    }

    func insertToolbarItem(_ sender: NSToolbarItem)
    {
        let index = tableArrayController.selectionIndex

        let selectedBox = boxes[index]

        let box = Box()
        box.x = selectedBox.x - selectedBox.width
        box.y = selectedBox.y
        box.width = selectedBox.width
        box.height = selectedBox.height
        box.character = "?"
        box.page = selectedBox.page

        insertBox(box, index: index)
    }

    // The KVO will see the change in selection and update the image view
    @IBAction func previousPage(_ sender: NSButton)
    {
        let index = currentTiffPage - 1
        if index < 0
        {
            return
        }
        let row = currentDocument.pageIndex[index]
        tableArrayController.setSelectionIndex(row!)
        updateSelectedCharacterDisplays()
        tableView.scrollRowToVisible(row!)


    }

    @IBAction func nextPage(_ sender: NSButton)
    {
        let index = currentTiffPage + 1
        if index >= boxes.count
        {
            return
        }
        let row = currentDocument.pageIndex[index]
        tableArrayController.setSelectionIndex(row!)
        updateSelectedCharacterDisplays()
        tableView.scrollRowToVisible(row!)

    }

    func scanRow(_ y: Int, width:Int, pointer: UnsafePointer<UInt8>) -> Bool
    {
        for x in 0 ..< width
        {
            if pointer[(x + y * width) * 4] != 0xff // only check red, could cause trouble
            {
                return true
            }
        }
        return false
    }

    func scanColumn(_ x: Int, height: Int, width: Int, pointer: UnsafePointer<UInt8>) -> Bool
    {
        for y in 0 ..< height
        {
            if pointer[(x + y * width) * 4] != 0xff // only check red
            {
                return true
            }
        }
        return false
    }

    func updateCharacterView(_ box: Box)
    {
        if box.page < pagesFromImage.count
        {
            let image = NSImage(size: pagesFromImage[box.page].size)
            image.addRepresentation(pagesFromImage[box.page])

            let croppedImage = NSImage(size: NSSize(width: box.width + 10, height: box.height + 10))

            croppedImage.lockFocus()
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current?.imageInterpolation = NSImageInterpolation.none
            NSGraphicsContext.current?.shouldAntialias = false

            image.draw(in: NSRect(x: 0, y: 0, width: box.width + 10, height: box.height + 10),
                       from: NSRect(x: box.x - 5, y: box.y - 5,
                    width: box.width + 10, height: box.height + 10),
                operation: .copy,
                fraction: 1.0)

            NSGraphicsContext.restoreGraphicsState()
            croppedImage.unlockFocus()

            characterView.updateCharacter(croppedImage, cropPoint: NSPoint(x: box.x - 5, y: box.y - 5), rect: box.boxToNSRect())
        }
    }


    func windowDidResize(_ notification: Notification!)
    {
        if mainImageView.image != nil
        {
            updateSelectedCharacterDisplays()
        }
    }

    override func windowDidLoad()
    {
        super.windowDidLoad()

        if observing
        {
            self.tableArrayController.removeObserver(self, forKeyPath: "selection")
            observing = false
        }

        if let tiffUrl = currentDocument.fileURL?.deletingPathExtension().appendingPathExtension("tif")
        {
            let imageFromFile = NSImage(byReferencing: tiffUrl)
            pagesFromImage = imageFromFile.representations as! [NSBitmapImageRep]
            mainImageView.trimImage(imageFromFile)
            currentTiffPage = 0
            
            tableArrayController.addObserver(self, forKeyPath: "selection", options: [], context: nil)
            observing = true
            tableArrayController.setSelectionIndex(1)
            tableArrayController.setSelectionIndex(0) // Move the selection so the observer sees the change and updates the display
            currentDocument.createPageIndex()
            tableView.scrollRowToVisible(0)
            tableView.becomeFirstResponder()
        }

    }

    // TODO: Need to allow composed characters
    // TODO: Investigate the method for interpreting characters, see orange book
    override func keyDown(with theEvent: NSEvent)
    {
        self.interpretKeyEvents([theEvent])

    }

    // function for interpretKeyEvents
    override func insertText(_ insertString: Any)
    {
        if let characters = insertString as? String
        {
            let selectedIndex = tableArrayController.selectionIndex
            changeCharacter(characters, index: selectedIndex)
        }
    }


    override func encodeRestorableState(with coder: NSCoder)
    {
        super.encodeRestorableState(with: coder)
        coder.encode(tableArrayController.selectionIndex, forKey: "selectionIndex")


    }

    override func restoreState(with coder: NSCoder)
    {
        super.restoreState(with: coder)
        let index = coder.decodeInteger(forKey: "selectionIndex")

        tableArrayController.setSelectionIndex(index)
        tableView.scrollRowToVisible(index)
        updateSelectedCharacterDisplays()
    }
}
