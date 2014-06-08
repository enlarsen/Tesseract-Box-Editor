//
//  TBEBox.m
//  Tesseract-Box-Editor
//
//  Created by Erik Larsen on 5/27/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

#import "TBEBox.h"

@interface TBEBox()


@end

@implementation TBEBox

@synthesize characterAsString = _characterAsString;
@synthesize width = _width;
@synthesize height = _height;

- (NSString *)characterAsString
{
    if(!_characterAsString)
    {
        _characterAsString = [[NSString alloc] initWithCharacters:&_character length:1];
    }
    return _characterAsString;
}

- (void)setCharacterAsString:(NSString *)characterAsString
{
    if(![characterAsString isEqualToString:_characterAsString])
    {
        _character = [characterAsString characterAtIndex:0];
        _characterAsString = nil;
    }

}

- (void)setCharacter:(unichar)character
{
    if(character != _character)
    {
        _characterAsString = nil;
        _character = character;
    }
}

- (NSUInteger)width
{
    return self.x2 - self.x;
}

- (NSUInteger)height
{
    return self.y2 - self.y;
}

- (void)setHeight:(NSUInteger)height
{
    self.y2 = self.y + height;
}

- (void)setWidth:(NSUInteger)width
{
    self.x2 = self.x + width;
}

+ (NSRect)boxToNSRect:(TBEBox *)box
{
    return NSMakeRect((float)box.x, (float)box.y, (float)box.width, (float)box.height);
}

- (NSRect)boxToNSRect
{
    return NSMakeRect((float)self.x, (float)self.y, (float)self.width, (float)self.height);
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"<%@:%p%@>",
            [self class],
            self,
            @{@"x": @(_x),
              @"y": @(_y),
              @"x2": @(_x2),
              @"y2": @(_y2),
              @"width": @(self.width),
              @"height": @(self.height)
              }];

}
@end
