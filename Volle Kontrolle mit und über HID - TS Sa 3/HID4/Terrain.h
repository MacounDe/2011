//
//  Terrain.h
//  HID4
//
//  Created by Matthias Krauß on 18.08.11.
//  Copyright 2011 Matthias Krauß. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>

@class Camera, OGLResourceManager;

@interface Terrain : NSObject {

}

+ (Terrain*) terrain;

- (void) renderWithCamera:(Camera*)camera resources:(OGLResourceManager*)resources;

@end
