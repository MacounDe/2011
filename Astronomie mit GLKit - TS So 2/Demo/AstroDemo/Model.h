//
//  Model.h
//  Space
//
//  Created by Daniel Dönigus on 04.01.11.
//  Copyright 2011 PRODEVCON. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

@interface Model : NSObject {
	GLushort *indices;
    GLuint elementCount;
    
    GLfloat *buffer;
    GLuint vertexArray;
    GLuint vertexBuffer;
    GLuint indexBuffer;
    
    GLKTextureInfo* textureInfo;
}

@property (readonly) GLushort* indices;
@property (readonly) GLuint elementCount;
@property (readonly) GLfloat* buffer;
@property (readonly) GLuint vertexArray;
@property (readonly) GLuint vertexBuffer;
@property (readonly) GLuint indexBuffer;
@property (readonly) GLKTextureInfo* textureInfo;

@end
