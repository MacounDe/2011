//
//  Transformation.h
//  OpenGL Demo
//
//  Created by Dönigus Daniel on 22.08.11.
//  Copyright 2011 PRODEVCON. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TRANSFORMATION_TRANSLATION 0
#define TRANSFORMATION_SCALE 1
#define TRANSFORMATION_ROTATION 2
#define TRANSFORMATION_POP 3

#define AXIS_X 0
#define AXIS_Y 1
#define AXIS_Z 2

@interface Transformation : NSObject {
    int transformationType;
    
    GLfloat translateX;
    GLfloat translateY;
    GLfloat translateZ;
    
    GLfloat scaleX;
    GLfloat scaleY;
    GLfloat scaleZ;
    
    GLfloat rotation;
    int rotationAxis;
}

@property int transformationType;

@property GLfloat translateX;
@property GLfloat translateY;
@property GLfloat translateZ;

@property GLfloat scaleX;
@property GLfloat scaleY;
@property GLfloat scaleZ;

@property GLfloat rotation;
@property int rotationAxis;

- (id)initAsTranslationWithX:(GLfloat) x Y:(GLfloat)y andZ:(GLfloat)z;
- (id)initAsScaleWithX:(GLfloat) x Y:(GLfloat)y andZ:(GLfloat)z;
- (id)initAsRotationWithRotation:(GLfloat) rot aroundAxis:(int)axis;
- (id)initAsPop;

@end
