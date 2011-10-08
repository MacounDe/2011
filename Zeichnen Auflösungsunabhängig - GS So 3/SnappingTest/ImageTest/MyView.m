//
//  MyView.m
//  ImageTest
//
//  Created by Frank Illenberger on 22.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MyView.h"
#import "PWGraphicsContext.h"
#import <QuartzCore/QuartzCore.h>

@implementation MyView
{
    CGColorRef  lineColor_;
    CGColorRef  bgColor_;
}

@synthesize lineWidth           = lineWidth_;
@synthesize posX                = posX_;
@synthesize posY                = posY_;
@synthesize boxSize             = boxSize_;
@synthesize drawsWithSnapping   = drawsWithSnapping_;
@synthesize animatesLineWidth   = animatesLineWidth_;
@synthesize animatesPosition    = animatesPosition_;
@synthesize animatesSize        = animatesSize_;

- (void)resetGeometry
{
    self.lineWidth  = 3.0;
    self.posX       = 20.0;
    self.posY       = 20.0;
    self.boxSize    = 160.0;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    lineColor_ = CGColorCreateGenericRGB(0, 0, 0, 1.0);
    bgColor_   = CGColorCreateGenericRGB(1, 1, 1, 1.0);
    self.animatesPosition = YES;
    self.animatesSize     = YES;
    [self resetGeometry];
}

- (IBAction)startAnimation:(id)sender
{
    [self resetGeometry];
    [[NSAnimationContext currentContext] setDuration:10.0f];
    if(animatesLineWidth_)
        [self.animator setLineWidth:45.4];
    if(animatesPosition_)
        [self.animator setPosX:111.3];
    if(animatesSize_)
        [self.animator setBoxSize:354.4];   
}

- (void)drawRect:(NSRect)dirtyRect
{    
    NSGraphicsContext* gc = [NSGraphicsContext currentContext];
    CGContextRef ctx = gc.graphicsPort;
    PWGraphicsContext* context = [[PWGraphicsContext alloc] initWithCGContext:ctx 
                                                                    isFlipped:NO 
                                                            isDrawingToScreen:YES];
    
    CGContextSetFillColorWithColor(ctx, bgColor_);
    CGContextFillRect(ctx, dirtyRect);
    
    NSUInteger numberOfBoxes = 6;
    for(NSUInteger index=0; index<numberOfBoxes; index++)
    {   
        PWSnapToPixelMode snapMode;
        CGFloat factor = (CGFloat)(numberOfBoxes - index) / (CGFloat)numberOfBoxes;
        CGFloat lineWidth = lineWidth_ * factor;
        CGColorRef lineColor = lineColor_;
        CGFloat size = boxSize_ * factor;
        CGRect rect = CGRectMake(posX_, posY_, size, size);
        if(drawsWithSnapping_)
        {
            [context screenifyLineColor:&lineColor forWidth:&lineWidth snapMode:&snapMode];
            rect = [context snapRect:rect toPixelWithMode:snapMode];
        }

        CGContextSetStrokeColorWithColor(ctx, lineColor);
        CGContextSetLineWidth(ctx, lineWidth);
        CGContextStrokeRect(ctx, rect);
        
        CGFloat diagonalFactor = (CGFloat)(numberOfBoxes - index - 1) / (CGFloat)numberOfBoxes;
        CGPoint diagonalStart = CGPointMake(posX_ + boxSize_ * diagonalFactor, posY_ + boxSize_ * diagonalFactor);
        CGPoint diagonalEnd = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
        
        CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx, diagonalStart.x, diagonalStart.y);
        CGContextAddLineToPoint(ctx, diagonalEnd.x, diagonalEnd.y);
        CGContextStrokePath(ctx);
    }
}

+ (id)defaultAnimationForKey:(NSString *)key {
    return [CABasicAnimation animation];
}

- (void)setLineWidth:(CGFloat)lineWidth
{
    lineWidth_ = lineWidth;
    [self setNeedsDisplay:YES];
}

- (void)setPosX:(CGFloat)pos
{
    posX_= pos;
    [self setNeedsDisplay:YES];
}

- (void)setBoxSize:(CGFloat)size
{
    boxSize_ = size;
    [self setNeedsDisplay:YES];
}

- (void)setDrawsWithSnapping:(BOOL)drawsWithSnapping
{
    drawsWithSnapping_ = drawsWithSnapping;
    [self setNeedsDisplay:YES];
}
@end
