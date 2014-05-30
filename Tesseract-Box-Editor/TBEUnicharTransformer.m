//
//  TBEUnicharTransformer.m
//  Tesseract-Box-Editor
//
//  Created by Erik Larsen on 5/29/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

#import "TBEUnicharTransformer.h"

@implementation TBEUnicharTransformer

+ (Class)transformedValueClass
{
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (instancetype)transformedValue:(id)value
{
    return nil;
}

- (id)reverseTransformedValue:(id)value
{
    return nil;
}

@end
