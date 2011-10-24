//
//  Sky.m
//  HID4
//
//  Created by Matthias Krauß on 21.08.11.
//  Copyright 2011 Matthias Krauß. All rights reserved.
//

#import <OpenGL/OpenGL.h>
#import <OpenGL/glu.h>

#import "Sky.h"
#import "Camera.h"
#import "OGLResourceManager.h"

#include "geometry.h"
#include "glTools.h"

@interface Sky ()

- (GLfloat*) generateDome;

@end


@implementation Sky

#define TILES_H 60
#define TILES_V 10
#define SPHERE_RADIUS 5900.0


+ (Sky*) sky {
	return [[[Sky alloc] init] autorelease];
}

- (void) renderWithCamera:(Camera*)camera resources:(OGLResourceManager*)resources {
	glPushMatrix();
	vec3 camPos = [camera pos];
	glTranslated(camPos.x, 0.0, camPos.z);
	GLuint program = [resources shaderProgramWithName:@"sky"];
	if (!program) program = [resources buildShaderProgramWithName:@"sky" baseName:@"sky"];
	GLuint skydome = [resources textureWithName:@"skydome"];
	if (!skydome) skydome = [resources buildTextureWithName:@"skydome"
												   imageUrl:[[NSBundle mainBundle] URLForResource:@"skydome"
																					withExtension:@"jpg"]
													 mipmap:NO];
	GLuint vbo = [resources vboWithName:@"skydome"];
	if (!vbo) vbo = [resources buildVBO:@"skydome" buffer:[self generateDome]
								 length:(TILES_H*TILES_V)*4*5*sizeof(GLfloat)];
	int vertexCount = [resources lengthOfVBOWithName:@"skydome"] / (5*sizeof(GLfloat));
	
	glUseProgram(program);
	GLint texLoc = glGetUniformLocation(program, "tex");
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, skydome);
	glUniform1i(texLoc, 0);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	glVertexPointer(3, GL_FLOAT, 5*sizeof(GLfloat), 0);
	glTexCoordPointer(2, GL_FLOAT, 5*sizeof(GLfloat), (void*)(3*sizeof(GLfloat)));
	glDrawArrays(GL_QUADS, 0, vertexCount);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_VERTEX_ARRAY);	
	glUseProgram(0);
	glPopMatrix();
	glError();
}	

// ------ private -------

- (GLfloat*) generateDome {
	int fullSize = TILES_H * TILES_V * 4 * 5 * sizeof(GLfloat);
	NSMutableData* data = [NSMutableData dataWithLength:fullSize];
	GLfloat* base = (GLfloat*)[data mutableBytes];
	for (int j=0;j<TILES_V;j++) {
		double beta1 = 0.501 * M_PI * (double)j / (double)TILES_V;
		double beta2 = 0.501 * M_PI * (double)(j+1) / (double)TILES_V;
		double rad1 = SPHERE_RADIUS * sin(beta1);
		double rad2 = SPHERE_RADIUS * sin(beta2);
		double y1 = SPHERE_RADIUS * cos(beta1);
		double y2 = SPHERE_RADIUS * cos(beta2);
		double texRad1 = 0.48 * (double)(j) / (double)TILES_V;
		double texRad2 = 0.48 * (double)(j+1) / (double)TILES_V;
		for (int i=0;i<TILES_H;i++) {
			double alpha1 = 2.0 * M_PI * (double)i / (double)TILES_H;
			double alpha2 = 2.0 * M_PI * (double)(i+1) / (double)TILES_H;
			double x11 = rad1 * sin(alpha1);
			double z11 = rad1 * cos(alpha1);
			double x21 = rad1 * sin(alpha2);
			double z21 = rad1 * cos(alpha2);
			double x12 = rad2 * sin(alpha1);
			double z12 = rad2 * cos(alpha1);
			double x22 = rad2 * sin(alpha2);
			double z22 = rad2 * cos(alpha2);
			double s11 = texRad1 * sin(alpha1)+0.5;
			double t11 = texRad1 * cos(alpha1)+0.5;
			double s21 = texRad1 * sin(alpha2)+0.5;
			double t21 = texRad1 * cos(alpha2)+0.5;
			double s12 = texRad2 * sin(alpha1)+0.5;
			double t12 = texRad2 * cos(alpha1)+0.5;
			double s22 = texRad2 * sin(alpha2)+0.5;
			double t22 = texRad2 * cos(alpha2)+0.5;
			*(base++) = x11; *(base++) = y1; *(base++) = z11; *(base++) = s11; *(base++) = t11;
			*(base++) = x21; *(base++) = y1; *(base++) = z21; *(base++) = s21; *(base++) = t21;
			*(base++) = x22; *(base++) = y2; *(base++) = z22; *(base++) = s22; *(base++) = t22;
			*(base++) = x12; *(base++) = y2; *(base++) = z12; *(base++) = s12; *(base++) = t12;
		}
	}
	return (GLfloat*)[data mutableBytes];
}

@end
