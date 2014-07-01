# Tesseract Box Editor (TBE)

An editor for editing .box files created by Tesseract OCR in training mode.
Tesseract is an open source OCR program available at [Tesseract-OCR](https://code.google.com/p/tesseract-ocr/)
TBE was written in Apple's new language, Swift.

Open a .box file, and the editor will open the corresponding
.tif file (same filename as the box file but with a "tif" extension).

## Tips

Use the up and down arrows to move between quickly between boxes. Type a
character to immediately replace the selected character. Move between pages in multiple
page tiff files with the buttons at the bottom of the screen.

## Creating .box files

Tesseract can be invoked in training mode to create box files:

```
tesseract [lang].[fontname].exp[num].tif [lang].[fontname].exp[num] batch.nochop makebox
```

For example:

```
tesseract eng.swim.exp0.tif eng.swim.exp0 batch.nochop makebox
```

For more information about generating box files see [Training Tesseract](https://code.google.com/p/tesseract-ocr/wiki/TrainingTesseract3)

## License

[MIT License](http://zonorocha.mit-license.org)
