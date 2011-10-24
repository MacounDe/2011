//
//  Terrain.m
//  HID4
//
//  Created by Matthias Krauß on 18.08.11.
//  Copyright 2011 Matthias Krauß. All rights reserved.
//

#import "Terrain.h"
#import <OpenGL/glu.h>
#import "Camera.h"
#import "OGLResourceManager.h"
#include "glTools.h"

#define TERRAIN_GRID 32
#define NOISE_SIZE 1024
#define NOISE_OCTAVES 4

//TERRAIN_GRID+2 quads (TERRAIN_GRID+3 vertices) per axis because of skirts
const static int gridVertexCount = (TERRAIN_GRID+3) * (TERRAIN_GRID+3);
const static int gridVertexSizeBytes = (TERRAIN_GRID+3) * (TERRAIN_GRID+3) * 3 * sizeof(GLfloat);
const static int gridIndexCount = (TERRAIN_GRID+2) * (TERRAIN_GRID+2) * 4;
const static int gridIndexSizeBytes = (TERRAIN_GRID+2) * (TERRAIN_GRID+2) * 4 * sizeof(GLushort);
const static int gridFullSize = (TERRAIN_GRID+3) * (TERRAIN_GRID+3) * 3 * sizeof(GLfloat) + (TERRAIN_GRID+2) * (TERRAIN_GRID+2) * 4 * sizeof(GLushort);

@interface Terrain ()

- (void*) gridVerticesAndIndexes;
- (uint8_t*) noiseTex; //returns reasonably good tileable perlin noise rgb data

@end

@implementation Terrain

+ (Terrain*)terrain {
	return [[[Terrain alloc] init] autorelease];
}

- (void) quadTreeRenderWithCamera:(Camera*)camera 
							 base:(NSPoint)base
							 size:(double)size
					  offScaleLoc:(GLuint)offScaleLoc
					needClipCheck:(BOOL)needClipCheck
					 minMaxHeight:(NSPoint)minMaxHeight {
	box3 box = {base.x, minMaxHeight.x, base.y, size, minMaxHeight.y-minMaxHeight.x, size};
	if (needClipCheck) {
		CullState clip = [camera cullTest:box];
		if (clip == Cull_Outside) return;                   //skip: we're completely outside
		else if (clip == Cull_Inside) needClipCheck = NO;   //don't check subpatches: we're inside
	}
	vec3 camPos = [camera pos];
	float minDist = pow(distBoxVec(&box,&camPos),2.0);
	float neededResolution = MAX(40.0,0.003*minDist);
	
	if (size > neededResolution) {	//need to subdivide further
        vec3 lookDir = camera.lookDir;
        float halfSize = size/2.0;
        //order subdivision patches front-to-back to reduce overdraw and fragment shader overhead
        NSPoint p1 = NSMakePoint(base.x + ((lookDir.x>0)?0.0:halfSize), base.y + ((lookDir.z>0)?0.0:halfSize));
        NSPoint p2 = NSMakePoint(base.x + ((lookDir.x>0)?0.0:halfSize), base.y + ((lookDir.z>0)?halfSize:0.0));
        NSPoint p3 = NSMakePoint(base.x + ((lookDir.x>0)?halfSize:0.0), base.y + ((lookDir.z>0)?0.0:halfSize));
        NSPoint p4 = NSMakePoint(base.x + ((lookDir.x>0)?halfSize:0.0), base.y + ((lookDir.z>0)?halfSize:0.0));
		[self quadTreeRenderWithCamera:camera base:p1 size:halfSize
						   offScaleLoc:offScaleLoc needClipCheck:needClipCheck minMaxHeight:minMaxHeight];
		[self quadTreeRenderWithCamera:camera base:p2 size:halfSize
						   offScaleLoc:offScaleLoc needClipCheck:needClipCheck minMaxHeight:minMaxHeight];
		[self quadTreeRenderWithCamera:camera base:p3 size:halfSize
						   offScaleLoc:offScaleLoc needClipCheck:needClipCheck minMaxHeight:minMaxHeight];
		[self quadTreeRenderWithCamera:camera base:p4 size:halfSize
						   offScaleLoc:offScaleLoc needClipCheck:needClipCheck minMaxHeight:minMaxHeight];
	} else {	//resolution is ok
		glUniform4f(offScaleLoc, base.x, base.y, size, size);
		glDrawElements(GL_QUADS, gridIndexCount, GL_UNSIGNED_SHORT, (void*)(NULL+gridVertexSizeBytes));
	}
}

