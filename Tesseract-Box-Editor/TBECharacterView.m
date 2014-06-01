//
//  TBECharacterView.m
//  Tesseract-Box-Editor
//
//  Created by Erik Larsen on 5/31/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

#import "TBECharacterView.h"

@implementation TBECharacterView

- (void)awakeFromNib
{
    self.imageScaling = NSImageScaleProportionallyUpOrDown;   
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)updateCharacter:(NSImage *)image
{
// For now, just generate an NSImage. Later, draw border around each pixel, give them
// gradiant shading, etc.

//    NSImage *image = [[NSImage alloc] initWithSize:size];
//    [image lockFocus];
//    [[NSColor redColor] set];
//    NSRectFill(NSMakeRect(0, 0, size.width, size.height));
//
//    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0, 0, size.width, size.height)];
//    [image unlockFocus];
//    [image addRepresentation:bitmap];
//
//
//
//    NSLog(@"Done");
//
//
//    [characterData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        NSColor *color = obj;
//        [bitmap setColor:color atX:(int)(idx % (int)size.width) y:(int)(idx / (int)size.width)];
//    }];

    self.image = image;
}

@end
