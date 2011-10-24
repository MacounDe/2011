//
//  Transformation.m
//  OpenGL Demo
//
//  Created by Dönigus Daniel on 22.08.11.
//  Copyright 2011 PRODEVCON. All rights reserved.
//

#import "Transformation.h"

@implementation Transformation

@synthesize transformationType;

@synthesize translateX;
@synthesize translateY;
@synthesize translateZ;

@synthesize scaleX;
@synthesize scaleY;
@synthesize scaleZ;

@synthesize rotation;
@synthesize rotationAxis;

- (id)initAsTranslationWithX:(GLfloat) x Y:(GLfloat)y andZ:(GLfloat)z {
    self = [super init];
    if (self) {
        transformationType = TRANSFORMATION_TRANSLATION;

        translateX = x;
        translateY = y;
        translateZ = z;
    }
    
    return self;
}

- (id)initAsScaleWithX:(GLfloat) x Y:(GLfloat)y andZ:(GLfloat)z {
    self = [super init];
    if (self) {
        transformationType = TRANSFORMATION_SCALE;
        
        scaleX = x;
        scaleY = y;
        scaleZ = z;
    }
    
    return self;
}

- (id)initAsRotationWithRotation:(GLfloat) rot aroundAxis:(int)axis {
    self = [super init];
    if (self) {
        transformationType = TRANSFORMATION_ROTATION;
        
        rotation = rot;
        rotationAxis = axis;
    }
    
    return self;
}

- (id)initAsPop {
    self = [super init];
    if (self) {
        transformationType = TRANSFORMATION_POP;
    }
    
    return self;
}

@end
