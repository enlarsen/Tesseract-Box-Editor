//
//  TBEBoxEditorViewController.m
//  Tesseract-Box-Editor
//
//  Created by Erik Larsen on 5/26/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

@import QuartzCore;

#import "TBEAppDelegate.h"
#import "TBEBoxEditorViewController.h"
#import "TBEBoxView.h"
#import "TBEBox.h"

@interface TBEBoxEditorViewController () <NSWindowDelegate>

@property (weak) IBOutlet NSImageView *mainImageView;
@property (unsafe_unretained) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTableView *boxesTableView;
@property (weak) IBOutlet NSArrayController *tableArrayController;
@property (strong, nonatomic) CAShapeLayer *selectionLayer;
@property (nonatomic) NSPoint croppedPoint; // new lower left point relative to image

@end

@implementation TBEBoxEditorViewController

- (void)awakeFromNib
{
//    self.mainImageView.layer = [CALayer layer];
//    self.mainImageView.wantsLayer = YES;

//    self.mainImageView.layer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
//    self.mainImageView.layer.needsDisplayOnBoundsChange = YES;

    self.mainImageView.imageScaling = NSImageScaleProportionallyUpOrDown;// NSImageScaleProportionallyDown;


    [self.tableArrayController addObserver:self forKeyPath:@"selection" options:0 context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(self.tableArrayController.selectedObjects.count)
    {
        TBEBox *box = self.tableArrayController.selectedObjects[0];
        [self removeAnimatedSelection];
        [self setupAnimatedSelectionWithBox:box];
    }
    else
    {
        [self removeAnimatedSelection];
    }
}

- (void)setupAnimatedSelectionWithBox:(TBEBox *)box
{
    float verticalPadding = 0.0;
    float horizontalPadding = 0.0;
    float scaleFactor = 1.0;
    float horizontalScaleFactor = self.mainImageView.frame.size.width /
                                self.mainImageView.image.size.width;
    float verticalScaleFactor =  self.mainImageView.frame.size.height /
                                self.mainImageView.image.size.height;



    NSLog(@"horizontal scale: %f, vertical scale %f", horizontalScaleFactor, verticalScaleFactor);

    if(verticalScaleFactor - horizontalScaleFactor < 0)
    {
        scaleFactor = verticalScaleFactor;

        float width = self.mainImageView.image.size.width * scaleFactor;
        horizontalPadding = (self.mainImageView.frame.size.width - width) / 2.0;
    }
    if(horizontalScaleFactor - verticalScaleFactor < 0)
    {
        scaleFactor = horizontalScaleFactor;

        float height = self.mainImageView.image.size.height * scaleFactor;
        verticalPadding = (self.mainImageView.frame.size.height - height) / 2.0;
    }

    NSLog(@"Horizontal padding: %f, vertical padding: %f", horizontalPadding, verticalPadding);

    self.selectionLayer = [CAShapeLayer layer];

    self.selectionLayer.lineWidth = 0.5;
    self.selectionLayer.strokeColor = [[NSColor redColor] CGColor];
    NSColor *fillColor = [NSColor colorWithDeviceRed:1.0 green:1.0 blue:30.0 alpha:0.5];

    self.selectionLayer.fillColor = [fillColor CGColor];

    self.selectionLayer.lineDashPattern = @[@10, @5];
    [self.mainImageView.layer addSublayer:self.selectionLayer];

    CABasicAnimation *dashAnimation;
    dashAnimation = [CABasicAnimation animationWithKeyPath:@"lineDashPhase"];
    [dashAnimation setFromValue:@0.0f];
    [dashAnimation setToValue:@15.0f];
    [dashAnimation setDuration:0.75f];
    dashAnimation.repeatCount = HUGE_VALF;
    [self.selectionLayer addAnimation:dashAnimation forKey:@"linePhase"];


    float left = (float)(box.x - self.croppedPoint.x) * scaleFactor + horizontalPadding;
    float bottom = (float)(box.y - self.croppedPoint.y) * scaleFactor + verticalPadding;
    float right = (float)(box.width - self.croppedPoint.x) * scaleFactor + horizontalPadding;
    float top = (float)(box.height - self.croppedPoint.y) * scaleFactor + verticalPadding;

    CGMutablePathRef path = CGPathCreateMutable();

    CGPathMoveToPoint(path, NULL, left, bottom);
    CGPathAddLineToPoint(path, NULL, left, top);
    CGPathAddLineToPoint(path, NULL, right, top);
    CGPathAddLineToPoint(path, NULL, right, bottom);
    CGPathCloseSubpath(path);

    self.selectionLayer.path = path;
    CGPathRelease(path);

}

- (void)removeAnimatedSelection
{
    [self.selectionLayer removeFromSuperlayer];
    self.selectionLayer = nil;
}

- (IBAction)openMenu:(NSMenuItem *)sender
{
    // present open panel...

    NSString *    extensions = @"tiff/tif/TIFF/TIF/jpg/jpeg/JPG/JPEG";
    NSArray *     types = [extensions pathComponents];

	// Let the user choose an output file, then start the process of writing samples
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setAllowedFileTypes:types];
	[openPanel setCanSelectHiddenExtension:YES];

 	[openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result)
    {
		if (result == NSFileHandlingPanelOKButton)
        {
            // user did select an image...

            NSURL *url = [openPanel URL];
            NSURL *boxUrl = [[url URLByDeletingPathExtension] URLByAppendingPathExtension:@"box"];
            self.mainImageView.image =  [self trimImage:[[NSImage alloc] initByReferencingURL:[openPanel URL]]];
//            self.mainImageView.image =  [[NSImage alloc] initByReferencingURL:[openPanel URL]];
            self.boxes = [[TBEBoxes alloc] initWithFile:[boxUrl path]];


        }
	}];


}

