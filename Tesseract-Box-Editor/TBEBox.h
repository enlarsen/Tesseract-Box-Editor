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
@property (nonatomic) NSUInteger width;
@property (nonatomic) NSUInteger height;
@property (nonatomic) NSUInteger page;

@property (nonatomic, strong) NSString *characterAsString;

@end
