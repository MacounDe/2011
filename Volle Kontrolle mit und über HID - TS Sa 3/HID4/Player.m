//
//  Player.m
//  HID4
//
//  Created by Matthias Krauß on 19.08.11.
//  Copyright 2011 Matthias Krauß. All rights reserved.
//

#import "Player.h"
#import <OpenGL/OpenGL.h>
#import <OpenGL/glu.h>
#import "HIDDevice.h"
#import "OGLResourceManager.h"
#include "geometry.h"
#include "glTools.h"

@interface Player ()

@property (readwrite, retain) HIDDevice* hidDevice;

- (void) drawHeliWithResources:(OGLResourceManager*)resources;

@end

@implementation Player

@synthesize hidDevice;
@synthesize pos;

+ (Player*) playerWithHIDDevice:(HIDDevice*)device {
	Player* player = [[[Player alloc] init] autorelease];
	player.hidDevice = device;
	return player;
}

- (id) init {
	self = [super init];
	if (!self) return nil;
	set(&pos,0,500,0);
	return self;
}

- (void) dealloc {
	self.hidDevice = nil;
	[super dealloc];
}

- (void) behave {
	float headScale = -2.0;
	float pitchBlend = 0.95;
	float pitchScale = -15.0;
	float pitchMoveScale = 0.1;
	float rollBlend = 0.95;
	float rollScale = -15.0;
	float rollMoveScale = 0.1;
	
	NSPoint joy1 = self.hidDevice.joystick1;
	NSPoint joy2 = self.hidDevice.joystick2;
	heading += headScale * joy1.x;
	pitch = pitchBlend * pitch + (1.0-pitchBlend) * pitchScale * joy1.y;
	roll = rollBlend * roll + (1.0-rollBlend) * rollScale * joy2.x;

	float forwardX = -cos(-heading*M_PI/180.0);
	float forwardZ = -sin(-heading*M_PI/180.0);
	pos.y += joy2.y;
	pos.x += forwardX * pitchMoveScale * pitch;
	pos.z += forwardZ * pitchMoveScale * pitch;

	pos.x += forwardZ * rollMoveScale * roll;
	pos.z -= forwardX * rollMoveScale * roll;


}

- (void) renderWithCamera:(Camera*)camera resources:(OGLResourceManager*)resources {
	glPushMatrix();
	glTranslatef(pos.x,pos.y,pos.z);
	glScaled(0.1,0.1,0.1);
	glRotatef(heading, 0.0,1.0,0.0);
	glRotatef(roll, 1.0,0.0,0.0);
	glRotatef(pitch, 0.0,0.0,1.0);
	[self drawHeliWithResources:resources];
	glPopMatrix();
}

// ------ private ------


#include "helicopter.h"

- (void) drawHeliWithResources:(OGLResourceManager*)resources {
	//body
	GLuint heliVBO = [resources vboWithName:@"helicopter"];
	if (!heliVBO) {
        NSURL* url = [[NSBundle mainBundle] URLForResource:@"helicopter" withExtension:@"vnt"];
        NSData* data = [NSData dataWithContentsOfURL:url];
        heliVBO = [resources buildVBO:@"helicopter" buffer:[data bytes] length:[data length]];
    }
	int heliVertexCount = [resources lengthOfVBOWithName:@"helicopter"] / sizeof (simpleVertex);
	GLuint heliProgram = [resources shaderProgramWithName:@"helicopter"];
	if (!heliProgram) heliProgram = [resources buildShaderProgramWithName:@"helicopter" baseName:@"helicopter"];
	
	glUseProgram(heliProgram);
	glBindBuffer(GL_ARRAY_BUFFER, heliVBO);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_NORMAL_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glVertexPointer(3, GL_FLOAT, 8*sizeof(GLfloat), 0);
	glNormalPointer(GL_FLOAT, 8*sizeof(GLfloat), (char*)(3*sizeof(GLfloat)));
	glTexCoordPointer(2, GL_FLOAT, 8*sizeof(GLfloat), (char*)(6*sizeof(GLfloat)));
	glDrawArrays(GL_TRIANGLES, 0, heliVertexCount);
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_NORMAL_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glUseProgram(0);
	glError();
	
	//main rotor
	glDepthMask(GL_FALSE);
	GLuint rotorVBO = [resources vboWithName:@"rotor"];
	if (!rotorVBO) rotorVBO = [resources buildVBO:@"rotor" buffer:(void*)rotorVertices length:sizeof(rotorVertices)];
	int rotorVertexCount = [resources lengthOfVBOWithName:@"rotor"] / sizeof (simpleVertex);
	GLuint rotorProgram = [resources shaderProgramWithName:@"rotor"];
	if (!rotorProgram) rotorProgram = [resources buildShaderProgramWithName:@"rotor" baseName:@"rotor"];
	glUseProgram(rotorProgram);
	GLint animLoc = glGetUniformLocation(rotorProgram, "anim");
	anim += 3.0;
	if (anim > 2.0*M_PI) anim -= 2.0*M_PI;
	glUniform1f(animLoc, anim);
	
	glBindBuffer(GL_ARRAY_BUFFER, rotorVBO);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_NORMAL_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glVertexPointer(3, GL_FLOAT, 8*sizeof(GLfloat), 0);
	glNormalPointer(GL_FLOAT, 8*sizeof(GLfloat), (char*)(3*sizeof(GLfloat)));
	glTexCoordPointer(2, GL_FLOAT, 8*sizeof(GLfloat), (char*)(6*sizeof(GLfloat)));
	glDrawArrays(GL_QUADS, 0, rotorVertexCount);
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_NORMAL_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glUseProgram(0);
	glDepthMask(GL_TRUE);
	glError();
}

@end
