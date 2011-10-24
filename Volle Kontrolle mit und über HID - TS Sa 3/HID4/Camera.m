//
//  Camera.m
//  HID4
//
//  Created by Matthias Krauß on 19.08.11.
//  Copyright 2011 Matthias Krauß. All rights reserved.
//

#import <OpenGL/OpenGL.h>
#import <OpenGL/glu.h>
#import "Camera.h"
#import "Game.h"
#import "Player.h"



@interface Camera ()

- (void) rebuildClippingPlanes;

@end


@implementation Camera

+ (Camera*) camera {
	return [[[Camera alloc] init] autorelease];
}

- (id) init {
	self = [super init];
	if (!self) return nil;
	set(&pos,0,0,1);
	set(&poi,0,0,0);
	set(&up,0,1,0);
	fovy = 30.0;
	aspect = 1.0;
	near = 1.0;
	far = 10000.0;
	[self rebuildClippingPlanes];
	return self;
}

- (vec3) pos {
	return pos;
}

- (void) setPos:(const vec3)v {
	copy(&v,&pos);
	[self rebuildClippingPlanes];
}

- (vec3) poi {
	return poi;
}

- (void) setPoi:(const vec3)v {
	copy(&v,&poi);
	[self rebuildClippingPlanes];
}

- (vec3) up {
	return up;
}

- (void) setUp:(const vec3)v {
	copy(&v,&up);
	[self rebuildClippingPlanes];
}

- (void) setFovy:(float)f {
	fovy = f;
	[self rebuildClippingPlanes];
}

- (float) fovy {
	return fovy;
}

- (void) setAspect:(float)f {
	aspect = f;
	[self rebuildClippingPlanes];
}

- (float) aspect {
	return aspect;
}

- (void) setNear:(float)f {
	near = f;
	[self rebuildClippingPlanes];
}

- (float) near {
	return near;
}

- (void) setFar:(float)f {
	far = f;
	[self rebuildClippingPlanes];
}

- (float) far {
	return far;
}

- (vec3) lookDir {
    vec3 lookDir;
    sub(&poi,&pos,&lookDir);
    return lookDir;
}


- (void) assignProjectionMatrix {
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	float vFactor = atan(fovy*M_PI/360.0);
	float hFactor = vFactor * aspect;
	glFrustum(-near*hFactor, near*hFactor, -near*vFactor, near*vFactor, near, far);
	glMatrixMode(GL_MODELVIEW);
}

- (void) assignModelviewMatrix {
	glLoadIdentity();
	gluLookAt(pos.x, pos.y, pos.z, poi.x, poi.y, poi.z, up.x, up.y, up.z);
}

- (CullState) cullTest:(const box3)box {
	vec3 points[8] = {
		box.origin.x, box.origin.y, box.origin.z,
		box.origin.x+box.size.x, box.origin.y, box.origin.z,
		box.origin.x, box.origin.y+box.size.y, box.origin.z,
		box.origin.x+box.size.x, box.origin.y+box.size.y, box.origin.z,
		box.origin.x, box.origin.y, box.origin.z+box.size.z,
		box.origin.x+box.size.x, box.origin.y, box.origin.z+box.size.z,
		box.origin.x, box.origin.y+box.size.y, box.origin.z+box.size.z,
		box.origin.x+box.size.x, box.origin.y+box.size.y, box.origin.z+box.size.z
	};
	//if all points are outside at least one plane, the box is completely out
	//if all points inside all planes, the box is completely in
	//box is partially in otherwise
	BOOL allIn = YES;
	for (int planeIdx = 0; planeIdx < 6; planeIdx++) {
		BOOL planeOut = YES;
		for (int pointIdx = 0; pointIdx < 8; pointIdx++) {
			BOOL pointIn = (signedDistance(&(points[pointIdx]), &(clippingPlanes[planeIdx])) >= 0);
			if (pointIn) planeOut = NO;
			else allIn = NO;
		}
		if (planeOut) return Cull_Outside;
	}
	return (allIn) ? Cull_Inside : Cull_Partial;
}

