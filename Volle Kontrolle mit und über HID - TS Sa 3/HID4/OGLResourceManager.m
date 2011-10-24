//
//  OGLResourceManager.m
//  HID4
//
//  Created by Matthias Krauß on 20.08.11.
//  Copyright 2011 Matthias Krauß. All rights reserved.
//

#import "OGLResourceManager.h"
#import <OpenGL/glu.h>
#include "geometry.h"
#include "glTools.h"

@interface OGLResourceManager ()
	
@property (readwrite, retain) NSMutableDictionary* shaderPrograms;
@property (readwrite, retain) NSMutableDictionary* textures;
@property (readwrite, retain) NSMutableDictionary* vertexBufferObjects;
@property (readwrite, retain) NSMutableDictionary* vboLengths;

- (GLuint) buildProgramWithName:(NSString*)name;
- (GLuint) buildShaderWithType:(GLenum)type name:(NSString*)name;
- (GLuint) loadTexData:(void*)bitmap
                 width:(int)width
                height:(int)height
           bitsPerComp:(int)bitsPerComp
           compsPerPix:(int)compsPerPix
      storeCompsPerPix:(int)pseudoCompsPerPix
                mipmap:(BOOL)mipmap
                repeat:(BOOL)repeat;
- (GLuint) loadTexture:(NSURL*)url mipmap:(BOOL)mipmap;

@end

@implementation OGLResourceManager

@synthesize shaderPrograms;
@synthesize textures;
@synthesize vertexBufferObjects;
@synthesize vboLengths;

+ (OGLResourceManager*)resourceManager {
	return [[[OGLResourceManager alloc] init] autorelease];
}

- (id) init {
	self = [super init];
	if (!self) return nil;
	self.shaderPrograms = [NSMutableDictionary dictionary];
	self.textures = [NSMutableDictionary dictionary];
	self.vertexBufferObjects = [NSMutableDictionary dictionary];
	self.vboLengths = [NSMutableDictionary dictionary];
	return self;
}

- (void) dealloc {
	//TODO: Release in OGL ******
	self.shaderPrograms = nil;
	self.textures = nil;
	self.vertexBufferObjects = nil;
	self.vboLengths = nil;
	[super dealloc];
}

- (GLuint) shaderProgramWithName:(NSString*)name {
	NSNumber* num = [self.shaderPrograms objectForKey:name];
	if (!num) return 0;
	return [num intValue];
}

- (GLuint) buildShaderProgramWithName:(NSString*)name baseName:(NSString*)baseName {
	GLuint program = [self buildProgramWithName:baseName];
	if (!program) return 0;
	[self.shaderPrograms setObject:[NSNumber numberWithInt:program] forKey:name];
	return program;
}

- (GLuint) textureWithName:(NSString*)name {
	NSNumber* num = [self.textures objectForKey:name];
	if (!num) return 0;
	return [num intValue];
}	

- (GLuint) buildTextureWithName:(NSString*)name imageUrl:(NSURL*)url mipmap:(BOOL)mipmap {
	GLuint tex = [self loadTexture:url mipmap:mipmap];
	NSAssert1(tex,@"texture load failed: %@",url);
	[self.textures setObject:[NSNumber numberWithInt:tex] forKey:name];
	return tex;
}

- (GLuint) buildTextureWithName:(NSString *)name 
                         bitmap:(void*)bitmap
                          width:(int)width
                         height:(int)height
                    bitsPerComp:(int)bitsPerComp
                    compsPerPix:(int)compsPerPix
               storeCompsPerPix:(int)pseudoCompsPerPix
                         mipmap:(BOOL)mipmap
                         repeat:(BOOL)repeat {
	GLuint tex = [self loadTexData:bitmap
                             width:width
                            height:height
                       bitsPerComp:bitsPerComp
                       compsPerPix:compsPerPix
                  storeCompsPerPix:pseudoCompsPerPix
                            mipmap:mipmap
                            repeat:repeat];
	NSAssert1(tex,@"texture load failed: %@",name);
	[self.textures setObject:[NSNumber numberWithInt:tex] forKey:name];
	return tex;
}    

- (GLuint) vboWithName:(NSString*)name {
	NSNumber* num = [self.vertexBufferObjects objectForKey:name];
	if (!num) return 0;
	return [num intValue];
}

- (GLuint) lengthOfVBOWithName:(NSString*)name {
	NSNumber* num = [self.vboLengths objectForKey:name];
	if (!num) return 0;
	return [num intValue];
}	

- (GLuint) buildVBO:(NSString*)name buffer:(const void*)buffer length:(int)lengthBytes {
	GLuint vbo;
	glError();
	glGenBuffers(1, &vbo);
	glError();
	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	glError();
	glBufferData(GL_ARRAY_BUFFER, lengthBytes, buffer, GL_STATIC_DRAW);
	glError();
	[self.vertexBufferObjects setObject:[NSNumber numberWithInt:vbo] forKey:name];
	[self.vboLengths setObject:[NSNumber numberWithInt:lengthBytes] forKey:name];
	return vbo;
}	

//------------------- private ------------------

