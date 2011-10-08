//
//  PWGraphicsContext.h
//  PWAppKit
//
//  Created by Frank Illenberger on 09.08.10.
//  Copyright 2010 ProjectWizards. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PWQuartzUtilities.h"


@interface PWGraphicsContext : NSObject 
{
@private
    // Note: cgContext may not be made collectable as it is a _kCFRuntimeResourcefulObject which is not supported by the
    // collector.
    CGContextRef        cgContext_;
    CGFloat             pixelPerPoint_;     // 0.0 for invalid
    CGAffineTransform   lastCTM_;
    CGFloat             currentAlpha_;
    __strong CGColorRef backgroundColor_;
    BOOL                isFlipped_;
    BOOL                isDrawingToScreen_;
}

#pragma mark Managing life cycle

- (id) initWithCGContext:(CGContextRef)cgContext 
               isFlipped:(BOOL)isFlipped
       isDrawingToScreen:(BOOL)isDrawingToScreen;

@property (readonly) CGContextRef   cgContext;
@property (readonly) BOOL           isFlipped;
@property (readonly) BOOL           isDrawingToScreen;

#pragma mark Discrete Graphics Helpers

// The background color is used for blending the line color in -screenifyLineColor:... Default is white.
@property (readwrite)   CGColorRef  backgroundColor;

// 'pixelPerPoint' returns the current scale factor from user to device space, averaged in case of non-uniform scale.
@property (readonly)    CGFloat     pixelPerPoint;

// This method modifies the color for lines depending on the relation between ideal line width and actual line width
// in pixels. The result is (mostly) the same as Qaurtz’ anti-aliasing, but without introducing alpha in the line color.
// The has the advantage that overlapping lines and lines drawn over background remain opaque.
// The passed in color is blended with 'backgroundColor' by the relation between ideal and pixel line width.
// The passed in width is modified to result in an integral number of pixels when set as line width.
// '*outSnapMode' is set to the pixel snap mode which should be used to grid snap the coordinates of the line before
// drawing.
// The method uses 'pixelPerPoint', make sure it is flushed first if necessary.
// For printing the color and line width are not changed and '*outSnapMode' is set to PWSnapToPixelOff.
// 'inOutColor' and 'outSnapMode' are optional.
- (void) screenifyLineColor:(CGColorRef*)inOutColor forWidth:(CGFloat*)inOutWidth snapMode:(PWSnapToPixelMode*)outSnapMode;


// Before drawing, coordinates should be snapped to device pixel positions to avoid unwanted anti-aliasing artefacts.
// Typically, coordinates for fill-only operations are snapped to full pixels (PWSnapToFullPixel).
// Coordinates for stroking should be snapped with the mode returned by -screenifyLineColor: If ever possible, for a
// fill plus stroke combination, both should be done with identical coordinates snapped with the same modes. This is the
// only method to guarantee that fill and border always correctly align on both screen and print.
// See also PWQuartzUtilities.h for additional information, including the use of 'pixelOffsets'.

// Note that all pixel snapping is disabled for printing.

- (CGPoint) snapPoint:(CGPoint)point toPixelWithMode:(PWSnapToPixelMode)mode;

- (CGPoint)     snapPoint:(CGPoint)point
toPixelWithHorizontalMode:(PWSnapToPixelMode)hMode
             verticalMode:(PWSnapToPixelMode)vMode;

- (CGPoint)     snapPoint:(CGPoint)point
toPixelWithHorizontalMode:(PWSnapToPixelMode)hMode
             verticalMode:(PWSnapToPixelMode)vMode
             pixelOffsets:(const CGSize*)pixelOffsets;


- (CGSize) snapSize:(CGSize)size toPixelWithMode:(PWSnapToPixelMode)mode;

- (CGSize)       snapSize:(CGSize)size
toPixelWithHorizontalMode:(PWSnapToPixelMode)hMode
             verticalMode:(PWSnapToPixelMode)vMode;

- (CGSize)       snapSize:(CGSize)size
toPixelWithHorizontalMode:(PWSnapToPixelMode)hMode
             verticalMode:(PWSnapToPixelMode)vMode
             pixelOffsets:(const CGSize*)pixelOffsets;


- (CGRect) snapRect:(CGRect)rect toPixelWithMode:(PWSnapToPixelMode)mode;

- (CGRect)       snapRect:(CGRect)rect
toPixelWithHorizontalMode:(PWSnapToPixelMode)hMode
             verticalMode:(PWSnapToPixelMode)vMode;

// Note: there is no variant of -snapRect: with pixelOffsets because its use should not be necessary for rectangles.


#pragma mark Supporting nestable alpha

// Unfortunately there seems to be no way to access the current alpha value in a Quartz context. This makes it difficult
// to combine alpha values from different stages of drawing.
// The alpha support here is mainly providing storage and some simple methods. A more complete implementation would
// route save and restore of the CG context through this object to save and restore the alpha value, too.
// With this implementation saving and restoring the alpha value in the PWGraphicsContext is left to the client.
//
// Typical usage:
// 
//   CGFloat savedAlpha = context.currentAlpha;
//
//   CGContextSaveGState (ctx);
//   [context applyAlpha:x];
//
//   // Some drawing with combined alpha
//
//   CGContextRestoreGState (ctx);
//   [context restoreAlphaTo:savedAlpha];

@property (readonly) CGFloat currentAlpha;

- (void)applyAlpha:(CGFloat)alpha;      // multiplies 'alpha' on currentAlpha and sets it in CG context
- (void)restoreAlphaTo:(CGFloat)alpha;  // resets currentAlpha to 'alpha' without setting it in CG context

// Applies alpha before executing the block and restores it afterwards. Also saves/restores the context.
- (void)applyAlpha:(CGFloat)alpha toBlock:(void(^)(void))block;

@end
