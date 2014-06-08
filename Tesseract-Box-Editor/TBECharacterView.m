//
//  TBECharacterView.m
//  Tesseract-Box-Editor
//
//  Created by Erik Larsen on 5/31/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//
@import QuartzCore;

#import "TBECharacterView.h"

@interface TBECharacterView()

@property (nonatomic, strong) CAShapeLayer *selectionLayer;
@property (nonatomic) NSPoint cropPoint;
@property (nonatomic) NSPoint leftHandle;
@property (nonatomic) NSPoint rightHandle;
@property (nonatomic) NSPoint topHandle;
@property (nonatomic) NSPoint bottomHandle;
@property (nonatomic) NSMutableArray *selectionHandleLayers;

@property (nonatomic) float scaleFactor;

@property (nonatomic) NSRect box;

@property (nonatomic) NSPoint startPoint;

@end

@implementation TBECharacterView



//+ (NSSet *)keyPathsForValuesAffectingHeight
//{
//    return [NSSet setWithObjects:NSStringFromSelector(@selector(updateCharacter:)), nil];
//}
//
//+ (NSSet *)keyPathsForValuesAffectingWidth
//{
//    return [NSSet setWithObjects:NSStringFromSelector(@selector(updateCharacter:)), nil];
//}

#pragma mark - properties

- (NSUInteger)width
{
    return self.image.size.width;
}

- (NSUInteger)height
{
    return self.image.size.height;
}

- (NSMutableArray *)selectionHandleLayers
{
    if(!_selectionHandleLayers)
    {
        _selectionHandleLayers = [NSMutableArray array];
    }
    return _selectionHandleLayers;
}

- (void)awakeFromNib
{
    self.imageScaling = NSImageScaleProportionallyUpOrDown;
    self.startPoint = CGPointZero;
    
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

- (void)updateCharacter:(NSImage *)image withCropPoint:(NSPoint)cropPoint andCharacterRect:(NSRect)box
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
    self.cropPoint = cropPoint;
    self.box = box;
    NSLog(@"image size: %@", NSStringFromSize(image.size));
    NSLog(@"characterView frame: %@", NSStringFromRect(self.frame));
    NSLog(@"crop point: %@", NSStringFromPoint(cropPoint));

    [self removeAnimatedSelection];
    [self setupAnimatedSelectionWithRect:self.box];

}

