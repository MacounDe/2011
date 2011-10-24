//
//  OpenGLDemoView.m
//  OpenGL Demo
//
//  Created by Daniel Dönigus on 10.08.11.
//  Copyright 2011 PRODEVCON. All rights reserved.
//

#import "OpenGLDemoView.h"
#include <OpenGL/gl.h>
#include <GLUT/GLUT.h>
#include "OpenGL_DemoAppDelegate.h"
#include "Transformation.h"

#include "GLUHelper.h"

@implementation OpenGLDemoView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        distance = 2;
    }
    
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        distance = 2;
    }

    return self;
}

- (GLint) loadTextureWithName:(NSString*) filename andExtension:(NSString*) fileExtension {
    CFBundleRef gameBundle = CFBundleGetMainBundle();
    
    CFStringRef subdirectory = NULL;
    CFURLRef fileLocation;
    fileLocation = CFBundleCopyResourceURL(gameBundle, (__bridge CFStringRef)filename,
                                           (__bridge CFStringRef)fileExtension, subdirectory);
    
    CGImageSourceRef myImageSourceRef = CGImageSourceCreateWithURL (fileLocation, NULL);
    CGImageRef myImageRef = CGImageSourceCreateImageAtIndex (myImageSourceRef, 0, NULL);
    GLuint myTextureName;
    size_t width = CGImageGetWidth(myImageRef);
    size_t height = CGImageGetHeight(myImageRef);
    CGRect rect = {{0, 0}, {width, height}};
    void * myData = calloc(width * 4, height);
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextRef myBitmapContext = CGBitmapContextCreate (myData,
                                                          width, height, 8,
                                                          (size_t)(width*4), space,
                                                          kCGBitmapByteOrder32Host |
                                                          kCGImageAlphaPremultipliedFirst);
    CGContextSetBlendMode(myBitmapContext, kCGBlendModeCopy);
    CGContextDrawImage(myBitmapContext, rect, myImageRef);
    CGContextRelease(myBitmapContext);
    glPixelStorei(GL_UNPACK_ROW_LENGTH, (GLint) width);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glGenTextures(1, &myTextureName);
    glBindTexture(GL_TEXTURE_2D, myTextureName);
    glTexParameteri(GL_TEXTURE_2D,
                    GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, (GLsizei)width, (GLsizei)height,
                 0, GL_BGRA_EXT, GL_UNSIGNED_INT_8_8_8_8_REV, myData);
    free(myData);
    
    return myTextureName;
}

- (void) initializeZTexture {
    glGenTextures(1, &textureZ);
}

- (void) awakeFromNib {
    texturesInitialized = NO;
    
    OpenGL_DemoAppDelegate* delegate = [[NSApplication sharedApplication] delegate];
    
    [delegate addObserver:self forKeyPath:@"modelType" options:NSKeyValueObservingOptionNew context:@"REDRAW"];
    [delegate addObserver:self forKeyPath:@"fillingType" options:NSKeyValueObservingOptionNew context:@"REDRAW"];

    [delegate addObserver:self forKeyPath:@"materialAmbient" options:NSKeyValueObservingOptionNew context:@"REDRAW"];
    [delegate addObserver:self forKeyPath:@"materialDiffuse" options:NSKeyValueObservingOptionNew context:@"REDRAW"];
    [delegate addObserver:self forKeyPath:@"materialSpecular" options:NSKeyValueObservingOptionNew context:@"REDRAW"];
    
    [delegate addObserver:self forKeyPath:@"lightAmbient" options:NSKeyValueObservingOptionNew context:@"REDRAW"];
    [delegate addObserver:self forKeyPath:@"lightDiffuse" options:NSKeyValueObservingOptionNew context:@"REDRAW"];
    [delegate addObserver:self forKeyPath:@"lightSpecular" options:NSKeyValueObservingOptionNew context:@"REDRAW"];
    [delegate addObserver:self forKeyPath:@"lightSpecularExponent" options:NSKeyValueObservingOptionNew context:@"REDRAW"];
    
    [delegate addObserver:self forKeyPath:@"texture" options:NSKeyValueObservingOptionNew context:@"REDRAW"];
    
    [delegate addObserver:self forKeyPath:@"cameraType" options:NSKeyValueObservingOptionNew context:@"REDRAW"];

    [delegate addObserver:self forKeyPath:@"left" options:NSKeyValueObservingOptionNew context:@"REDRAW"];
    [delegate addObserver:self forKeyPath:@"right" options:NSKeyValueObservingOptionNew context:@"REDRAW"];
    [delegate addObserver:self forKeyPath:@"top" options:NSKeyValueObservingOptionNew context:@"REDRAW"];
    [delegate addObserver:self forKeyPath:@"bottom" options:NSKeyValueObservingOptionNew context:@"REDRAW"];
    [delegate addObserver:self forKeyPath:@"nearVal" options:NSKeyValueObservingOptionNew context:@"REDRAW"];
    [delegate addObserver:self forKeyPath:@"farVal" options:NSKeyValueObservingOptionNew context:@"REDRAW"];

    [delegate addObserver:self forKeyPath:@"aspectRatio" options:NSKeyValueObservingOptionNew context:@"REDRAW"];
    [delegate addObserver:self forKeyPath:@"nearZ" options:NSKeyValueObservingOptionNew context:@"REDRAW"];
    [delegate addObserver:self forKeyPath:@"farZ" options:NSKeyValueObservingOptionNew context:@"REDRAW"];
    [delegate addObserver:self forKeyPath:@"fovY" options:NSKeyValueObservingOptionNew context:@"REDRAW"];
    
    [delegate addObserver:self forKeyPath:@"showZBuffer" options:NSKeyValueObservingOptionNew context:@"REDRAW"];

    [self setNeedsDisplay:YES];

    NSRect rect = [self frame];
    trackingArea = [[NSTrackingArea alloc] initWithRect:rect options: (NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveInKeyWindow) owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];
}

