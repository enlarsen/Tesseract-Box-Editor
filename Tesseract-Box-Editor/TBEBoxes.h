//
//  TBEBoxes.h
//  Tesseract-Box-Editor
//
//  Created by Erik Larsen on 5/27/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TBEBoxes : NSObject

- (instancetype)initWithFile:(NSString *)path;
@property (strong, nonatomic) NSMutableArray *boxes; // of TBEBox

@end
