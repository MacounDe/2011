/*
 *  PWQuartzUtilities.m
 *  PWAppKit
 *
 *  Created by Kai Brüning on 8.4.10.
 *  Copyright 2010 ProjectWizards. All rights reserved.
 *
 */

#import "PWQuartzUtilities.h"

const CGFloat PWSnapToPixelOff  =  0.0;
const CGFloat PWSnapToFullPixel = -1.0;
const CGFloat PWSnapToHalfPixel = -2.0;

CGFloat PWSizeLength (CGSize size)
{
    if (size.width == 0.0)
        return fabs (size.height);
    if (size.height == 0.0)
        return fabs (size.width);
    return sqrt (size.width * size.width + size.height * size.height);
}

BOOL PWPointEqualToPoint (CGPoint pointA, CGPoint pointB, CGFloat accuracy)
{
    if(CGPointEqualToPoint(pointA, pointB))
        return YES;
    
    CGFloat squaredHorizontalDistance = (pointA.x - pointB.x)*(pointA.x - pointB.x);
    CGFloat squaredVerticalDistance   = (pointA.y - pointB.y)*(pointA.y - pointB.y);
    
    return (squaredHorizontalDistance + squaredVerticalDistance) < accuracy*accuracy;
}

static void ResolveSnapModes (CGContextRef ctx, PWSnapToPixelMode* inOutHMode, PWSnapToPixelMode* inOutVMode)
{
    NSCParameterAssert (inOutHMode);
    NSCParameterAssert (inOutVMode);
    
    CGSize lineWidths = CGSizeZero;
    
    BOOL hasLineWidths = NO;
    if (*inOutHMode > 0.0) {
        lineWidths.width = *inOutHMode;
        hasLineWidths = YES;
    } else
        NSCAssert (*inOutHMode == PWSnapToPixelOff || *inOutHMode == PWSnapToFullPixel || *inOutHMode == PWSnapToHalfPixel, nil);

    if (*inOutVMode > 0.0) {
        lineWidths.height = *inOutVMode;
        hasLineWidths = YES;
    } else
        NSCAssert (*inOutVMode == PWSnapToPixelOff || *inOutVMode == PWSnapToFullPixel || *inOutVMode == PWSnapToHalfPixel, nil);
    
    if (hasLineWidths) {
        lineWidths = CGContextConvertSizeToDeviceSpace (ctx, lineWidths);
        
        if (*inOutHMode > 0.0) {
//            <= 1.0 -> half
//            <= 2.0 -> full
//            <= 3.0 -> half
//            ....
        	double remainder = fmod (fabs (lineWidths.width), 2.0);
            *inOutHMode = (remainder == 0.0 || remainder > 1.0) ? PWSnapToFullPixel : PWSnapToHalfPixel;
        }
        if (*inOutVMode > 0.0) {
        	double remainder = fmod (fabs (lineWidths.height), 2.0);
            *inOutVMode = (remainder == 0.0 || remainder > 1.0) ? PWSnapToFullPixel : PWSnapToHalfPixel;
        }
    }
}

CGSize PWOffsetInDeviceSpace (CGContextRef ctx, CGSize direction, CGFloat value)
{
    // Convert a unity vector in the direction of the offset to device space.
    CGSize offset = CGContextConvertSizeToDeviceSpace (ctx, direction);
    // Scale the transformed vector to unity in device space and then by the length of the offset.
    CGFloat offsetLength = PWSizeLength (offset);
    offset.width  *= value / offsetLength;
    offset.height *= value / offsetLength;
    return offset;
}

CGPoint PWSnapPointToPixel (CGContextRef ctx, CGPoint point,
                            PWSnapToPixelMode hMode, PWSnapToPixelMode vMode, const CGSize* pixelOffsets)
{
    ResolveSnapModes (ctx, &hMode, &vMode);

    point = CGContextConvertPointToDeviceSpace (ctx, point);

    if (hMode == PWSnapToFullPixel)
        point.x = floor (point.x  + 0.5);
    else if (hMode == PWSnapToHalfPixel)
        point.x = floor (point.x) + 0.5;
    
    if (vMode == PWSnapToFullPixel)
        point.y = floor (point.y  + 0.5);
    else if (vMode == PWSnapToHalfPixel)
        point.y = floor (point.y) + 0.5;

    if (pixelOffsets) {
        // Adding pixel offsets in device space is complicated because the vectorial direction of the offsets must be
        // transformed, while their length is already in device space.
        
        if (pixelOffsets->width != 0.0) {
            // Convert the offset to a vector with the correct length in device space.
            CGSize offset = PWOffsetInDeviceSpace (ctx, CGSizeMake (1.0, 0.0), pixelOffsets->width);
            // Add the result to the point in device space.
            point.x += offset.width;
            point.y += offset.height;
        }

        // Same for the other direction.
        if (pixelOffsets->height != 0.0) {
            CGSize offset = PWOffsetInDeviceSpace (ctx, CGSizeMake (0.0, 1.0), pixelOffsets->height);
            point.x += offset.width;
            point.y += offset.height;
        }
    }

    return CGContextConvertPointToUserSpace (ctx, point);
}