- (void) rebuildClippingPlanes {
	vec3 lookDir, right, realUp;
	sub(&poi,&pos,&lookDir);
	normalize(&lookDir);
	crossProduct(&lookDir, &up, &right);
	normalize(&right);
	crossProduct(&right, &lookDir, &realUp);
	normalize(&realUp);
	float vFactor = atan(fovy*M_PI/360.0);
	float hFactor = vFactor * aspect;
	vec3 nearLook, nearRight, nearUp;
	vec3 farLook, farRight, farUp;
	copy(&lookDir,&nearLook);
	copy(&right,&nearRight);
	copy(&realUp,&nearUp);
	copy(&lookDir,&farLook);
	copy(&right,&farRight);
	copy(&realUp,&farUp);
	scale(&nearLook,near);
	scale(&nearRight,hFactor*near);
	scale(&nearUp,vFactor*near);
	scale(&farLook,far);
	scale(&farRight,hFactor*far);
	scale(&farUp,vFactor*far);
	vec3 nearLowerLeft, nearLowerRight, nearUpperLeft, nearUpperRight;
	vec3 farLowerLeft, farLowerRight, farUpperLeft, farUpperRight;
	add(&pos, &nearLook, &nearLowerLeft); sub(&nearLowerLeft, &nearUp, &nearLowerLeft); sub(&nearLowerLeft, &nearRight, &nearLowerLeft);
	add(&pos, &nearLook, &nearLowerRight); sub(&nearLowerRight, &nearUp, &nearLowerRight); add(&nearLowerRight, &nearRight, &nearLowerRight);
	add(&pos, &nearLook, &nearUpperLeft); add(&nearUpperLeft, &nearUp, &nearUpperLeft); sub(&nearUpperLeft, &nearRight, &nearUpperLeft);
	add(&pos, &nearLook, &nearUpperRight); add(&nearUpperRight, &nearUp, &nearUpperRight); add(&nearUpperRight, &nearRight, &nearUpperRight);
	add(&pos, &farLook, &farLowerLeft); sub(&farLowerLeft, &farUp, &farLowerLeft); sub(&farLowerLeft, &farRight, &farLowerLeft);
	add(&pos, &farLook, &farLowerRight); sub(&farLowerRight, &farUp, &farLowerRight); add(&farLowerRight, &farRight, &farLowerRight);
	add(&pos, &farLook, &farUpperLeft); add(&farUpperLeft, &farUp, &farUpperLeft); sub(&farUpperLeft, &farRight, &farUpperLeft);
	add(&pos, &farLook, &farUpperRight); add(&farUpperRight, &farUp, &farUpperRight); add(&farUpperRight, &farRight, &farUpperRight);
	planeFromPoints(&pos, &nearUpperRight, &nearLowerRight, &(clippingPlanes[0]));
	planeFromPoints(&pos, &nearLowerRight, &nearLowerLeft, &(clippingPlanes[1]));
	planeFromPoints(&pos, &nearLowerLeft, &nearUpperLeft, &(clippingPlanes[2]));
	planeFromPoints(&pos, &nearUpperLeft, &nearUpperRight, &(clippingPlanes[3]));
	planeFromPoints(&nearUpperLeft, &nearUpperRight, &nearLowerRight, &(clippingPlanes[4]));
	planeFromPoints(&farUpperRight, &farUpperLeft, &farLowerLeft, &(clippingPlanes[5]));
}

