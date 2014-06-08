//
//  TBECharacterView.h
//  Tesseract-Box-Editor
//
//  Created by Erik Larsen on 5/31/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TBECharacterView : NSImageView

@property (nonatomic) NSUInteger width;
@property (nonatomic) NSUInteger height;

- (void)updateCharacter:(NSImage *)image withCropPoint:(NSPoint)cropPoint andCharacterRect:(NSRect)box;

@end
