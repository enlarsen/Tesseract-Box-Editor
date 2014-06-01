//
//  TBEBoxes.m
//  Tesseract-Box-Editor
//
//  Created by Erik Larsen on 5/27/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

#import "TBEBoxes.h"
#import "TBEBox.h"

@interface TBEBoxes()

@property (copy, nonatomic) NSString *path;

@end

@implementation TBEBoxes

#pragma init

- (instancetype)initWithFile:(NSString *)path
{
    self = [super init];
    if(self)
    {
        self.path = path;
        [self parseBoxFile];
    }
    return self;
}

#pragma mark - properties

- (NSMutableArray *)boxes
{
    if(!_boxes)
    {
        _boxes = [[NSMutableArray alloc] init];
    }
    return _boxes;
}


#pragma mark - index access methods

- (TBEBox *)objectAtIndexedSubscript:(NSUInteger)index
{
    return self.boxes[index];
}

- (void)setObject:(TBEBox *)move atIndexedSubscript:(NSUInteger)index
{
    self.boxes[index] = move;
}

- (void)parseBoxFile
{
    NSError *error = nil;
    NSStringEncoding encoding = 0;
    NSString *fileText;


    fileText = [NSString stringWithContentsOfFile:self.path
                                          usedEncoding:&encoding
                                                 error:&error];
    // Encoding 0x0000 means encoding can't be determined, so try again with Win 1252
    if(encoding == 0)
    {
        fileText = nil;
        error = nil;
        encoding = NSWindowsCP1252StringEncoding;
        fileText = [NSString stringWithContentsOfFile:self.path
                                                  encoding:encoding
                                                     error:&error];
    }

    [fileText enumerateLinesUsingBlock:^(NSString *line, BOOL *stop)
    {
        NSScanner *scanner = [[NSScanner alloc] initWithString:line];
        scanner.caseSensitive = YES;
        scanner.charactersToBeSkipped = nil;

        TBEBox *box = [[TBEBox alloc] init];
        NSString *characterAsString;
        int intValue;

        [scanner scanUpToString:@" " intoString:&characterAsString];
        box.character = [characterAsString characterAtIndex:0];
        scanner.charactersToBeSkipped = [NSCharacterSet whitespaceCharacterSet];
        [scanner scanInt:&intValue];
        box.x = intValue;
        [scanner scanInt:&intValue];
        box.y = intValue;
        [scanner scanInt:&intValue];
        box.x2 = intValue;
        [scanner scanInt:&intValue];
        box.y2 = intValue;
        [scanner scanInt:&intValue];
        box.page = intValue;
        [self.boxes addObject:box];
    }];

}

- (void)writeBoxFile
{

}

@end
