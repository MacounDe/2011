//
//  OGLResourceManager.h
//  HID4
//
//  Created by Matthias Krauß on 20.08.11.
//  Copyright 2011 Matthias Krauß. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>

@interface OGLResourceManager : NSObject {

	NSMutableDictionary* shaderPrograms;
	NSMutableDictionary* textures;
	NSMutableDictionary* vertexBufferObjects;
	NSMutableDictionary* vboLengths;
	
}

+ (OGLResourceManager*)resourceManager;

- (GLuint) shaderProgramWithName:(NSString*)name;
- (GLuint) buildShaderProgramWithName:(NSString*)name baseName:(NSString*)baseName;

- (GLuint) textureWithName:(NSString*)name;
- (GLuint) buildTextureWithName:(NSString*)name imageUrl:(NSURL*)url mipmap:(BOOL)mipmap;
- (GLuint) buildTextureWithName:(NSString *)name 
                         bitmap:(void*)bitmap
                          width:(int)width
                         height:(int)height
                    bitsPerComp:(int)bitsPerComp
                    compsPerPix:(int)compsPerPix
               storeCompsPerPix:(int)pseudoCompsPerPix
                         mipmap:(BOOL)mipmap
                         repeat:(BOOL)repeat;

- (GLuint) vboWithName:(NSString*)name;
- (GLuint) lengthOfVBOWithName:(NSString*)name;

- (GLuint) buildVBO:(NSString*)name buffer:(const void*)buffer length:(int)lengthBytes;

@end
