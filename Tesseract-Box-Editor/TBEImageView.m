//
//  TBEImageView.m
//  Tesseract-Box-Editor
//
//  Created by Erik Larsen on 5/31/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

#import "TBEImageView.h"
#import "TBEBoxEditorViewController.h"

@implementation TBEImageView

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

- (void)mouseDown:(NSEvent *)theEvent
{
    if([self.delegate respondsToSelector:@selector(mouseDown:)])
    {
        [self.delegate mouseDown:theEvent];
    }
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    if([self.delegate respondsToSelector:@selector(mouseDragged:)])
    {
        [self.delegate mouseDragged:theEvent];
    }

}

- (void)mouseUp:(NSEvent *)theEvent
{
    if([self.delegate respondsToSelector:@selector(mouseUp:)])
    {
        [self.delegate mouseUp:theEvent];
    }

}

- (void)keyDown:(NSEvent *)theEvent
{
    if([self.delegate respondsToSelector:@selector(keyDown:)])
    {
        [self.delegate keyDown:theEvent];
    }
}

// As a convenience, accept key presses to redefine a character
- (BOOL)acceptsFirstResponder
{
    return YES;
}


@end