- (void)prepareOpenGL {
    textureJeans = [self loadTextureWithName:@"jeans" andExtension:@"jpg"];
    textureMoon = [self loadTextureWithName:@"moonmap1k" andExtension:@"jpg"];
    textureEarth = [self loadTextureWithName:@"earthmap1k" andExtension:@"jpg"];
    textureWood = [self loadTextureWithName:@"wood" andExtension:@"jpg"];    
}

- (void)updateTrackingAreas {
    [self removeTrackingArea:trackingArea];
    NSRect rect = [self frame];
    trackingArea = [[NSTrackingArea alloc] initWithRect:rect
                                                options: (NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveInKeyWindow)
                                                  owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self setNeedsDisplay:YES];
}

-(void) updateColor {
    OpenGL_DemoAppDelegate* delegate = [[NSApplication sharedApplication] delegate];
    
    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);
    
    GLfloat materialAmbient[4] = { [[delegate materialAmbient] redComponent],
        [[delegate materialAmbient] greenComponent],
        [[delegate materialAmbient] blueComponent],
        [[delegate materialAmbient] alphaComponent] };
    glMaterialfv(GL_FRONT, GL_AMBIENT, materialAmbient);
    GLfloat materialDiffuse[4] = { [[delegate materialDiffuse] redComponent],
        [[delegate materialDiffuse] greenComponent],
        [[delegate materialDiffuse] blueComponent],
        [[delegate materialDiffuse] alphaComponent] };
    glMaterialfv(GL_FRONT, GL_DIFFUSE, materialDiffuse);
    GLfloat materialSpecular[4] = { [[delegate materialSpecular] redComponent],
        [[delegate materialSpecular] greenComponent],
        [[delegate materialSpecular] blueComponent],
        [[delegate materialSpecular] alphaComponent] };
    glMaterialfv(GL_FRONT, GL_SPECULAR, materialSpecular);
    glMaterialf(GL_FRONT, GL_SHININESS, [[delegate lightSpecularExponent] floatValue]);
    
    GLfloat lightAmbient[4] = { [[delegate lightAmbient] redComponent],
        [[delegate lightAmbient] greenComponent],
        [[delegate lightAmbient] blueComponent],
        [[delegate lightAmbient] alphaComponent] };
    glLightfv(GL_LIGHT0, GL_AMBIENT, lightAmbient);
    GLfloat lightDiffuse[4] = { [[delegate lightDiffuse] redComponent],
        [[delegate lightDiffuse] greenComponent],
        [[delegate lightDiffuse] blueComponent],
        [[delegate lightDiffuse] alphaComponent] };
    glLightfv(GL_LIGHT0, GL_DIFFUSE, lightDiffuse);
    GLfloat lightSpecular[4] = { [[delegate lightSpecular] redComponent],
        [[delegate lightSpecular] greenComponent],
        [[delegate lightSpecular] blueComponent],
        [[delegate lightSpecular] alphaComponent] };
    glLightfv(GL_LIGHT0, GL_SPECULAR, lightSpecular);
    
    GLfloat position[3] = { 2, 2, 2 };
    glLightfv(GL_LIGHT0, GL_POSITION, position);
}

