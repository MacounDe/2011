/*
 *  PWQuartzColorExtensions.m
 *  PWAppKit
 *
 *  Created by Kai Brüning on 13.8.10.
 *  Copyright 2010 ProjectWizards. All rights reserved.
 *
 */

#import "PWQuartzColorExtensions.h"


CGFloat PWColorGetLuminescence (CGColorRef color)
{
    NSCParameterAssert (color);
    
    CGFloat luminescence = 0.0;
    
    const CGFloat* components = CGColorGetComponents (color);
    NSCAssert (components, nil);
    
    CGColorSpaceRef colorSpace = CGColorGetColorSpace (color);
    NSCAssert (colorSpace, nil);
    
    CGColorSpaceModel model = CGColorSpaceGetModel (colorSpace);
    
    switch (model) {
        case kCGColorSpaceModelMonochrome:
            luminescence = components[0];
            break;
            
        case kCGColorSpaceModelRGB:
            luminescence = components[0] * 0.3 + components[1] * 0.59 + components[2] * 0.11;
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException
                        format:@"Unsupported color space model %i for PWColorGetLuminescence()", model];
    }
    
    return luminescence;
}

CGFloat PWColorGetSaturation (CGColorRef color)
{
    NSCParameterAssert (color);

    CGFloat saturation = 0.0;
    
    const CGFloat* components = CGColorGetComponents (color);
    NSCAssert (components, nil);
    
    CGColorSpaceRef colorSpace = CGColorGetColorSpace (color);
    NSCAssert (colorSpace, nil);
    
    CGColorSpaceModel model = CGColorSpaceGetModel (colorSpace);
    
    switch (model) {
        case kCGColorSpaceModelMonochrome:
            saturation = 0.0;
            break;
            
        case kCGColorSpaceModelRGB:
        {
            CGFloat max = MAX(MAX(components[0], components[1]), components[2]);
            CGFloat min = MIN(MIN(components[0], components[1]), components[2]);
            saturation = (max == 0.0) ? 0.0 : (max - min)/max;
            break;
        }
            
        default:
            [NSException raise:NSInternalInconsistencyException
                        format:@"Unsupported color space model %i for PWColorGetSaturation()", model];
    }
    
    return saturation;
    
}

void PWColorGetRGBComponents (CGColorRef color, CGFloat outComponents[3])
{
    NSCParameterAssert (color);
    NSCParameterAssert (outComponents);
    
    const CGFloat* components = CGColorGetComponents (color);
    NSCAssert (components, nil);
    
    CGColorSpaceRef colorSpace = CGColorGetColorSpace (color);
    NSCAssert (colorSpace, nil);
    
    CGColorSpaceModel model = CGColorSpaceGetModel (colorSpace);
    
    switch (model) {
        case kCGColorSpaceModelMonochrome:
            outComponents[0] = outComponents[1] = outComponents[2] = components[0];
            break;
            
        case kCGColorSpaceModelRGB:
            outComponents[0] = components[0];
            outComponents[1] = components[1];
            outComponents[2] = components[2];
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException
                        format:@"Unsupported color space model %i for PWColorGetRGBComponents()", model];
    }
}

void PWColorGetBlendedRGBComponents (CGColorRef color1, CGColorRef color2, CGFloat fraction, CGFloat outComponents[4])
{
    NSCParameterAssert (fraction >= 0.0 && fraction <= 1.0);

    CGFloat components1[4];
    PWColorGetRGBComponents (color1, components1);
    components1[3] = CGColorGetAlpha (color1);

    CGFloat components2[4];
    PWColorGetRGBComponents (color2, components2);
    components2[3] = CGColorGetAlpha (color2);
    
    for (int i = 0; i < 4; ++i)
        outComponents[i] = (1.0 - fraction) * components1[i] + fraction * components2[i];
}

CGColorRef PWColorByBlendingColorToColor(CGColorRef color1, CGColorRef color2, CGFloat fraction)
{
    CGFloat c[4];
    PWColorGetBlendedRGBComponents(color1, color2, fraction, c);
    return (CGColorRef)CFMakeCollectable(CGColorCreateGenericRGB(c[0], c[1], c[2], c[3]));
}

CGColorRef PWColorWithAlphaComponent(CGColorRef color, CGFloat alpha)
{
    CGFloat c[4];
    PWColorGetRGBComponents(color, c);
    return (CGColorRef)CFMakeCollectable(CGColorCreateGenericRGB(c[0], c[1], c[2], alpha));
}

CGColorRef PWRGBColorWithColor(CGColorRef color)
{
    NSUInteger count = CGColorGetNumberOfComponents(color);    
    if(count == 2)
    {
        CGFloat* colorComponents = (CGFloat *)CGColorGetComponents(color);
        CGFloat gray = colorComponents[0];
        return (CGColorRef)CFMakeCollectable(CGColorCreateGenericRGB(gray, gray, gray, colorComponents[1]));
    }        
    return color;
}

