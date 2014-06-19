Tesseract Box Editor
====================

An editor for editing .box files created by Tesseract OCR in training mode. Not
yet usable. It was written in Apple's new language, Swift.

## To Do

1. Save file
2. Merge (toolbar, menubar, and implementation)
3. Split (toolbar, menubar, and implementation)
4. Choose character in tableview when corresponding character is selected in image view and vice versa
5. Adornments for selection rectangle: handles, size, position, update in table view continuously
6. Status bar?
7. View menu: show cropped or not
8. Drag selection rectangle when clicking within or not on resize handles
9. Add a new column: seen or show bold for characters that were never selected.
10. Save data to another file for including other metadata (such as the "seen" attribute). Should be in the same directory, loaded if found. Or should it be in a known location?
11. Zoom control
12. Implement multiple selection in table view (for merging character boxes)
13. Add the current character to the CALayer near the selection box (for verification)
14. NSUndoManager
15. Handle case where .box file can't be found or opened
16. Cursor changes when over resize handles (up/down, left/right, diagonal)
17. Change to hand cursor when over the body of the selection
18. Scale selection handles and selection rectangle stroke width depending on the scale of the image (so they don't appear too large).
19. Change Box to use NSRect for storing coordinates
20. Fix names of parameter in funcs (don't use Objective C internal and external parameter names)
21. Restrict dragging to the character's image bounds/frame
22. Send new bounds data back to data structure after handle resize

## License

[MIT License](http://zonorocha.mit-license.org)