-(void) doTransformations {
    OpenGL_DemoAppDelegate* delegate = [[NSApplication sharedApplication] delegate];
    NSArray* transformations = [delegate transformations];
    
    for (id trans in transformations) {
        if ([trans transformationType] == TRANSFORMATION_TRANSLATION) {
            glTranslatef([trans translateX], [trans translateY], [trans translateZ]);
        }
        if ([trans transformationType] == TRANSFORMATION_SCALE) {
            glScalef([trans scaleX], [trans scaleY], [trans scaleZ]);
        }
        if ([trans transformationType] == TRANSFORMATION_ROTATION) {
            if ([trans rotationAxis] == AXIS_X) {
                glRotatef([trans rotation], 1, 0, 0);
            }
            if ([trans rotationAxis] == AXIS_Y) {
                glRotatef([trans rotation], 0, 1, 0);
            }
            if ([trans rotationAxis] == AXIS_Z) {
                glRotatef([trans rotation], 0, 0, 1);
            }
        }
    }
}

-(void) drawCoordinateSystem {
    glDisable(GL_LIGHTING);
    glEnable(GL_COLOR);
    glDisable(GL_TEXTURE_2D);
    glBegin(GL_LINES);
    glColor3f(1.0f,0.0f,0.0f);
    glVertex3f( 0.0f, 0.0f, 0.0f);
    glVertex3f( 1.0f, 0.0f, 0.0f);
    glEnd();
    glBegin(GL_LINES);
    glColor3f(0.0f,1.0f,0.0f);
    glVertex3f( 0.0f, 0.0f, 0.0f);
    glVertex3f( 0.0f, 1.0f, 0.0f);
    glEnd();
    glBegin(GL_LINES);
    glColor3f(0.0f,0.0f,1.0f);
    glVertex3f( 0.0f, 0.0f, 0.0f);
    glVertex3f( 0.0f, 0.0f, 1.0f);
    glEnd();
    glDisable(GL_COLOR);
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_LIGHTING);
}

-(void) grabScreenAndDrawZBufferInRect: (NSRect) bounds {
    int width = bounds.size.width;
    int height = bounds.size.height;
    
    GLfloat *pixels = malloc(width*height*sizeof(GLfloat));
    glReadPixels(0, 0, width, height, GL_DEPTH_COMPONENT, GL_FLOAT, pixels);
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_LIGHTING);
    
    glPixelStorei(GL_UNPACK_ROW_LENGTH, width);
    
    glDrawPixels(width, height, GL_LUMINANCE, GL_FLOAT, pixels);
    free(pixels);
}

