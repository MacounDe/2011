//
//  AstronomicalObject.h
//  Space
//
//  Created by Daniel Dönigus on 11.01.11.
//  Copyright 2011 PRODEVCON. All rights reserved.
//

#import <GLKit/GLKMatrix4.h>

#import <Foundation/Foundation.h>
#import "Model.h"
#import "PlanetTrace.h"
#import <GLKit/GLKit.h>

//Planets are scaled by this factor
const static float planetScaleFactor = 0.000001437;
//Planet circling axis are scaled by this factor
const static float rangeScaleFactor = 0.000000013;

@interface AstronomicalObject : NSObject {
	AstronomicalObject* parent;
	NSArray* children;
	
	NSString* name;
	
	float radius;
	float semiMajorAxis;
	float orbitalPeriod;
	float siderealRotationPeriod;
	
    float scaleFactor;
    
	BOOL useLighting;
	
	Model* model;
	PlanetTrace* trace;
	
	GLKMatrix4 relativeTransformation;
	GLKMatrix4 modelTransformation;
	GLKMatrix4 modelTransformationForChildren;
}

- (id) initWithName:(NSString*) name andParent:(AstronomicalObject*) parentObject;
- (float) calculateScreenPositionOfObject:(GLKVector3*) screenPosition perspective:(GLKMatrix4) projectionMatrix viewMatrix:(GLKMatrix4) viewMatrix bounds:(CGRect) bounds;
- (void) calculateTransformationForTime:(float) time;
- (void) updateScaleFactor:(GLKMatrix4) projectionMatrix viewMatrix:(GLKMatrix4) viewMatrix bounds:(CGRect) bounds;

@property float radius;
@property float semiMajorAxis;
@property float orbitalPeriod;

@property float scaleFactor;

@property float siderealRotationPeriod;

@property (retain) AstronomicalObject* parent;
@property (retain) NSArray* children;

@property (readonly) Model* model;
@property (readonly) PlanetTrace* trace;

@property (readonly) NSString* name;

@property (readonly) BOOL useLighting;

@property BOOL showSymbol;

@property GLKMatrix4 modelTransformation;
@property GLKMatrix4 relativeTransformation;
@property GLKMatrix4 modelTransformationForChildren;

- (GLKVector3) retrievePosition;

@end
