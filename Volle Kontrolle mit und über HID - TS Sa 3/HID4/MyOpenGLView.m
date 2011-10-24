//
//  MyOpenGLView.m
//  HID4
//
//  Created by Matthias Krauß on 18.08.11.
//  Copyright 2011 Matthias Krauß. All rights reserved.
//

#import <OpenGL/glu.h>
#import "MyOpenGLView.h"
#import "Terrain.h"
#import "Player.h"
#import "Camera.h"
#import "HID4AppDelegate.h"
#import "OGLResourceManager.h"
#include "glTools.h"

@interface MyOpenGLView ()

@property (readwrite, retain) Camera* camera;
@property (readwrite, retain) OGLResourceManager* resourceManager;

@end

@implementation MyOpenGLView

@synthesize camera;
@synthesize game;
@synthesize resourceManager;

- (id) initWithCoder:(NSCoder*)coder {
    self = [super initWithCoder:coder];
	if (!self) return nil;
	self.resourceManager = [OGLResourceManager resourceManager];
	self.camera = [Camera camera];
	[camera setNear:5.0];
	[camera setFar:6000.0];
	[camera setFovy:60.0];
	vec3 camPos = { 100, 550, 0 };
	vec3 camPoi = { 0, 500, 0 };
	[camera setPos:camPos];
	[camera setPoi:camPoi];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(gameStep:)
												 name:@"Game step"
											   object:nil];
    return self;
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.camera = nil;
	self.resourceManager = nil;
	[super dealloc];
}

- (void) prepareOpenGL {
	[self reshape];	
	glEnable(GL_NORMALIZE);
	glEnable(GL_DEPTH_TEST);
	glDepthFunc(GL_LESS);
	glEnable(GL_BLEND);
	glEnable(GL_CULL_FACE);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

- (void) reshape {
	NSRect rect = [self bounds];
	rect.size = [self convertSize:rect.size toView:nil];
	float width = NSWidth(rect);
	float height = NSHeight(rect);
	glViewport(0.0, 0.0, width, height);
	float aspect = width / height;
	[camera setAspect:aspect];
	[camera assignProjectionMatrix];
}

- (void) gameStep:(NSNotification*)notification {
	[self.camera behaveForGame:self.game];
	[self setNeedsDisplay:YES];
}


- (void) drawRect:(NSRect)r {
    static NSTimeInterval tiStart = 0;
    static int frameCounter = 0;
    frameCounter++;
    if (frameCounter>=100) {
        NSTimeInterval tiEnd = [NSDate timeIntervalSinceReferenceDate];
        double fps = 100.0 / (tiEnd - tiStart);
        NSLog(@"fps: %f",fps);
        frameCounter -=100;
        tiStart = tiEnd;
    }
//	glPolygonMode( GL_FRONT_AND_BACK, GL_LINE );
	glClearColor(0,1,0,1);
	glClear( GL_DEPTH_BUFFER_BIT );
	[self.camera assignModelviewMatrix];
	
	[self.game renderWithCamera:self.camera resources:self.resourceManager];
	glError();
	[[NSOpenGLContext currentContext] flushBuffer];
	
}


@end