- (void) draw {
	vec3 lookDir, right, realUp;
	sub(&poi,&pos,&lookDir);
	normalize(&lookDir);
	crossProduct(&lookDir, &up, &right);
	normalize(&right);
	crossProduct(&right, &lookDir, &realUp);
	normalize(&realUp);
	float vFactor = atan(fovy*M_PI/360.0);
	float hFactor = vFactor * aspect;
	vec3 nearLook, nearRight, nearUp;
	vec3 farLook, farRight, farUp;
	copy(&lookDir,&nearLook);
	copy(&right,&nearRight);
	copy(&realUp,&nearUp);
	copy(&lookDir,&farLook);
	copy(&right,&farRight);
	copy(&realUp,&farUp);
	scale(&nearLook,near);
	scale(&nearRight,hFactor*near);
	scale(&nearUp,vFactor*near);
	scale(&farLook,far);
	scale(&farRight,hFactor*far);
	scale(&farUp,vFactor*far);
	vec3 nearLowerLeft, nearLowerRight, nearUpperLeft, nearUpperRight;
	vec3 farLowerLeft, farLowerRight, farUpperLeft, farUpperRight;
	add(&pos, &nearLook, &nearLowerLeft); sub(&nearLowerLeft, &nearUp, &nearLowerLeft); sub(&nearLowerLeft, &nearRight, &nearLowerLeft);
	add(&pos, &nearLook, &nearLowerRight); sub(&nearLowerRight, &nearUp, &nearLowerRight); add(&nearLowerRight, &nearRight, &nearLowerRight);
	add(&pos, &nearLook, &nearUpperLeft); add(&nearUpperLeft, &nearUp, &nearUpperLeft); sub(&nearUpperLeft, &nearRight, &nearUpperLeft);
	add(&pos, &nearLook, &nearUpperRight); add(&nearUpperRight, &nearUp, &nearUpperRight); add(&nearUpperRight, &nearRight, &nearUpperRight);
	add(&pos, &farLook, &farLowerLeft); sub(&farLowerLeft, &farUp, &farLowerLeft); sub(&farLowerLeft, &farRight, &farLowerLeft);
	add(&pos, &farLook, &farLowerRight); sub(&farLowerRight, &farUp, &farLowerRight); add(&farLowerRight, &farRight, &farLowerRight);
	add(&pos, &farLook, &farUpperLeft); add(&farUpperLeft, &farUp, &farUpperLeft); sub(&farUpperLeft, &farRight, &farUpperLeft);
	add(&pos, &farLook, &farUpperRight); add(&farUpperRight, &farUp, &farUpperRight); add(&farUpperRight, &farRight, &farUpperRight);
	vec3 middle = lookDir;
	scale(&middle,(near+far)/2.0);
	add(&pos,&middle,&middle);
	add(&middle,&nearLowerLeft,&nearLowerLeft); scale(&nearLowerLeft,0.5);
	add(&middle,&nearLowerRight,&nearLowerRight); scale(&nearLowerRight,0.5);
	add(&middle,&nearUpperLeft,&nearUpperLeft); scale(&nearUpperLeft,0.5);
	add(&middle,&nearUpperRight,&nearUpperRight); scale(&nearUpperRight,0.5);
	add(&middle,&farLowerLeft,&farLowerLeft); scale(&farLowerLeft,0.5);
	add(&middle,&farLowerRight,&farLowerRight); scale(&farLowerRight,0.5);
	add(&middle,&farUpperLeft,&farUpperLeft); scale(&farUpperLeft,0.5);
	add(&middle,&farUpperRight,&farUpperRight); scale(&farUpperRight,0.5);
	
	glBegin(GL_LINES);
	glVertex3f(nearLowerLeft.x, nearLowerLeft.y, nearLowerLeft.z); 
	glVertex3f(nearLowerRight.x, nearLowerRight.y, nearLowerRight.z); 
	glVertex3f(nearUpperLeft.x, nearUpperLeft.y, nearUpperLeft.z); 
	glVertex3f(nearUpperRight.x, nearUpperRight.y, nearUpperRight.z); 
	glVertex3f(nearLowerLeft.x, nearLowerLeft.y, nearLowerLeft.z); 
	glVertex3f(nearUpperLeft.x, nearUpperLeft.y, nearUpperLeft.z); 
	glVertex3f(nearLowerRight.x, nearLowerRight.y, nearLowerRight.z); 
	glVertex3f(nearUpperRight.x, nearUpperRight.y, nearUpperRight.z); 

	glVertex3f(farLowerLeft.x, farLowerLeft.y, farLowerLeft.z); 
	glVertex3f(farLowerRight.x, farLowerRight.y, farLowerRight.z); 
	glVertex3f(farUpperLeft.x, farUpperLeft.y, farUpperLeft.z); 
	glVertex3f(farUpperRight.x, farUpperRight.y, farUpperRight.z); 
	glVertex3f(farLowerLeft.x, farLowerLeft.y, farLowerLeft.z); 
	glVertex3f(farUpperLeft.x, farUpperLeft.y, farUpperLeft.z); 
	glVertex3f(farLowerRight.x, farLowerRight.y, farLowerRight.z); 
	glVertex3f(farUpperRight.x, farUpperRight.y, farUpperRight.z); 
	
	glVertex3f(nearLowerLeft.x, nearLowerLeft.y, nearLowerLeft.z); 
	glVertex3f(farLowerLeft.x, farLowerLeft.y, farLowerLeft.z); 
	glVertex3f(nearLowerRight.x, nearLowerRight.y, nearLowerRight.z); 
	glVertex3f(farLowerRight.x, farLowerRight.y, farLowerRight.z); 
	glVertex3f(nearUpperLeft.x, nearUpperLeft.y, nearUpperLeft.z); 
	glVertex3f(farUpperLeft.x, farUpperLeft.y, farUpperLeft.z); 
	glVertex3f(nearUpperRight.x, nearUpperRight.y, nearUpperRight.z); 
	glVertex3f(farUpperRight.x, farUpperRight.y, farUpperRight.z); 
	glEnd();
}

- (void) behaveForGame:(Game*)game {
	float poiBlend = 0.9;
	float posBlend = 0.9;
	float lookDownBlend = 0.9;
	float wantedLookDown = 0.3;
	
	NSArray* players = game.players;
	vec3 wantedPoi = {0,0,0};
	int numPlayers = 0;
	for (Player* player in players) {
		vec3 playerPos = [player pos];
		add(&wantedPoi,&playerPos,&wantedPoi);
		numPlayers++;
	}
	if (numPlayers<1) return;
	scale(&wantedPoi,1.0/numPlayers);
	vec3 isPoi = self.poi;
	scale(&wantedPoi,1.0-poiBlend);
	scale(&isPoi,poiBlend);
	add(&wantedPoi,&isPoi,&wantedPoi);
	self.poi = wantedPoi;

	float maxDist = 20.0;
	for (Player* player in players) {
		vec3 playerPos = [player pos];
		float dist = distance(&playerPos,&wantedPoi);
		if (dist>maxDist) maxDist = dist;
	}
	float wantedDist = 3.0 * maxDist;	//TODO: base this on the camera's fov
	vec3 isPos = self.pos;
	vec3 camDir;
	sub(&wantedPoi, &isPos, &camDir);
	float isDist = length(&camDir);
	wantedDist = posBlend * isDist + (1.0-posBlend) * wantedDist;
	scale(&camDir,wantedDist/isDist);
	vec3 wantedPos;
	sub(&wantedPoi, &camDir, &wantedPos);
	float wantedHeight = wantedPoi.y + wantedLookDown * wantedDist;
	wantedPos.y = wantedPos.y * lookDownBlend + wantedHeight * (1.0-lookDownBlend);
	self.pos = wantedPos;
}
	
	
	
	
	
		


@end