- (GLuint) buildShaderWithType:(GLenum)type name:(NSString*)name {
	GLuint shader = glCreateShader(type);
	NSString* extension = (type==GL_VERTEX_SHADER) ? @"vs" : @"fs";
	NSURL* shaderURL = [[NSBundle mainBundle] URLForResource:name withExtension:extension];
	NSError* err = nil;
	NSString* shaderString = [NSString stringWithContentsOfURL:shaderURL usedEncoding:nil error:&err];
	if (err) {
		[[NSAlert alertWithError:err] runModal];
		[NSApp terminate:self];
	}
	GLchar* shaderSource = (GLchar*)[shaderString cStringUsingEncoding:NSASCIIStringEncoding];
	GLint shaderLength = strlen(shaderSource);
	glShaderSource(shader, 1, (const GLchar**)(&shaderSource), &shaderLength);
	glCompileShader(shader);
	GLsizei len = 1000;
	GLchar log[len];
	glGetShaderInfoLog (shader, len, &len, log);
	return shader;
}

- (GLuint) buildProgramWithName:(NSString*)name {
	GLuint vs = [self buildShaderWithType:GL_VERTEX_SHADER name:name];
	GLuint fs = [self buildShaderWithType:GL_FRAGMENT_SHADER name:name];
	GLuint pgm = glCreateProgram();
	glAttachShader(pgm, vs);
	glAttachShader(pgm, fs);
	glLinkProgram(pgm);
	glValidateProgram(pgm);
	GLsizei len = 1000;
	GLchar log[len];
	glGetProgramInfoLog (pgm, len, &len, log);
	return pgm;
}

- (GLuint) loadTexData:(void*)bitmap
                 width:(int)width
                height:(int)height
           bitsPerComp:(int)bitsPerComp
           compsPerPix:(int)compsPerPix
      storeCompsPerPix:(int)pseudoCompsPerPix
                mipmap:(BOOL)mipmap
                repeat:(BOOL)repeat {
	GLenum dim = (height>1) ? GL_TEXTURE_2D : GL_TEXTURE_1D;
	
	GLenum format,internalFormat,type;
    
	if (compsPerPix==1 && bitsPerComp==32) {
		internalFormat = GL_LUMINANCE32F_ARB;
		format = GL_LUMINANCE;
		type = GL_FLOAT;
	} else if (compsPerPix==1 && bitsPerComp==16) {
		internalFormat = GL_LUMINANCE;
		format = GL_LUMINANCE;
		type = GL_UNSIGNED_SHORT;
	} else if (compsPerPix==1 && bitsPerComp==8) {
		internalFormat = GL_LUMINANCE;
		format = GL_LUMINANCE;
		type = GL_UNSIGNED_BYTE;
	} else if (compsPerPix==3 && bitsPerComp==8) {
		internalFormat = GL_RGB;
		format = (pseudoCompsPerPix>3) ? GL_RGBA : GL_RGB;
		type = GL_UNSIGNED_BYTE;
	} else if (compsPerPix==4 && bitsPerComp==8) {
		internalFormat = GL_RGBA;
		format = (pseudoCompsPerPix>3) ? GL_RGBA : GL_RGB;
		type = GL_UNSIGNED_BYTE;
	} else NSAssert(NO,@"unknown bitmap component count");
    GLenum clampMode = repeat ? GL_REPEAT : GL_CLAMP_TO_EDGE;
    GLenum minMode = mipmap ? GL_LINEAR_MIPMAP_LINEAR : GL_LINEAR;
    
	glEnable(dim);
	GLuint texId;
	glGenTextures(1, &texId);
	glBindTexture(dim, texId);
	if (dim==GL_TEXTURE_1D) {
		if (mipmap) gluBuild1DMipmaps (GL_TEXTURE_1D, internalFormat, width, format, type, bitmap);
		else glTexImage1D(GL_TEXTURE_1D, 0, internalFormat, width, 0, format, type, bitmap);
	} else {
		if (mipmap) gluBuild2DMipmaps (GL_TEXTURE_2D, internalFormat, width, height, format, type, bitmap);
		else glTexImage2D(GL_TEXTURE_2D, 0, internalFormat, width, height, 0, format, type, bitmap);
	}
	glTexParameterf(dim, GL_TEXTURE_WRAP_S, clampMode);
    if (dim==GL_TEXTURE_2D) glTexParameterf(dim, GL_TEXTURE_WRAP_T, clampMode);
    glTexParameterf(dim, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(dim, GL_TEXTURE_MIN_FILTER, minMode);
	return texId;
}


- (GLuint) loadTexture:(NSURL*)url mipmap:(BOOL)mipmap {
	NSData* imgData = [NSData dataWithContentsOfURL:url];
	NSBitmapImageRep* ir = [NSBitmapImageRep imageRepWithData:imgData];

	int bitsPerComp = [ir bitsPerSample];
	int compsPerPix = [ir samplesPerPixel];
	int pseudoCompsPerPix = [ir bitsPerPixel]/bitsPerComp;
	int width = [ir pixelsWide];
	int height = [ir pixelsHigh];
	void* bitmap = [ir bitmapData];
    return [self loadTexData:bitmap
                       width:width
                      height:height
                 bitsPerComp:bitsPerComp
                 compsPerPix:compsPerPix
            storeCompsPerPix:pseudoCompsPerPix
                      mipmap:mipmap
                      repeat:NO];
}


@end
