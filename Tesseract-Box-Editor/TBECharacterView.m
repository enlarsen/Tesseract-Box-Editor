//
//  TBECharacterView.m
//  Tesseract-Box-Editor
//
//  Created by Erik Larsen on 5/31/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

#import "TBECharacterView.h"

@interface TBECharacterView()



@end

@implementation TBECharacterView

+ (NSSet *)keyPathsForValuesAffectingHeight
{
    return [NSSet setWithObjects:NSStringFromSelector(@selector(updateCharacter:)), nil];
}

+ (NSSet *)keyPathsForValuesAffectingWidth
{
    return [NSSet setWithObjects:NSStringFromSelector(@selector(updateCharacter:)), nil];
}

#pragma mark - properties

- (NSUInteger)width
{
    return self.image.size.width;
}

- (NSUInteger)height
{
    return self.image.size.height;
}

- (void)awakeFromNib
{
    self.imageScaling = NSImageScaleProportionallyUpOrDown;   
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)updateCharacter:(NSImage *)image withCropPoint:(NSPoint)cropPoint
{
// For now, just generate an NSImage. Later, draw border around each pixel, give them
// gradiant shading, etc.

//    NSImage *image = [[NSImage alloc] initWithSize:size];
//    [image lockFocus];
//    [[NSColor redColor] set];
//    NSRectFill(NSMakeRect(0, 0, size.width, size.height));
//
//    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0, 0, size.width, size.height)];
//    [image unlockFocus];
//    [image addRepresentation:bitmap];
//
//
//
//    NSLog(@"Done");
//
//
//    [characterData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        NSColor *color = obj;
//        [bitmap setColor:color atX:(int)(idx % (int)size.width) y:(int)(idx / (int)size.width)];
//    }];

    self.image = image;
    NSLog(@"image size: %@", NSStringFromSize(image.size));
    NSLog(@"characterView frame: %@", NSStringFromRect(self.frame));
    NSLog(@"crop point: %@", NSStringFromPoint(cropPoint));

}
/*
- (void)setupAnimatedSelectionWithBox:(TBEBox *)box
{
    float verticalPadding = 0.0;
    float horizontalPadding = 0.0;
    float untransformedVerticalPadding = 0.0;
    float untransformedHorizontalPadding = 0.0;
    float scaleFactor = 1.0;
    float horizontalScaleFactor = self.mainImageView.frame.size.width /
    self.mainImageView.image.size.width;
    float verticalScaleFactor =  self.mainImageView.frame.size.height /
    self.mainImageView.image.size.height;



    NSLog(@"horizontal scale: %f, vertical scale %f", horizontalScaleFactor, verticalScaleFactor);

    if(verticalScaleFactor - horizontalScaleFactor < 0)
    {
        scaleFactor = verticalScaleFactor;

        float width = self.mainImageView.image.size.width * scaleFactor;
        horizontalPadding = (self.mainImageView.frame.size.width - width) / 2.0;
        untransformedHorizontalPadding = (self.mainImageView.frame.size.width -
                                          self.mainImageView.image.size.width) / 2.0;
    }
    if(horizontalScaleFactor - verticalScaleFactor < 0)
    {
        scaleFactor = horizontalScaleFactor;

        float height = self.mainImageView.image.size.height * scaleFactor;
        verticalPadding = (self.mainImageView.frame.size.height - height) / 2.0;
        untransformedVerticalPadding = (self.mainImageView.frame.size.height -
                                        self.mainImageView.image.size.height) / 2.0;
    }

    NSLog(@"Horizontal padding: %f, vertical padding: %f", horizontalPadding, verticalPadding);
    NSLog(@"Untransformed horizontal padding: %f, untransformed vertical padding %f", untransformedHorizontalPadding, untransformedVerticalPadding);

    self.selectionLayer = [CAShapeLayer layer];
    //    self.selectionLayer.anchorPoint = CGPointMake(1.0, 1.0);

    self.selectionLayer.lineWidth = 0.5;
    self.selectionLayer.strokeColor = [[NSColor redColor] CGColor];
    NSColor *fillColor = [NSColor colorWithDeviceRed:1.0 green:1.0 blue:0.0 alpha:0.5];

    self.selectionLayer.fillColor = [fillColor CGColor];

    self.selectionLayer.lineDashPattern = @[@10, @5];
    [self.mainImageView.layer addSublayer:self.selectionLayer];

    CABasicAnimation *dashAnimation;
    dashAnimation = [CABasicAnimation animationWithKeyPath:@"lineDashPhase"];
    [dashAnimation setFromValue:@0.0f];
    [dashAnimation setToValue:@15.0f];
    [dashAnimation setDuration:0.75f];
    dashAnimation.repeatCount = HUGE_VALF;
    [self.selectionLayer addAnimation:dashAnimation forKey:@"linePhase"];


    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DTranslate(transform, horizontalPadding, verticalPadding, 0.0);
    transform = CATransform3DScale(transform, scaleFactor, scaleFactor, 1.0);
    transform = CATransform3DTranslate(transform, -self.croppedPoint.x, -self.croppedPoint.y, 0.0);


    //  transform = CATransform3DTranslate(transform, untransformedHorizontalPadding, untransformedVerticalPadding, 0);

    //    float left = (float)(box.x - self.croppedPoint.x) * scaleFactor + horizontalPadding;
    //    float bottom = (float)(box.y - self.croppedPoint.y) * scaleFactor + verticalPadding;
    //    float right = (float)(box.x2 - self.croppedPoint.x) * scaleFactor + horizontalPadding;
    //    float top = (float)(box.y2 - self.croppedPoint.y) * scaleFactor + verticalPadding;

    float left = (float)box.x; // - self.croppedPoint.x;
    float bottom = (float)box.y; // - self.croppedPoint.y;
    float right = (float)box.x2; // - self.croppedPoint.x;
    float top = (float)box.y2; // - self.croppedPoint.y;

    NSLog(@"Cropped point: %@", NSStringFromPoint(self.croppedPoint));

    self.leftHandle = NSMakePoint(left, bottom + (top - bottom) / 2);
    self.rightHandle = NSMakePoint(right, bottom + (top - bottom) / 2);
    self.topHandle = NSMakePoint(left + (right - left) / 2, top);
    self.bottomHandle = NSMakePoint(left + (right - left) / 2, bottom);

    NSLog(@"Left handle: %@", NSStringFromPoint(self.leftHandle));
    NSLog(@"Right handle: %@", NSStringFromPoint(self.rightHandle));
    NSLog(@"Top handle: %@", NSStringFromPoint(self.topHandle));
    NSLog(@"Bottom handle: %@", NSStringFromPoint(self.bottomHandle));

    self.selectionLayer.transform = transform;
    NSLog(@"Transformation: %f %f %f %f", transform.m11, transform.m22, transform.m41, transform.m42);
    NSLog(@"Left handle transformed: %@", NSStringFromPoint(CGPointApplyAffineTransform(self.leftHandle, CATransform3DGetAffineTransform(transform))));

    //    [self drawHandle:self.leftHandle];
    //    [self drawHandle:self.rightHandle];
    //    [self drawHandle:self.topHandle];
    //    [self drawHandle:self.bottomHandle];


    CGMutablePathRef path = CGPathCreateMutable();

    CGPathMoveToPoint(path, NULL, left, bottom);
    CGPathAddLineToPoint(path, NULL, left, top);
    CGPathAddLineToPoint(path, NULL, right, top);
    CGPathAddLineToPoint(path, NULL, right, bottom);
    CGPathCloseSubpath(path);

    self.selectionLayer.path = path;
    CGPathRelease(path);


}

- (void)drawHandle:(NSPoint)point
{
    CGFloat size = 1.0; // half the width of the selection handle
    CGMutablePathRef path = CGPathCreateMutable();

    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.lineWidth = 0.5;
    layer.strokeColor = [[NSColor redColor] CGColor];
    layer.fillColor = [[NSColor redColor] CGColor];
    layer.transform = self.selectionLayer.transform;

    [self.mainImageView.layer addSublayer:layer];


    CGPathMoveToPoint(path, NULL, point.x - size, point.y - size);
    CGPathAddLineToPoint(path, NULL, point.x - size, point.y + size);
    CGPathAddLineToPoint(path, NULL, point.x + size, point.y + size);
    CGPathAddLineToPoint(path, NULL, point.x + size, point.y - size);
    CGPathCloseSubpath(path);

    layer.path = path;

    CGPathRelease(path);

    [self.selectionHandleLayers addObject:layer];
    return;
}

- (void)removeAnimatedSelection
{
    [self.selectionLayer removeFromSuperlayer];
    [self.selectionHandleLayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CAShapeLayer *layer = obj;
        [layer removeFromSuperlayer];
    }];
    
    [self.selectionHandleLayers removeAllObjects];
    
    self.selectionLayer = nil;
}

*/

@end
