//
//  Camera.h
//  HID4
//
//  Created by Matthias Krauß on 19.08.11.
//  Copyright 2011 Matthias Krauß. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "geometry.h"

typedef enum _CullState {
	Cull_Inside = 0,
	Cull_Outside,
	Cull_Partial
} CullState;

@class Game;

@interface Camera : NSObject {
	plane3 clippingPlanes[6];
	vec3 pos;
	vec3 poi;
	vec3 up;
	float fovy;
	float aspect;
	float near;
	float far;
}

+ (Camera*) camera;

@property (readwrite, assign) vec3 pos;
@property (readwrite, assign) vec3 poi;
@property (readwrite, assign) vec3 up;
@property (readwrite, assign) float fovy;
@property (readwrite, assign) float aspect;
@property (readwrite, assign) float near;
@property (readwrite, assign) float far;
@property (readonly, assign) vec3 lookDir;


- (void) assignProjectionMatrix;
- (void) assignModelviewMatrix;
- (CullState) cullTest:(const box3)box;

- (void) draw;

- (void) behaveForGame:(Game*)game;

@end
