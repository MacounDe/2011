/*
 *  PWQuartzColorExtensions.h
 *  PWAppKit
 *
 *  Created by Kai Brüning on 13.8.10.
 *  Copyright 2010 ProjectWizards. All rights reserved.
 *
 */

#import <ApplicationServices/ApplicationServices.h>

#if defined __cplusplus
extern "C" {
#endif

// The luminescence of a color is the value which would result when converting the color to the gray color space.
// 'color' must use a monochrome or RGB color space, else an exception is thrown.
CGFloat PWColorGetLuminescence (CGColorRef color);

// The saturation of a color is the value S when transforming the color into the HSV colorspace. 
// 'color' must use a monochrome or RGB color space, else an exception is thrown.
CGFloat PWColorGetSaturation (CGColorRef color);

// Return RGB components for 'color'.
// 'color' must use a monochrome or RGB color space, else an exception is thrown.
void PWColorGetRGBComponents (CGColorRef color, CGFloat outComponents[3]);

// Blend using an RGB color space. Both colors are converted into an RGB color space, and they are blended by taking
// (1 - fraction) of color1 and fraction of color2. That is, fraction == 0 uses color1 only and fraction == 1 color2.
// The result is returned as RGB components plus alpha.
void PWColorGetBlendedRGBComponents (CGColorRef color1, CGColorRef color2, CGFloat fraction, CGFloat outComponents[4]);
    
// Convenience method. Uses PWColorGetBlendedRGBComponents for blending but returns a collectable color ref.
CGColorRef PWColorByBlendingColorToColor(CGColorRef color1, CGColorRef color2, CGFloat fraction);

// Returns a collectable color in RGB color space that equiivalent color components, but the specified alpha component.    
CGColorRef PWColorWithAlphaComponent(CGColorRef color, CGFloat alpha);

// Returns a collectable color in RGB color space using the components of color.    
CGColorRef PWRGBColorWithColor(CGColorRef color);
    
    
#if defined __cplusplus
}   // extern "C"
#endif