- (void) renderWithCamera:(Camera*)camera resources:(OGLResourceManager*)resources {
	GLuint program = [resources shaderProgramWithName:@"terrain"];
	if (!program) program = [resources buildShaderProgramWithName:@"terrain" baseName:@"terrain"];
	GLuint heightmap = [resources textureWithName:@"heightmap"];
	if (!heightmap) heightmap = [resources buildTextureWithName:@"heightmap" imageUrl:[[NSBundle mainBundle] URLForResource:@"heightmap" withExtension:@"tiff"] mipmap:NO];
	GLuint heightcolormap = [resources textureWithName:@"heightcolormap"];
	if (!heightcolormap) heightcolormap = [resources buildTextureWithName:@"heightcolormap" imageUrl:[[NSBundle mainBundle] URLForResource:@"heightcolormap" withExtension:@"png"] mipmap:NO];
	GLuint skydome = [resources textureWithName:@"skydome"];
	if (!skydome) skydome = [resources buildTextureWithName:@"skydome"
												   imageUrl:[[NSBundle mainBundle] URLForResource:@"skydome"
																					withExtension:@"jpg"]
													 mipmap:NO];
    GLuint noiseTex = [resources textureWithName:@"noise"];
    if (!noiseTex) noiseTex = [resources buildTextureWithName:@"noise"
                                                       bitmap:[self noiseTex]
                                                        width:NOISE_SIZE
                                                       height:NOISE_SIZE
                                                  bitsPerComp:8
                                                  compsPerPix:3
                                             storeCompsPerPix:3
                                                       mipmap:YES
                                                       repeat:YES];
    
	GLuint vbo = [resources vboWithName:@"flat grid"];
	if (!vbo) vbo = [resources buildVBO:@"flat grid" buffer:[self gridVerticesAndIndexes]
								 length:gridFullSize];

	glError();
	glUseProgram(program);
	GLint offScaleLoc = glGetUniformLocation(program, "offScale");
	GLint heightMapLoc = glGetUniformLocation(program, "tex");
	GLint texScaleLoc = glGetUniformLocation(program, "texScale");
	GLint heightSealevelLoc = glGetUniformLocation(program, "heightSealevel");
	GLint heightColorMapLoc = glGetUniformLocation(program, "heightColorMap");
	GLint camPosLoc = glGetUniformLocation(program, "camPos");
	GLint envMapLoc = glGetUniformLocation(program, "envMap");
	GLint noiseTexLoc = glGetUniformLocation(program, "noiseTex");
	
	glActiveTexture(GL_TEXTURE3);
	glBindTexture(GL_TEXTURE_2D, noiseTex);
	glUniform1i(noiseTexLoc, 3);

	glActiveTexture(GL_TEXTURE2);
	glBindTexture(GL_TEXTURE_2D, skydome);
	glUniform1i(envMapLoc, 2);
	
	glActiveTexture(GL_TEXTURE1);
	glBindTexture(GL_TEXTURE_1D, heightcolormap);
	glUniform1i(heightColorMapLoc, 1);
	
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, heightmap);
	glUniform1i(heightMapLoc, 0);
	
	glUniform2f(texScaleLoc, 2000, 2000);
	glUniform2f(heightSealevelLoc, 500, 10.6);
	glUniform3f(camPosLoc, [camera pos].x,[camera pos].y,[camera pos].z);

	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_INDEX_ARRAY);
	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	glVertexPointer(3, GL_FLOAT, 3*sizeof(GLfloat), 0);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vbo);

	[self quadTreeRenderWithCamera:camera base:NSMakePoint(-7000,-7000) size:14000
					   offScaleLoc:offScaleLoc needClipCheck:YES
					  minMaxHeight:NSMakePoint(-10, 690)];
	
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	glDisableClientState(GL_INDEX_ARRAY);	
	glDisableClientState(GL_VERTEX_ARRAY);	
	glUseProgram(0);
	glError();
}


