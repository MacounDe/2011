/*
 *  PWQuartzUtilities.h
 *  PWAppKit
 *
 *  Created by Kai Brüning on 8.4.10.
 *  Copyright 2010 ProjectWizards. All rights reserved.
 *
 */

#import <Cocoa/Cocoa.h>

/*
 Collection of utility functions for use with Quartz-based drawing.
 */

// When drawing horizontal or vertical lines, Quartz’ antialiasing results in different line width depending on how
// the line coordinates relate to exact pixel positions. To avoid this, coordinates must be snapped to fixed pixel
// relations (full pixels or half pixels, depending on circumstances) before drawing. The following functions do this
// in a zoom and resolution independent way.
// TODO: write tests.

typedef enum PWRoundToPixelMode {
    PWRoundToPixelOff     = 0,
    PWRoundToPixelDown    = 1,
    PWRoundToPixelUp      = 2,
    PWRoundToPixelNearest = 3
} PWRoundToPixelMode;


// Note: not used in this header, but defined here because it has to two with geometric rounding.
typedef enum PWGranularityRoundingMode {
    PWGranularityRoundToNearest      = 0,   // mathematical rounding, upwards above 0.5
    PWGranularityRoundToPlusInfinity = 1    // always rounding upwards
                                            // other styles to be added when needed
} PWGranularityRoundingMode;


#if defined __cplusplus
extern "C" {
#endif

// The vertical and horizontal snapping modes are either one of three snapping requests or a line width in user space,
// which is used to calculate the required snapping mode.
typedef CGFloat PWSnapToPixelMode;

// Special values for the vertical and horizontal snapping modes.
extern const CGFloat PWSnapToPixelOff;      // no snapping at all
extern const CGFloat PWSnapToFullPixel;     // snap to integral pixel coordinates
extern const CGFloat PWSnapToHalfPixel;     // snap to center pixel coordinates

// If not NULL, the values pointed to by 'pixelOffsets' are added to the result after rounding and before converting
// back to user space. This is sometimes needed to align multiple drawing operations in pixel space. An example would
// be stroking a line which touches a filled rect. In this case one would start with the coordinate used for the
// rectangle, snap it to full pixel (as done for rectangle filling) and than offset by half the line width in pixel.

CGPoint PWSnapPointToPixel (CGContextRef ctx, CGPoint point,
                            PWSnapToPixelMode hMode, PWSnapToPixelMode vMode, const CGSize* pixelOffsets);
CGSize  PWSnapSizeToPixel  (CGContextRef ctx, CGSize  size,
                            PWSnapToPixelMode hMode, PWSnapToPixelMode vMode, const CGSize* pixelOffsets);
CGRect  PWSnapRectToPixel  (CGContextRef ctx, CGRect  rect,
                            PWSnapToPixelMode hMode, PWSnapToPixelMode vMode, const CGRect* pixelOffsets);

CGFloat PWRoundWidthToPixel (CGContextRef ctx, CGFloat width, PWRoundToPixelMode roundMode,
                             PWSnapToPixelMode* outSnapMode);

CGFloat PWRoundHeightToPixel (CGContextRef ctx, CGFloat height, PWRoundToPixelMode roundMode,
                              PWSnapToPixelMode* outSnapMode);

// Calculate the vectorial lenght of 'size'. Optimized to use sqrt() only if necessary.
CGFloat PWSizeLength (CGSize size);

BOOL PWPointEqualToPoint (CGPoint pointA, CGPoint pointB, CGFloat accuracy);

CGPathRef PWContourPath (CGPathRef path, CGFloat contourDistance, BOOL useInnerContour);

void PWContextAddRoundedRect (CGContextRef ctx, CGRect rect, CGFloat ovalWidth, CGFloat ovalHeight);
void PWContextAddRoundedRect2(CGContextRef ctx,
                                  CGRect rect, 
                                  CGFloat topLeftRadius,
                                  CGFloat topRightRadius, 
                                  CGFloat bottomRightRadius,
                                  CGFloat bottomLeftRadius);
    
void PWPathAddRoundedRect (CGMutablePathRef path, const CGAffineTransform* m,
                           CGRect rect, CGFloat ovalWidth, CGFloat ovalHeight);
    
CGPathRef PWPathCreateRectPath (CGRect rect);

// Draw a focus ring for the given rectangle. Snaps the rectangle to pixels and adds a little rounding to the corners
// to make the focus ring look the same as Apple’s.
void PWContextDrawFocusRingForRect (CGContextRef ctx, CGRect rect, BOOL activeAppearance);

// Draw a focus ring along an arbitrary path. 'path' should be snapped to half pixels for best results.
// Low level function, used by PWContextDrawFocusRingForRect.
void PWContextDrawFocusRingForPath (CGContextRef ctx, CGPathRef path, BOOL activeAppearance);

CGGradientRef PWCreateGradientWithTwoColors(CGColorRef startColor, CGColorRef endColor);

#if defined __cplusplus
}   // extern "C"
#endif
