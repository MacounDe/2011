//
//  Sky.h
//  HID4
//
//  Created by Matthias Krauß on 21.08.11.
//  Copyright 2011 Matthias Krauß. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Camera, OGLResourceManager;

@interface Sky : NSObject {

}

+ (Sky*) sky;

- (void) renderWithCamera:(Camera*)camera resources:(OGLResourceManager*)resources;

@end
