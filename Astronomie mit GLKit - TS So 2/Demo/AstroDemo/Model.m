//
//  Model.m
//  Space
//
//  Created by Daniel Dönigus on 04.01.11.
//  Copyright 2011 PRODEVCON. All rights reserved.
//

#import "Model.h"
//#import "QATransform.h"

@implementation Model

@synthesize indices;
@synthesize elementCount;
@synthesize buffer;
@synthesize vertexArray;
@synthesize vertexBuffer;
@synthesize indexBuffer;
@synthesize textureInfo;

- (id)init {
    if ((self = [super init])) {
    }
	
    return self;
}

- (void)dealloc
{
	if (indices)
		free(indices);
    if (buffer)
        free(buffer);
    
    glDeleteBuffers(1, &vertexBuffer);
    glDeleteVertexArraysOES(1, &vertexArray);
    glDeleteBuffers(1, &indexBuffer);
}

@end