CGSize PWSnapSizeToPixel (CGContextRef ctx, CGSize  size,
                          PWSnapToPixelMode hMode, PWSnapToPixelMode vMode, const CGSize* pixelOffsets)
{
    ResolveSnapModes (ctx, &hMode, &vMode);

    size = CGContextConvertSizeToDeviceSpace (ctx, size);

    if (hMode == PWSnapToFullPixel)
        size.width  = floor (size.width   + 0.5);
    else if (hMode == PWSnapToHalfPixel)
        size.width  = floor (size.width)  + 0.5;

    if (vMode == PWSnapToFullPixel)
        size.height = floor (size.height  + 0.5);
    else if (vMode == PWSnapToHalfPixel)
        size.height = floor (size.height) + 0.5;
    
    // See PWSnapPointToPixel for pixel offset handling.
    if (pixelOffsets) {
        if (pixelOffsets->width != 0.0) {
            CGSize offset = PWOffsetInDeviceSpace (ctx, CGSizeMake (1.0, 0.0), pixelOffsets->width);
            size.width += offset.width;
            size.height += offset.height;
        }
        if (pixelOffsets->height != 0.0) {
            CGSize offset = PWOffsetInDeviceSpace (ctx, CGSizeMake (0.0, 1.0), pixelOffsets->height);
            size.width += offset.width;
            size.height += offset.height;
        }
    }
    
    return CGContextConvertSizeToUserSpace (ctx, size);
}

CGRect PWSnapRectToPixel (CGContextRef ctx, CGRect rect,
                          PWSnapToPixelMode hMode, PWSnapToPixelMode vMode, const CGRect* pixelOffsets)
{    
    ResolveSnapModes (ctx, &hMode, &vMode);

    CGRect pixelRect = CGContextConvertRectToDeviceSpace (ctx, rect);
    CGFloat pixelMaxX = NSMaxX (pixelRect);
    CGFloat pixelMaxY = NSMaxY (pixelRect);
    
    if (hMode == PWSnapToFullPixel) {
        pixelRect.origin.x = floor (pixelRect.origin.x + 0.5);
        pixelMaxX          = floor (pixelMaxX          + 0.5);
    } else if (hMode == PWSnapToHalfPixel) {
        pixelRect.origin.x = floor (pixelRect.origin.x) + 0.5;
        pixelMaxX          = floor (pixelMaxX)          + 0.5;
    }
    if (vMode == PWSnapToFullPixel) {
        pixelRect.origin.y = floor (pixelRect.origin.y + 0.5);
        pixelMaxY          = floor (pixelMaxY          + 0.5);
    } else if (vMode == PWSnapToHalfPixel) {
        pixelRect.origin.y = floor (pixelRect.origin.y) + 0.5;
        pixelMaxY          = floor (pixelMaxY)          + 0.5;
    }
    
    pixelRect.size.width  = pixelMaxX - pixelRect.origin.x;
    pixelRect.size.height = pixelMaxY - pixelRect.origin.y;
    
    // Don't let the height or width round to 0 unless either was originally 0
    if (pixelRect.size.width == 0.0 && NSWidth (rect) > 0.0)
        pixelRect.size.width = 1.0;
    if (pixelRect.size.height == 0.0 && NSHeight (rect) > 0.0)
        pixelRect.size.height = 1.0;
    
    if (pixelOffsets) {
        pixelRect.origin.x    += pixelOffsets->origin.x;
        pixelRect.origin.y    += pixelOffsets->origin.y;
        pixelRect.size.width  += pixelOffsets->size.width;
        pixelRect.size.height += pixelOffsets->size.height;
    }
    
    return CGContextConvertRectToUserSpace (ctx, pixelRect);
}