- (void)setupAnimatedSelectionWithRect:(NSRect)box
{
    float verticalPadding = 0.0;
    float horizontalPadding = 0.0;
    float untransformedVerticalPadding = 0.0;
    float untransformedHorizontalPadding = 0.0;
    self.scaleFactor = 1.0;
    float horizontalScaleFactor = self.frame.size.width /
        self.image.size.width;
    float verticalScaleFactor =  self.frame.size.height /
        self.image.size.height;



    NSLog(@"horizontal scale: %f, vertical scale %f", horizontalScaleFactor, verticalScaleFactor);

    if(verticalScaleFactor - horizontalScaleFactor < 0)
    {
        self.scaleFactor = verticalScaleFactor;

        float width = self.image.size.width * self.scaleFactor;
        horizontalPadding = (self.frame.size.width - width) / 2.0;
        untransformedHorizontalPadding = (self.frame.size.width -
                                          self.image.size.width) / 2.0;
    }
    if(horizontalScaleFactor - verticalScaleFactor < 0)
    {
        self.scaleFactor = horizontalScaleFactor;

        float height = self.image.size.height * self.scaleFactor;
        verticalPadding = (self.frame.size.height - height) / 2.0;
        untransformedVerticalPadding = (self.frame.size.height -
                                        self.image.size.height) / 2.0;
    }

    NSLog(@"Horizontal padding: %f, vertical padding: %f", horizontalPadding, verticalPadding);
    NSLog(@"Untransformed horizontal padding: %f, untransformed vertical padding %f", untransformedHorizontalPadding, untransformedVerticalPadding);

    self.selectionLayer = [CAShapeLayer layer];
    //    self.selectionLayer.anchorPoint = CGPointMake(1.0, 1.0);

    self.selectionLayer.lineWidth = 0.2;
    self.selectionLayer.strokeColor = [[NSColor grayColor] CGColor];
//    NSColor *fillColor = [NSColor colorWithDeviceRed:1.0 green:1.0 blue:0.0 alpha:0.5];

    self.selectionLayer.fillColor = [[NSColor clearColor] CGColor];

    self.selectionLayer.lineDashPattern = @[@1, @1];
    [self.layer addSublayer:self.selectionLayer];

    CABasicAnimation *dashAnimation;
    dashAnimation = [CABasicAnimation animationWithKeyPath:@"lineDashPhase"];
    [dashAnimation setFromValue:@0.0f];
    [dashAnimation setToValue:@15.0f];
    [dashAnimation setDuration:10.0f];
    dashAnimation.repeatCount = HUGE_VALF;
    [self.selectionLayer addAnimation:dashAnimation forKey:@"linePhase"];


    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DTranslate(transform, horizontalPadding, verticalPadding, 0.0);
    transform = CATransform3DScale(transform, self.scaleFactor, self.scaleFactor, 1.0);
    transform = CATransform3DTranslate(transform, -self.cropPoint.x, -self.cropPoint.y, 0.0);


    //  transform = CATransform3DTranslate(transform, untransformedHorizontalPadding, untransformedVerticalPadding, 0);

    //    float left = (float)(box.x - self.croppedPoint.x) * scaleFactor + horizontalPadding;
    //    float bottom = (float)(box.y - self.croppedPoint.y) * scaleFactor + verticalPadding;
    //    float right = (float)(box.x2 - self.croppedPoint.x) * scaleFactor + horizontalPadding;
    //    float top = (float)(box.y2 - self.croppedPoint.y) * scaleFactor + verticalPadding;


    float left = (float)box.origin.x; // - self.croppedPoint.x;
    float bottom = (float)box.origin.y; // - self.croppedPoint.y;
    float right = (float)box.origin.x + box.size.width; // - self.croppedPoint.x;
    float top = (float)box.origin.y + box.size.height; // - self.croppedPoint.y;

    NSLog(@"Cropped point: %@", NSStringFromPoint(self.cropPoint));

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

    [self drawHandle:self.leftHandle];
    [self drawHandle:self.rightHandle];
    [self drawHandle:self.topHandle];
    [self drawHandle:self.bottomHandle];


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
    CGFloat size = 0.5f; // half the width of the selection handle
    CGMutablePathRef path = CGPathCreateMutable();

    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.lineWidth = 0.1;
    layer.strokeColor = [[NSColor blueColor] CGColor];
    layer.fillColor = [[NSColor blueColor] CGColor];
    layer.transform = self.selectionLayer.transform;

    [self.layer addSublayer:layer];


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

- (void)mouseDown:(NSEvent *)theEvent
{

    NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    CGAffineTransform transform = CGAffineTransformInvert(CATransform3DGetAffineTransform(self.selectionLayer.transform));
    [self.selectionHandleLayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         CAShapeLayer *layer = obj;

         if(CGPathContainsPoint(layer.path, &transform, point, NO))
         {
             self.startPoint = CGPointApplyAffineTransform(point, transform);
         }
     }];

    // TODO: also need to check whether they clicked inside the bounds of the selection
    // rectangle and if so, move the selection rectangle around


}

- (void)mouseUp:(NSEvent *)theEvent
{
    self.startPoint = CGPointZero; // Indicates we're not tracking anything.
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
//    CGAffineTransform transform = CGAffineTransformMakeScale(self.scaleFactor, self.scaleFactor);
//    CGAffineTransform transform = CGAffineTransformInvert(CATransform3DGetAffineTransform(self.layer.transform));

    CGAffineTransform transform = CGAffineTransformInvert(CATransform3DGetAffineTransform(self.selectionLayer.transform));
//    NSPoint transformedPoint = CGPointApplyAffineTransform(point, transform);
//    NSPoint transformedLeftHandle = CGPointApplyAffineTransform(self.leftHandle, transform);

    [self.selectionHandleLayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        CAShapeLayer *layer = obj;

        if(CGPathContainsPoint(layer.path, &transform, point, NO))
        {
            NSLog(@"Found handle");
        }
    }];

//    NSLog(@"Drag point: %@", NSStringFromPoint(point));
//    NSLog(@"Transformed drag point: %@", NSStringFromPoint(transformedPoint));
//    NSLog(@"Left handle: %@", NSStringFromPoint(self.leftHandle));
//    NSLog(@"Transformed left handle: %@", NSStringFromPoint(transformedLeftHandle));

}

@end
