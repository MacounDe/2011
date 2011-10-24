//
//  PlanetTrace.m
//  Space
//
//  Created by Daniel Dönigus on 14.01.11.
//  Copyright 2011 PRODEVCON. All rights reserved.
//

#import "PlanetTrace.h"

#define NUMBER_OF_SLICES 200

@implementation PlanetTrace

//Creating buffer for circle trace of positions and colors.
- (void) createCircleWithRadius:(float) radius beginColor:(GLKVector4) colorFrom andEndColor:(GLKVector4) colorTo {
	int numVertices = NUMBER_OF_SLICES + 1;
	int numIndices = NUMBER_OF_SLICES + 1;
	float angleStep = (2.0f * M_PI) / ((float) NUMBER_OF_SLICES);
	
    buffer = malloc( sizeof(GLfloat) * 7 * numVertices );
	
    for (int i = 0; i < numVertices; i++) {
        int vertex = i * 7; 
        
        buffer[vertex + 0] = radius * cosf ( angleStep * (float)i );
        buffer[vertex + 1] = 0;
        buffer[vertex + 2] = -radius * sinf ( angleStep * (float)i );
    }
	
    for(int i = 0; i < numVertices; i++) {
        int color = i * 7 + 3;
        float interpolatedPartFrom = (float)(numVertices - i) / (numVertices);
        float interpolatedPartTo = 1.0f - interpolatedPartFrom;
        
        buffer[color + 0] = interpolatedPartFrom * colorFrom.v[0] + interpolatedPartTo * colorTo.v[0];
        buffer[color + 1] = interpolatedPartFrom * colorFrom.v[1] + interpolatedPartTo * colorTo.v[1];
        buffer[color + 2] = interpolatedPartFrom * colorFrom.v[2] + interpolatedPartTo * colorTo.v[2];
        buffer[color + 3] = interpolatedPartFrom * colorFrom.v[3] + interpolatedPartTo * colorTo.v[3];
    }
    
	elementCount = numIndices;
}

//Vertex array object for planet traces
- (id)initForAstronomicalObjectData:(float) radius andColor:(float*) color {
    if ((self = [super init]))
    {
        GLKVector4 colorFrom = GLKVector4Make(color[0], color[1], color[2], color[3]);
        GLKVector4 colorTo = GLKVector4Make(color[0], color[1], color[2], 0.1);
        
        [self createCircleWithRadius:radius beginColor:colorFrom andEndColor:colorTo];
        
        glGenBuffers(1, &vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
        glBufferData(GL_ARRAY_BUFFER, (NUMBER_OF_SLICES + 1)*4*7, buffer, GL_STATIC_DRAW);
        
        glGenVertexArraysOES(1, &vertexArray);
        glBindVertexArrayOES(vertexArray);
        
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
        
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 28, BUFFER_OFFSET(0));
        glEnableVertexAttribArray(GLKVertexAttribColor);
        glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, 28, BUFFER_OFFSET(12));
        
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glBindVertexArrayOES(0);
	}
	
    return self;
}

@end
