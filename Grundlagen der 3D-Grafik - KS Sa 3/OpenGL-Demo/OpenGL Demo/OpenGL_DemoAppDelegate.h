//
//  OpenGL_DemoAppDelegate.h
//  OpenGL Demo
//
//  Created by Daniel Dönigus on 05.08.11.
//  Copyright 2011 PRODEVCON. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class InspectorController;

@interface OpenGL_DemoAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *_window;
    NSOpenGLView* openGLDemoView;
    InspectorController *inspectorController;
    
    NSNumber* fillingType;
    NSNumber* modelType;
    
    NSString* texture;
    
    NSColor* materialAmbient;
    NSColor* materialDiffuse;
    NSColor* materialSpecular;
    NSColor* lightAmbient;
    NSColor* lightDiffuse;
    NSColor* lightSpecular;
    NSNumber* lightSpecularExponent;
    
    NSNumber* cameraType;
    NSNumber* fovY;
    NSNumber* aspectRatio;
    NSNumber* nearZ;
    NSNumber* farZ;
    
    NSNumber* left;
    NSNumber* right;
    NSNumber* bottom;
    NSNumber* top;
    NSNumber* nearVal;
    NSNumber* farVal;
    
    NSNumber* showZBuffer;

    NSMutableArray* transformations;
}

@property (strong) IBOutlet NSOpenGLView* openGLDemoView;
@property (strong) IBOutlet NSWindow *window;
@property (strong) IBOutlet InspectorController *inspectorController;

@property (strong) IBOutlet NSNumber* modelType;
@property (strong) IBOutlet NSNumber* fillingType;
@property (strong) IBOutlet NSString* texture;

@property (strong) IBOutlet NSColor* materialAmbient;
@property (strong) IBOutlet NSColor* materialDiffuse;
@property (strong) IBOutlet NSColor* materialSpecular;
@property (strong) IBOutlet NSColor* lightAmbient;
@property (strong) IBOutlet NSColor* lightDiffuse;
@property (strong) IBOutlet NSColor* lightSpecular;
@property (strong) IBOutlet NSNumber* lightSpecularExponent;

@property (strong) NSMutableArray* transformations;

@property (strong) IBOutlet NSNumber* cameraType;

@property (strong) IBOutlet NSNumber* fovY;
@property (strong) IBOutlet NSNumber* aspectRatio;
@property (strong) IBOutlet NSNumber* nearZ;
@property (strong) IBOutlet NSNumber* farZ;

@property (strong) IBOutlet NSNumber* left;
@property (strong) IBOutlet NSNumber* right;
@property (strong) IBOutlet NSNumber* bottom;
@property (strong) IBOutlet NSNumber* top;
@property (strong) IBOutlet NSNumber* nearVal;
@property (strong) IBOutlet NSNumber* farVal;

@property (strong) IBOutlet NSNumber* showZBuffer;

- (IBAction)showInspector:(id)pId;

@end
