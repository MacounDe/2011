//
//  MyOpenGLView.h
//  HID4
//
//  Created by Matthias Krauß on 18.08.11.
//  Copyright 2011 Matthias Krauß. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>

@class Camera, Game, OGLResourceManager;

@interface MyOpenGLView : NSOpenGLView {

	Game* game;
	Camera* camera;
	OGLResourceManager* resourceManager;
}

@property (assign) IBOutlet Game* game;

@end