CGFloat PWRoundToPixel (CGContextRef ctx, CGFloat value, PWRoundToPixelMode roundMode,
                        PWSnapToPixelMode* outSnapMode, BOOL vertical)
{
    NSCParameterAssert (ctx);
    NSCParameterAssert (value >= 0.0);
    
    CGSize deviceSize = CGContextConvertSizeToDeviceSpace (ctx, vertical ? CGSizeMake (0.0, value) : CGSizeMake (value, 0.0));
    CGFloat deviceValue;
    if (deviceSize.width == 0.0) {            // epsilon?
        deviceValue = fabs (deviceSize.height);
    } else if (deviceSize.height == 0.0) {    // epsilon?
        deviceValue = fabs (deviceSize.width);
    } else {
        if (outSnapMode)
            *outSnapMode = PWSnapToPixelOff;
        return value;
    }
    
    switch (roundMode) {
        case PWRoundToPixelDown:
            deviceValue = floor (deviceValue); break;
        case PWRoundToPixelUp:
            deviceValue = ceil (deviceValue); break;
        case PWRoundToPixelNearest:
            deviceValue = floor (deviceValue); break;
        default: break;
    }
    
    // Never round non-zero value to 0 (important for line widths).
    if (value > 0.0 && deviceValue == 0.0)
        deviceValue = 1.0;
    
    if (outSnapMode) {
        CGFloat remainder = fmod (deviceValue, 2.0);
        *outSnapMode = (remainder > 0.0 && remainder <= 1.0) ? PWSnapToHalfPixel : PWSnapToFullPixel;
    }
    
    if (roundMode != PWRoundToPixelOff) {
        if (vertical)
            deviceSize.height = deviceValue;
        else
            deviceSize.width = deviceValue;
        CGSize result = CGContextConvertSizeToUserSpace (ctx, deviceSize);
        value = fabs(vertical ? result.height : result.width);
    }
    
    return value;
}

CGFloat PWRoundHeightToPixel (CGContextRef ctx, CGFloat height, PWRoundToPixelMode roundMode,
                              PWSnapToPixelMode* outSnapMode)
{
    return PWRoundToPixel(ctx, height, roundMode, outSnapMode, YES);
}

CGFloat PWRoundWidthToPixel (CGContextRef ctx, CGFloat height, PWRoundToPixelMode roundMode,
                              PWSnapToPixelMode* outSnapMode)
{
    return PWRoundToPixel(ctx, height, roundMode, outSnapMode, NO);
}

#pragma mark -

typedef struct PWOuterContourInfo {
    CGMutablePathRef outerContourPath;
    BOOL             firstSubPathEnded;
    BOOL             useFirstSubPath;
} PWOuterContourInfo;

void OuterContourPathApplier(void* info, const CGPathElement* element)
{
    PWOuterContourInfo* outerContourInfo = (PWOuterContourInfo*)info;
    
    CGMutablePathRef outerContourPath = outerContourInfo->outerContourPath;
    BOOL appendElementToPath          = outerContourInfo->firstSubPathEnded != outerContourInfo->useFirstSubPath;
    
    switch(element->type)
    {
        case kCGPathElementMoveToPoint:
        {
            if(appendElementToPath)
            {
                CGPoint point0 = element->points[0];
                CGPathMoveToPoint(outerContourPath, NULL, point0.x, point0.y);
            }
            break;
        }
        case kCGPathElementAddLineToPoint:
        {
            if(appendElementToPath)
            {
                CGPoint point0 = element->points[0];
                CGPathAddLineToPoint(outerContourPath, NULL, point0.x, point0.y);
            }
            break;
        }
        case kCGPathElementAddQuadCurveToPoint:
        {
            if(appendElementToPath)
            {
                CGPoint point0 = element->points[0];
                CGPoint point1 = element->points[1];
                CGPathAddQuadCurveToPoint(outerContourPath, NULL, point0.x, point0.y, point1.x, point1.y);
            }
            break;
        }
        case kCGPathElementAddCurveToPoint:
        {
            if(appendElementToPath)
            {
                CGPoint point0 = element->points[0];
                CGPoint point1 = element->points[1];
                CGPoint point2 = element->points[2];
                CGPathAddCurveToPoint(outerContourPath, NULL, point0.x, point0.y, point1.x, point1.y, point2.x, point2.y);
            }
            break;
        }
        case kCGPathElementCloseSubpath:
        {
            if(appendElementToPath)
                CGPathCloseSubpath(outerContourPath);
            outerContourInfo->firstSubPathEnded = YES;
            break;
        }
    }
};