- (void*) gridVerticesAndIndexes {
	NSMutableData* data = [NSMutableData dataWithLength:gridFullSize];
	GLfloat* vertexBase = (GLfloat*)[data mutableBytes];
	GLushort* indexBase = (GLushort*)([data mutableBytes]+gridVertexSizeBytes);
	
	for (int j=-1;j<=(TERRAIN_GRID+1);j++) {
		for (int i=-1;i<=(TERRAIN_GRID+1);i++) {
			double x = (double)i / (double)TERRAIN_GRID;
			double z = (double)j / (double)TERRAIN_GRID;
			*(vertexBase++) = x; *(vertexBase++) = 0.0; *(vertexBase++) = z; 
		}
	}
	for (int j=0;j<=(TERRAIN_GRID+1);j++) {
		for (int i=0;i<=(TERRAIN_GRID+1);i++) {
			GLushort idx = (TERRAIN_GRID+3)*j+i;
			*(indexBase++) = idx;
			*(indexBase++) = idx + TERRAIN_GRID + 3;
			*(indexBase++) = idx + TERRAIN_GRID + 4;
			*(indexBase++) = idx + 1;
		}
	}
	return [data mutableBytes];
}

- (uint8_t*) noiseTex {
    int size = NOISE_SIZE * NOISE_SIZE * 3;
    NSMutableData* accumData = [NSMutableData dataWithLength:size];
    uint8_t* accumBase = (uint8_t*)[accumData mutableBytes];
    memset(accumBase, 127, size);
    NSMutableData* randData = [NSMutableData dataWithLength:size];
    int8_t* randBase = (int8_t*)[randData mutableBytes];

    for (int plane = 0; plane < 3; plane++) {    //repeat for r,g,b
        for (int octave = 0; octave < NOISE_OCTAVES; octave++) {    //make noise for all octaves
            //set noise points
            int gridSize = 1 << octave;
            int amplitude = 127 * gridSize / ((1 << NOISE_OCTAVES)-1);
            for (int j=0;j<NOISE_SIZE/gridSize;j++) {
                for (int i=0;i<NOISE_SIZE/gridSize;i++) {
                    int rnd = random() % (2*amplitude+1)-amplitude;
                    int idx = ((j*gridSize)*NOISE_SIZE + (i*gridSize))*3 + plane;
                    randBase[idx] = rnd;
                }
            }
            //interpolate points
            for (int j=0;j<NOISE_SIZE/gridSize;j++) {
                for (int i=0;i<NOISE_SIZE/gridSize;i++) {
                    for (int jj=0;jj<gridSize;jj++) {
                        for (int ii=0;ii<gridSize;ii++) {
                            int x0 = i*gridSize;
                            int x1 = ((i+1)*gridSize) % NOISE_SIZE;
                            int y0 = j*gridSize;
                            int y1 = ((j+1)*gridSize) % NOISE_SIZE;
                            int idx00 = (x0*NOISE_SIZE + y0)*3 + plane;
                            int idx01 = (x0*NOISE_SIZE + y1)*3 + plane;
                            int idx10 = (x1*NOISE_SIZE + y0)*3 + plane;
                            int idx11 = (x1*NOISE_SIZE + y1)*3 + plane;
                            int val00 = randBase[idx00];
                            int val01 = randBase[idx01];
                            int val10 = randBase[idx10];
                            int val11 = randBase[idx11];
                            float weightX = (float)ii/(float)gridSize;
                            float weightY = (float)jj/(float)gridSize;
                            int val = (val11*weightX + val01*(1.0-weightX)) * weightY +
                                (val10*weightX + val00*(1.0-weightX)) * weightX;
                            int idx = ((j*gridSize+jj)*NOISE_SIZE + (i*gridSize+ii))*3 + plane;
                            randBase[idx] = (int)val;
                        }
                    }
                }   
            }
            for (int i=0;i<NOISE_SIZE*NOISE_SIZE;i++) {     //accumulate
                int idx = 3*i+plane;
                accumBase[idx] += randBase[idx];
            }
        }
    }
    for (int i=0;i<size;i++) accumBase[i] = random()%256;
    return accumBase;
}

@end
