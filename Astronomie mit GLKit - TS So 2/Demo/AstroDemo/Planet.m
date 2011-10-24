//
//  Planet.m
//  Space
//
//  Created by Daniel Dönigus on 14.01.11.
//  Copyright 2011 PRODEVCON. All rights reserved.
//

#import "Planet.h"

#define NUMBER_OF_SLICES 60
#define NUMBER_OF_PARALLELS 30

@implementation Planet

//Creating buffer for sphere mesh consisting of positions, normals and texture coordinates. Also, creates
//indices to send triangles to graphics card.
-(void) createSphereWithRadius:(float) radius {
	
	int numVertices = ( NUMBER_OF_PARALLELS + 1 ) * ( NUMBER_OF_SLICES + 1 );
	int numIndices = NUMBER_OF_PARALLELS * NUMBER_OF_SLICES * 6;
	float angleStep = (2.0f * M_PI) / ((float) NUMBER_OF_SLICES);
	
    buffer = malloc(sizeof(GLfloat) * 8 * numVertices);
    indices = malloc(sizeof(GLushort) * numIndices);
    
    for(int i = 0; i < NUMBER_OF_PARALLELS + 1; i++) {
    	for(int j = 0; j < NUMBER_OF_SLICES + 1; j++) {
    		int vertex = ( i * (NUMBER_OF_SLICES + 1) + j ) * 8; 
    		
    		buffer[vertex + 0] = radius * sinf(angleStep * (float)i) * sinf(angleStep * (float)j);
            buffer[vertex + 1] = radius * cosf(angleStep * (float)i);
            buffer[vertex + 2] = radius * sinf(angleStep * (float)i) * cosf(angleStep * (float)j);
    		
            buffer[vertex + 3] = buffer[vertex + 0] / radius;
            buffer[vertex + 4] = buffer[vertex + 1] / radius;
            buffer[vertex + 5] = buffer[vertex + 2] / radius;
    		
            buffer[vertex + 6] = (float) j / (float) NUMBER_OF_SLICES;
            buffer[vertex + 7] = ((float) i ) / (float) NUMBER_OF_PARALLELS;
    	}
    }
	
	if(indices != NULL){
		GLushort *indexBuf = indices;
		for (int i = 0; i < NUMBER_OF_PARALLELS ; i++) {
			for (int j = 0; j < NUMBER_OF_SLICES; j++) {
				*indexBuf++  = i * ( NUMBER_OF_SLICES + 1 ) + j;
				*indexBuf++ = ( i + 1 ) * ( NUMBER_OF_SLICES + 1 ) + j;
				*indexBuf++ = ( i + 1 ) * ( NUMBER_OF_SLICES + 1 ) + ( j + 1 );
				
				*indexBuf++ = i * ( NUMBER_OF_SLICES + 1 ) + j;
				*indexBuf++ = ( i + 1 ) * ( NUMBER_OF_SLICES + 1 ) + ( j + 1 );
				*indexBuf++ = i * ( NUMBER_OF_SLICES + 1 ) + ( j + 1 );
			}
		}
	}
	
	elementCount = numIndices;
}

//Vertex array object for planet meshes
- (id)initWithRadius:(float) radius colorMapName:(NSString*) colorMapName normalMapName:(const char*) normalMapName {
    if ((self = [super init])) {
        [self createSphereWithRadius:radius];
        
		if(colorMapName != NULL) {
            NSString *path = [[NSBundle mainBundle] pathForResource: colorMapName ofType:@"jpg"];
            textureInfo = [GLKTextureLoader textureWithContentsOfFile:path                                                                      
                                                              options:nil                                                                              
                                                                error:nil];
		}
        
        glGenBuffers(1, &vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
        glBufferData(GL_ARRAY_BUFFER, ((NUMBER_OF_PARALLELS + 1) * (NUMBER_OF_SLICES + 1))*4*8, buffer, GL_STATIC_DRAW);
        
        
        glGenBuffers(1, &indexBuffer);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices)*elementCount, indices, GL_STATIC_DRAW);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
        
        glGenVertexArraysOES(1, &vertexArray);
        glBindVertexArrayOES(vertexArray);
        
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
        
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(0));
        glEnableVertexAttribArray(GLKVertexAttribNormal);
        glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(12));
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(24));
        glDisableVertexAttribArray(GLKVertexAttribColor);
        
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
        
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        
        glBindVertexArrayOES(0);
    }
	
    return self;
}

- (void)dealloc
{
}

@end