// This method only works for non-interrupted paths and returns either the inner or outer contour. For non-closed paths
// useInnerContour should be YES.
CGPathRef PWContourPath (CGPathRef path, CGFloat contourDistance, BOOL useInnerContour)
{    
    NSMutableData* data = [NSMutableData data];
    CGDataConsumerRef dataConsumer = CGDataConsumerCreateWithCFData((CFMutableDataRef)data);
    CGContextRef ctx = CGPDFContextCreate(dataConsumer, NULL, NULL);

    CGContextSaveGState(ctx);

    CGContextSetLineWidth(ctx, 2.0*contourDistance);
    CGContextAddPath(ctx, path);
    
    // It would be easier to use CGPathCreateCopyByStrokingPath, since it doesn't require a context, but this is only
    // available in iOS 5.0.
    
    CGContextReplacePathWithStrokedPath(ctx);
    CGPathRef strokedPath = CGContextCopyPath(ctx);
        
    PWOuterContourInfo outerContourInfo = {CGPathCreateMutable(), NO, useInnerContour};    
    CGPathApply(strokedPath, (void*)&outerContourInfo, OuterContourPathApplier);

    CGContextRestoreGState(ctx);
    
    CGDataConsumerRelease(dataConsumer);
    CGContextRelease(ctx);
    
    return CGPathCreateCopy(outerContourInfo.outerContourPath);
}

#pragma mark -

void PWContextAddRoundedRect (CGContextRef ctx, CGRect rect, CGFloat ovalWidth, CGFloat ovalHeight)
{
    if (ovalWidth <= 0.0 || ovalHeight <= 0.0) {
        CGContextAddRect (ctx, rect);
        return;
    }
    
    // Do not allow degeneration.
    ovalWidth  = fmin (ovalWidth,  rect.size.width  / 2.0);
    ovalHeight = fmin (ovalHeight, rect.size.height / 2.0);
    
    CGContextSaveGState (ctx);

    CGContextTranslateCTM (ctx, rect.origin.x, rect.origin.y);
    CGContextScaleCTM     (ctx, ovalWidth, ovalHeight);
    
    CGFloat fw = rect.size.width  / ovalWidth;
    CGFloat fh = rect.size.height / ovalHeight;
    CGContextMoveToPoint   (ctx, fw,  fh / 2.0);
    CGContextAddArcToPoint (ctx, fw,  fh,  fw / 2.0, fh,       1.0);
    CGContextAddArcToPoint (ctx, 0.0, fh,  0.0,      fh / 2.0, 1.0);
    CGContextAddArcToPoint (ctx, 0.0, 0.0, fw / 2.0, 0.0,      1.0);
    CGContextAddArcToPoint (ctx, fw,  0.0, fw,       fh / 2.0, 1.0);
    CGContextClosePath     (ctx);
    
    CGContextRestoreGState (ctx);
}

void PWContextAddRoundedRect2 (CGContextRef ctx,
                              CGRect rect, 
                              CGFloat topLeftRadius,
                              CGFloat topRightRadius, 
                              CGFloat bottomRightRadius,
                              CGFloat bottomLeftRadius)
{
	CGContextMoveToPoint(ctx, CGRectGetMinX(rect) + topLeftRadius, CGRectGetMinY(rect));
    CGContextAddArc(ctx, CGRectGetMaxX(rect) - topRightRadius, CGRectGetMinY(rect) + topRightRadius, topRightRadius, 3 * M_PI / 2, 0, 0);
    CGContextAddArc(ctx, CGRectGetMaxX(rect) - bottomRightRadius, CGRectGetMaxY(rect) - bottomRightRadius, bottomRightRadius, 0, M_PI / 2, 0);
    CGContextAddArc(ctx, CGRectGetMinX(rect) + bottomLeftRadius, CGRectGetMaxY(rect) - bottomLeftRadius, bottomLeftRadius, M_PI / 2, M_PI, 0);
    CGContextAddArc(ctx, CGRectGetMinX(rect) + topLeftRadius, CGRectGetMinY(rect) + topLeftRadius, topLeftRadius, M_PI, 3 * M_PI / 2, 0);	
}

void PWPathAddRoundedRect (CGMutablePathRef path, const CGAffineTransform* m,
                           CGRect rect, CGFloat ovalWidth, CGFloat ovalHeight)
{
    if (ovalWidth <= 0.0 || ovalHeight <= 0.0) {
        CGPathAddRect (path, m, rect);
        return;
    }
    
    // Do not allow degeneration.
    ovalWidth  = fmin (ovalWidth,  rect.size.width  / 2.0);
    ovalHeight = fmin (ovalHeight, rect.size.height / 2.0);

    CGAffineTransform transform = CGAffineTransformTranslate (m ? *m : CGAffineTransformIdentity,
                                                              rect.origin.x, rect.origin.y);
    transform = CGAffineTransformScale (transform, ovalWidth, ovalHeight);
    
    CGFloat fw = rect.size.width  / ovalWidth;
    CGFloat fh = rect.size.height / ovalHeight;
    CGPathMoveToPoint   (path, &transform, fw,  fh / 2.0);
    CGPathAddArcToPoint (path, &transform, fw,  fh,  fw / 2.0, fh,       1.0);
    CGPathAddArcToPoint (path, &transform, 0.0, fh,  0.0,      fh / 2.0, 1.0);
    CGPathAddArcToPoint (path, &transform, 0.0, 0.0, fw / 2.0, 0.0,      1.0);
    CGPathAddArcToPoint (path, &transform, fw,  0.0, fw,       fh / 2.0, 1.0);
    CGPathCloseSubpath  (path);
}

