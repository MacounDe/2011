//
//  PWGraphicsContext.m
//  PWAppKit
//
//  Created by Frank Illenberger on 09.08.10.
//  Copyright 2010 ProjectWizards. All rights reserved.
//

#import "PWGraphicsContext.h"
#import "PWQuartzColorExtensions.h"


@implementation PWGraphicsContext

#pragma mark Managing lify cycle

- (id) initWithCGContext:(CGContextRef)cgContext
               isFlipped:(BOOL)isFlipped
       isDrawingToScreen:(BOOL)isDrawingToScreen
{
    NSParameterAssert(cgContext);
    if(self = [super init])
    {
        // Do not use GC for cgContexts as they are a _kCFRuntimeResourcefulObject which is not supported by the collector
        cgContext_          = (CGContextRef)CFRetain(cgContext);
        isFlipped_          = isFlipped;
        isDrawingToScreen_  = isDrawingToScreen;
        currentAlpha_       = 1.0;
        backgroundColor_    = CGColorGetConstantColor (kCGColorWhite);
    }
    return self;
}

- (void) finalize
{
    if (cgContext_)
        CFRelease (cgContext_);
    [super finalize];
}

@synthesize isDrawingToScreen = isDrawingToScreen_;
@synthesize isFlipped         = isFlipped_;
@synthesize cgContext         = cgContext_;

#pragma mark Discrete Graphics Helpers

@synthesize backgroundColor = backgroundColor_;

- (CGFloat) pixelPerPoint
{
    // Check validity of the cached scale value.
    // Note: test on MacBook Pro showed this test to be about 20 times faster than the actual calculation of the scale.
    CGAffineTransform ctm = CGContextGetCTM (cgContext_);
    if (ctm.a != lastCTM_.a || ctm.b != lastCTM_.b || ctm.c != lastCTM_.c || ctm.d != lastCTM_.d) {
        lastCTM_ = ctm;
        // Calculate an average scaling factor in the case of non-uniform scaling.
        CGSize deviceSizeX = CGContextConvertSizeToDeviceSpace (cgContext_, CGSizeMake (1.0, 0.0));
        CGSize deviceSizeY = CGContextConvertSizeToDeviceSpace (cgContext_, CGSizeMake (0.0, 1.0));
        pixelPerPoint_ = (PWSizeLength (deviceSizeX) + PWSizeLength (deviceSizeY)) / 2.0;
    }
    return pixelPerPoint_;
}

//- (void) flushPixelPerPoint
//{
//    lastCTM_.a = 0.0;
//}

- (void) screenifyLineColor:(CGColorRef*)inOutColor forWidth:(CGFloat*)inOutWidth snapMode:(PWSnapToPixelMode*)outSnapMode
{
    NSParameterAssert (inOutWidth);
    NSParameterAssert (*inOutWidth >= 0.0);

    if (isDrawingToScreen_) {
        CGFloat pixelPerPoint = self.pixelPerPoint;
        
        CGFloat userLineWidth = *inOutWidth;
        
        CGFloat idealDeviceLineWidth = userLineWidth * pixelPerPoint;
        BOOL isSubDeviceWidth = (idealDeviceLineWidth < 1.0);
        CGFloat realDeviceLineWidth = isSubDeviceWidth ? ceil(idealDeviceLineWidth) : round(idealDeviceLineWidth);
        
        *inOutWidth = realDeviceLineWidth / pixelPerPoint;
        
        if (isSubDeviceWidth && inOutColor) {
            CGFloat lighteningFactor = idealDeviceLineWidth / realDeviceLineWidth;
            // Skip blending if the effect would be neglectable
            if (lighteningFactor < 0.95)
                *inOutColor = PWColorByBlendingColorToColor (backgroundColor_, *inOutColor, lighteningFactor);
        }
        
        if (outSnapMode) {
            double remainder = fmod (realDeviceLineWidth, 2.0);
            *outSnapMode = (remainder == 0.0 || remainder > 1.0) ? PWSnapToFullPixel : PWSnapToHalfPixel;
        }
    } else if (outSnapMode)
        *outSnapMode = PWSnapToPixelOff;
}

- (CGPoint) snapPoint:(CGPoint)point toPixelWithMode:(PWSnapToPixelMode)mode;
{
    return isDrawingToScreen_ ? PWSnapPointToPixel (cgContext_, point, mode, mode, NULL) : point;
}

- (CGPoint)     snapPoint:(CGPoint)point
toPixelWithHorizontalMode:(PWSnapToPixelMode)hMode
             verticalMode:(PWSnapToPixelMode)vMode;
{
    return isDrawingToScreen_ ? PWSnapPointToPixel (cgContext_, point, hMode, vMode, NULL) : point;
}

- (CGPoint)     snapPoint:(CGPoint)point
toPixelWithHorizontalMode:(PWSnapToPixelMode)hMode
             verticalMode:(PWSnapToPixelMode)vMode
             pixelOffsets:(const CGSize*)pixelOffsets
{
    return isDrawingToScreen_ ? PWSnapPointToPixel (cgContext_, point, hMode, vMode, pixelOffsets) : point;
}

- (CGSize) snapSize:(CGSize)size toPixelWithMode:(PWSnapToPixelMode)mode
{
    return isDrawingToScreen_ ? PWSnapSizeToPixel (cgContext_, size, mode, mode, NULL) : size;
}

- (CGSize)       snapSize:(CGSize)size
toPixelWithHorizontalMode:(PWSnapToPixelMode)hMode
             verticalMode:(PWSnapToPixelMode)vMode
{
    return isDrawingToScreen_ ? PWSnapSizeToPixel (cgContext_, size, hMode, vMode, NULL) : size;
}

- (CGSize)       snapSize:(CGSize)size
toPixelWithHorizontalMode:(PWSnapToPixelMode)hMode
             verticalMode:(PWSnapToPixelMode)vMode
             pixelOffsets:(const CGSize*)pixelOffsets
{
    return isDrawingToScreen_ ? PWSnapSizeToPixel (cgContext_, size, hMode, vMode, pixelOffsets) : size;
}

- (CGRect) snapRect:(CGRect)rect toPixelWithMode:(PWSnapToPixelMode)mode
{
    return isDrawingToScreen_ ? PWSnapRectToPixel (cgContext_, rect, mode, mode, NULL) : rect;
}

- (CGRect)       snapRect:(CGRect)rect
toPixelWithHorizontalMode:(PWSnapToPixelMode)hMode
             verticalMode:(PWSnapToPixelMode)vMode
{
    return isDrawingToScreen_ ? PWSnapRectToPixel (cgContext_, rect, hMode, vMode, NULL) : rect;
}

#pragma mark Supporting nestable alpha

@synthesize currentAlpha = currentAlpha_;

- (void)applyAlpha:(CGFloat)alpha
{
    currentAlpha_ *= alpha;
    CGContextSetAlpha(cgContext_, currentAlpha_);
}

- (void)restoreAlphaTo:(CGFloat)alpha
{
    currentAlpha_ = alpha;
}

- (void)applyAlpha:(CGFloat)alpha toBlock:(void(^)(void))block
{
    CGFloat savedAlpha = currentAlpha_;
    
    CGContextSaveGState(cgContext_);
    currentAlpha_ *= alpha;
    CGContextSetAlpha(cgContext_, currentAlpha_);
    
    block();
    
    CGContextRestoreGState(cgContext_);
    currentAlpha_ = savedAlpha;
}

@end
