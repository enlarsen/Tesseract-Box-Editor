//
//  TBEBoxView.m
//  Tesseract-Box-Editor
//
//  Created by Erik Larsen on 5/29/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

#import "TBEBoxView.h"

@implementation TBEBoxView

- (NSNumber *)x
{
    return @4;
}

- (NSNumber *)y
{
    return @5;
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

@end