CGPathRef PWPathCreateRectPath (CGRect rect)
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect (path, NULL, rect);
    return path;
}

void PWContextDrawFocusRingForRect (CGContextRef ctx, CGRect rect, BOOL activeAppearance)
{
    CGMutablePathRef path = CGPathCreateMutable();
    // TODO: make the corner radius pixel-based.
    CGSize radius = CGContextConvertSizeToUserSpace (ctx, CGSizeMake (3.0, 3.0));
    PWPathAddRoundedRect (path,
                          NULL,
                          PWSnapRectToPixel  (ctx, rect, PWSnapToHalfPixel, PWSnapToHalfPixel, NULL),
                          fabs (radius.width), fabs (radius.height));
    PWContextDrawFocusRingForPath (ctx, path, activeAppearance);
    CFRelease (path);
}

void PWContextDrawFocusRingForPath (CGContextRef ctx, CGPathRef path, BOOL activeAppearance)
{
    CGFloat colorComponents[4];
    if (activeAppearance) {
        // I (kb) found the following values by breaking on CGStyleCreateFocusRingWithColor() and examining the colors
        // which are passed to this function.
        if ([NSColor currentControlTint] == NSGraphiteControlTint) {
            // Graphite values.
            colorComponents[0] = 0.368627;
            colorComponents[1] = 0.419608;
            colorComponents[2] = 0.47451;
        } else {
            // Blue values.
            colorComponents[0] = 0.294118;
            colorComponents[1] = 0.537255;
            colorComponents[2] = 0.815686;
        }
    } else {
        colorComponents[0] = 0.3;
        colorComponents[1] = 0.3;
        colorComponents[2] = 0.3;
    }

    CGContextSaveGState (ctx);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); // note: returns generic colorspace in 10.4+
    CGContextSetStrokeColorSpace (ctx, colorSpace);
    CFRelease (colorSpace);
    CGContextSetLineJoin (ctx, kCGLineJoinRound);
    
    // Line width for the focus ring are in pixels.
    // Note: the current solution only works for a uniform scale. Correct would be to change the CTM to device
    // coordinates (using CGContextGetUserSpaceToDeviceSpaceTransform()) before drawing. But this would mean to save
    // and restore the context for each of the three lines, so I leave it as is until we really need this.
    CGFloat pixelSize = PWSizeLength (CGContextConvertSizeToUserSpace (ctx, CGSizeMake (0.0, 1.0)));

    if (activeAppearance) {
        CGContextSetLineWidth (ctx, 5.0 * pixelSize);
        CGContextAddPath (ctx, path);
        colorComponents[3] = 0.25;
        CGContextSetStrokeColor (ctx, colorComponents);
        CGContextStrokePath (ctx);
    }
    
    CGContextSetLineWidth (ctx, 3.0 * pixelSize);
    CGContextAddPath (ctx, path);
    colorComponents[3] = activeAppearance ? 0.40 : 0.30;
    CGContextSetStrokeColor (ctx, colorComponents);
    CGContextStrokePath (ctx);
    
    CGContextSetLineWidth (ctx, 1.0 * pixelSize);
    CGContextAddPath (ctx, path);
    colorComponents[3] = 0.60;
    CGContextSetStrokeColor (ctx, colorComponents);
    CGContextStrokePath (ctx);

    CGContextRestoreGState (ctx);
}

CGGradientRef PWCreateGradientWithTwoColors(CGColorRef startColor, CGColorRef endColor)
{
    const CGFloat* startColorComponents = CGColorGetComponents(startColor);
    const CGFloat* endColorComponents = CGColorGetComponents(endColor);
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGFloat components[8] = {
        startColorComponents[0], startColorComponents[1], startColorComponents[2], startColorComponents[3],
        endColorComponents[0],   endColorComponents[1],   endColorComponents[2],   endColorComponents[3]
    };
    CGFloat locations[2] = { 0.0, 1.0 };
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, components, locations, 2);
    
    CGColorSpaceRelease(colorspace);
    
    return gradient;
}
