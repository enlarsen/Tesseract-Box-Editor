//
//  TBEBox.h
//  Tesseract-Box-Editor
//
//  Created by Erik Larsen on 5/27/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TBEBox : NSObject

@property (nonatomic) unichar character;
@property (nonatomic) NSUInteger x;
@property (nonatomic) NSUInteger y;
@property (nonatomic) NSUInteger x2;
@property (nonatomic) NSUInteger y2;
@property (nonatomic) NSUInteger page;
@property (nonatomic, readonly) NSUInteger width;
@property (nonatomic, readonly) NSUInteger height;

@property (nonatomic, strong) NSString *characterAsString;

@end