-(void) drawRect: (NSRect) bounds {
    if (!texturesInitialized) {
        texturesInitialized = YES;
    }
    
    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    OpenGL_DemoAppDelegate* delegate = [[NSApplication sharedApplication] delegate];
    
    [self updateColor];

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    if ([delegate.cameraType intValue] == 0) {
        glOrtho([delegate.left doubleValue], 
                [delegate.right doubleValue], 
                [delegate.bottom doubleValue], 
                [delegate.top doubleValue], 
                [delegate.nearVal doubleValue], 
                [delegate.farVal doubleValue]);
    } else {
        double aspect = [delegate.aspectRatio doubleValue];
        
        gluPerspective([delegate.fovY doubleValue], 
                       aspect, 
                       [delegate.nearZ doubleValue], 
                       [delegate.farZ doubleValue]);
    }
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glPushMatrix();
    glTranslatef(0, 0, -distance);
    glRotatef(angleVertical, 1, 0, 0);
    glRotatef(angleHorizontal, 0, 1, 0);

    NSLog ( @"AngleHorizontal: %f", angleHorizontal );
    
    [self drawCoordinateSystem];
    
    [self doTransformations];
    
    if ([[delegate texture] isEqualTo: @"Wood"]) {
        glEnable(GL_TEXTURE_2D);
        glBindTexture(GL_TEXTURE_2D, textureWood);
    } else if ([[delegate texture] isEqualTo: @"Cloth"]) {
        glEnable(GL_TEXTURE_2D);
        glBindTexture(GL_TEXTURE_2D, textureJeans);
    } else if ([[delegate texture] isEqualTo: @"Moon"]) {
        glEnable(GL_TEXTURE_2D);
        glBindTexture(GL_TEXTURE_2D, textureMoon);
    } else if ([[delegate texture] isEqualTo: @"World"]) {
        glEnable(GL_TEXTURE_2D);
        glBindTexture(GL_TEXTURE_2D, textureEarth);
    } else {
        glDisable(GL_TEXTURE_2D);
    }
    
    if ([[delegate fillingType] isEqualToNumber:[NSNumber numberWithInt:0]]) {
        if ([[delegate modelType] isEqualToNumber:[NSNumber numberWithInt:0]]) {
            glutWireCube(1.0);
        } else if ([[delegate modelType] isEqualToNumber:[NSNumber numberWithInt:1]]) {
            glutWireSphere(0.5, 20, 20);
        } else if ([[delegate modelType] isEqualToNumber:[NSNumber numberWithInt:2]]) {
            glutWireTorus(0.25, 0.5, 20, 20);
        } else if ([[delegate modelType] isEqualToNumber:[NSNumber numberWithInt:3]]) {
            glutWireTeapot(0.5);
        }
    } else if ([[delegate fillingType] isEqualToNumber:[NSNumber numberWithInt:1]]) {
        if ([[delegate modelType] isEqualToNumber:[NSNumber numberWithInt:0]]) {
            glutSolidCubeTextured(1.0);
        } else if ([[delegate modelType] isEqualToNumber:[NSNumber numberWithInt:1]]) {
            glutSolidSphereTextured(0.5, 40, 40);
        } else if ([[delegate modelType] isEqualToNumber:[NSNumber numberWithInt:2]]) {
            glutSolidTorusTextured(0.25, 0.5, 20, 20);
        } else if ([[delegate modelType] isEqualToNumber:[NSNumber numberWithInt:3]]) {
            glutSolidTeapot(0.5);
        }
    }

    glPopMatrix();
    
    if ([delegate.showZBuffer intValue] == 1) {
        [self grabScreenAndDrawZBufferInRect:bounds];
    }
    
    glFlush();
}

- (void) mouseDown:(NSEvent*) event {
    NSUInteger mouseButtons = [NSEvent pressedMouseButtons];
    
    if (mouseButtons & 0x01) {
        NSLog(@"Mouse down");
        lastMousePosition = [NSEvent mouseLocation];
        mousePressed = YES;
    }
}

- (void) mouseUp:(NSEvent*) event {
    NSUInteger mouseButtons = [NSEvent pressedMouseButtons];
    
    if (!(mouseButtons & 0x01)) {
        NSLog(@"Mouse up");
        mousePressed = NO;
    }
}

- (void)mouseDragged:(NSEvent *)theEvent {
    if (mousePressed == YES) {
        
        NSPoint mousePosition = [NSEvent mouseLocation];
        CGFloat deltaX = mousePosition.x - lastMousePosition.x;
        CGFloat deltaY = mousePosition.y - lastMousePosition.y;
        
        angleHorizontal = (angleHorizontal - deltaX);
        if (angleHorizontal > 360) {
            angleHorizontal -= 360;
        }
        if (angleHorizontal < 0) {
            angleHorizontal += 360;
        }
        angleVertical = (angleVertical + deltaY);
        if (angleVertical > 90) {
            angleVertical = 90;
        }
        if (angleVertical < -90) {
            angleVertical = -90;
        }

        NSLog(@"New Position: %f, %f", angleHorizontal, angleVertical);

        [self setNeedsDisplay:YES];
        
        lastMousePosition = [NSEvent mouseLocation];
    }
}

- (void) scrollWheel:(NSEvent *)theEvent {
    distance += [theEvent deltaY]/10.0f;

    if (distance > 10) {
        distance = 10;
    } else if (distance < 2) {
        distance = 2;
    }

    NSLog(@"New Distance: %f", distance);

    [self setNeedsDisplay:YES];
}

- (void)reshape
{
    NSRect rect = [self bounds];
    rect.size = [self convertSize:rect.size toView:nil];
    glViewport(0.0, 0.0, NSWidth(rect), NSHeight(rect));
}


@end
