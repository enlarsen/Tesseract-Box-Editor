//
//  TBEBoxEditorViewController.h
//  Tesseract-Box-Editor
//
//  Created by Erik Larsen on 5/26/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TBECharacterView;
@class TBEBoxes;

@interface TBEBoxEditorViewController : NSViewController <NSTableViewDataSource>

@property (nonatomic, strong) TBEBoxes *boxes;
@property (weak) IBOutlet TBECharacterView *characterView;


@end
