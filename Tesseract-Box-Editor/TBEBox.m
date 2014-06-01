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
@end
