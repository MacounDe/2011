//
//  Game.h
//  HID4
//
//  Created by Matthias Krauß on 20.08.11.
//  Copyright 2011 Matthias Krauß. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class Terrain, Camera, Sky, OGLResourceManager;

@interface Game : NSObject {

	NSTimer* timer;
	Terrain* terrain;
	Sky* sky;
	NSArray* players;
	
}

@property (readonly, retain) NSArray* players;

- (void) renderWithCamera:(Camera*)camera resources:(OGLResourceManager*)resources;

@end


