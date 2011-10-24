//
//  OpenGLDemoView.h
//  OpenGL Demo
//
//  Created by Daniel Dönigus on 10.08.11.
//  Copyright 2011 PRODEVCON. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface OpenGLDemoView : NSOpenGLView
{
    BOOL texturesInitialized;
    GLint textureWood;
    GLint textureJeans;
    GLint textureEarth;
    GLint textureMoon;
    
    GLuint textureZ;
    
    GLfloat angleHorizontal;
    GLfloat angleVertical;
    GLfloat distance;
    
    NSPoint lastMousePosition;
    BOOL mousePressed;
    
    NSTrackingArea* trackingArea;
}

- (void) drawRect: (NSRect) bounds;

@end