- (NSImage *)trimImage:(NSImage *)image
{
    // TODO: temporary

//    return image;



    CGImageRef imageRef = [image CGImageForProposedRect:nil context:nil hints:nil];

    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);

    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);





//    CFDataRef m_DataRef;
//    m_DataRef = CGDataProviderCopyData(CGImageGetDataProvider(inImage));
//
//    UInt8 * m_PixelBuf = (UInt8 *) CFDataGetBytePtr(m_DataRef);
//
//    size_t width = CGImageGetWidth(inImage);
//    size_t height = CGImageGetHeight(inImage);
//
    CGPoint top,left,right,bottom;

    BOOL breakOut = NO;
    for (NSUInteger x = 0;breakOut==NO && x < width; x++)
    {
        for (NSUInteger y = 0; y < height; y++)
        {
            NSUInteger loc = x + (y * width);
            loc *= 4;
            if (rawData[loc] != 0xff)
            {
                left = CGPointMake(x, y);
                breakOut = YES;
                break;
            }
        }
    }

    breakOut = NO;
    for (int y = 0;breakOut==NO && y < height; y++)
    {
        for (NSUInteger x = 0; x < width; x++)
        {
            NSUInteger loc = x + (y * width);
            loc *= 4;
            if (rawData[loc] != 0xff)
            {
                top = CGPointMake(x, y);
                breakOut = YES;
                break;
            }

        }
    }

    breakOut = NO;
    for (NSInteger y = height-1;breakOut==NO && y >= 0; y--)
    {
        for (NSInteger x = width - 1; x >= 0; x--)
        {
            NSUInteger loc = x + (y * width);
            loc *= 4;
            if (rawData[loc] != 0xff) {
                bottom = CGPointMake(x, y);
                breakOut = YES;
                break;
            }

        }
    }

    breakOut = NO;
    for (NSInteger x = width - 1;breakOut==NO && x >= 0; x--) {

        for (NSInteger y = height - 1; y >= 0; y--) {

            NSUInteger loc = (x + (y * width));
            loc *= 4;
            if (rawData[loc] != 0xff) {
                right = CGPointMake(x, y);
                breakOut = YES;
                break;
            }

        }
    }



//    NSRect cropRect = NSMakeRect(left.x, top.y, right.x - left.x, bottom.y - top.y);
    NSRect cropRect = NSMakeRect(left.x, height - bottom.y - 1, right.x - left.x + 1, bottom.y - top.y + 1);

//    NSUInteger x = 100; NSUInteger y = 0;
//    NSRect cropRect = NSMakeRect(x, y, width-x, height-y);
    NSImage *target = [[NSImage alloc] initWithSize:cropRect.size];

    [target lockFocus];
//    [NSGraphicsContext saveGraphicsState];

    [image drawInRect:NSMakeRect(0,0, cropRect.size.width, cropRect.size.height)
             fromRect:cropRect operation:NSCompositeCopy
             fraction:1.0];

//    [NSGraphicsContext restoreGraphicsState];
    [target unlockFocus];
    free(rawData);

    [image lockFocus];
    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:cropRect];
    [image unlockFocus];

    NSImage *croppedImage = [[NSImage alloc] initWithData:[bitmapRep representationUsingType:NSPNGFileType properties:Nil]];

    self.croppedPoint = NSMakePoint(left.x, height - bottom.y - 1);
    return croppedImage;



    //return target;
}

+ (NSArray*)getRGBAsFromImage:(NSImage*)image atX:(int)xx andY:(int)yy count:(int)count
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:count];

    // First get the image into your data buffer
    CGImageRef imageRef = [image CGImageForProposedRect:nil context:nil hints:nil];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);

    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);

    // Now your rawData contains the image data in the RGBA8888 pixel format.
    NSUInteger byteIndex = (bytesPerRow * yy) + xx * bytesPerPixel;
    for (int ii = 0 ; ii < count ; ++ii)
    {
        CGFloat red   = (rawData[byteIndex]     * 1.0) / 255.0;
        CGFloat green = (rawData[byteIndex + 1] * 1.0) / 255.0;
        CGFloat blue  = (rawData[byteIndex + 2] * 1.0) / 255.0;
        CGFloat alpha = (rawData[byteIndex + 3] * 1.0) / 255.0;
        byteIndex += 4;

        NSColor *acolor = [NSColor colorWithRed:red green:green blue:blue alpha:alpha];
        [result addObject:acolor];
    }
    
    free(rawData);
    
    return result;
}

#pragma mark - NSTableView data source

//- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
//{
//    return 0;
//}
//
//- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
//{
//    return nil;
//}
//
//- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
//{
//    
//}

#pragma mark - window resizing

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize
{
//    NSLog(@"mainImageView frame:%@", NSStringFromRect(self.mainImageView.frame));
//    NSLog(@"mainImageView image size: %@", NSStringFromSize(self.mainImageView.image.size));
//    NSLog(@"height/height * 100: %f", self.mainImageView.frame.size.height / self.mainImageView.image.size.height * 100.0);
//
//    NSLog(@"width/width * 100: %f", self.mainImageView.frame.size.width / self.mainImageView.image.size.width * 100.0);
//

    return frameSize;
}

@end
