//
//  Player.h
//  HID4
//
//  Created by Matthias Krauß on 19.08.11.
//  Copyright 2011 Matthias Krauß. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "geometry.h"

@class HIDDevice, Camera, OGLResourceManager;

@interface Player : NSObject {
	vec3 pos;
	float heading;
	float roll;
	float pitch;
	HIDDevice* hidDevice;
	float anim;
}

@property (readonly, retain) HIDDevice* hidDevice;
@property (readwrite, assign) vec3 pos;

+ (Player*) playerWithHIDDevice:(HIDDevice*)device;
- (void) behave;
- (void) renderWithCamera:(Camera*)camera resources:(OGLResourceManager*)resources;

@end
