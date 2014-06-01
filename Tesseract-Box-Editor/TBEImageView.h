//
//  TBEImageView.h
//  Tesseract-Box-Editor
//
//  Created by Erik Larsen on 5/31/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TBEBoxEditorViewController;

@interface TBEImageView : NSImageView

@property (nonatomic, weak) IBOutlet TBEBoxEditorViewController *delegate;

@end
