//
//  OpenGL_DemoAppDelegate.m
//  OpenGL Demo
//
//  Created by Daniel Dönigus on 05.08.11.
//  Copyright 2011 PRODEVCON. All rights reserved.
//

#import "OpenGL_DemoAppDelegate.h"
#import "InspectorController.h"

@implementation OpenGL_DemoAppDelegate

@synthesize window = _window;
@synthesize openGLDemoView;
@synthesize inspectorController;

@synthesize modelType;
@synthesize fillingType;

@synthesize texture;

@synthesize materialAmbient;
@synthesize materialDiffuse;
@synthesize materialSpecular;

@synthesize lightAmbient;
@synthesize lightDiffuse;
@synthesize lightSpecular;
@synthesize lightSpecularExponent;

@synthesize cameraType;

@synthesize fovY;
@synthesize aspectRatio;
@synthesize nearZ;
@synthesize farZ;

@synthesize left;
@synthesize right;
@synthesize bottom;
@synthesize top;
@synthesize nearVal;
@synthesize farVal;

@synthesize showZBuffer;

@synthesize transformations;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.modelType = [NSNumber numberWithInt:0];
    self.fillingType = [NSNumber numberWithInt:0];
    
    self.materialAmbient = [NSColor colorWithDeviceRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    self.materialDiffuse = [NSColor colorWithDeviceRed:0.7 green:0.7 blue:0.7 alpha:1.0];
    self.materialSpecular = [NSColor colorWithDeviceRed:0.5 green:0.5 blue:0.5 alpha:1.0];
    
    self.lightAmbient = [NSColor colorWithDeviceRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    self.lightDiffuse = [NSColor colorWithDeviceRed:0.7 green:0.7 blue:0.7 alpha:1.0];
    self.lightSpecular = [NSColor colorWithDeviceRed:0.5 green:0.5 blue:0.5 alpha:1.0];
    self.lightSpecularExponent = [NSNumber numberWithInt:5];
    
    transformations = [[NSMutableArray alloc] init];
    
    NSSize aspect = _window.frame.size;
    
    self.cameraType = [NSNumber numberWithInt:0];
    
    self.top = [NSNumber numberWithFloat:1.0];
    self.left = [NSNumber numberWithFloat:-1.0];
    self.bottom = [NSNumber numberWithFloat:-1.0];
    self.right = [NSNumber numberWithFloat:1.0];
    self.nearVal = [NSNumber numberWithFloat:0.1];
    self.farVal = [NSNumber numberWithFloat:15];
    
    self.aspectRatio = [NSNumber numberWithFloat:aspect.height/aspect.width];
    self.nearZ = [NSNumber numberWithFloat:0.1];
    self.farZ = [NSNumber numberWithFloat:15];
    self.fovY = [NSNumber numberWithFloat:55];

    inspectorController.translateX = [NSNumber numberWithFloat:0.0];
    inspectorController.translateY = [NSNumber numberWithFloat:0.0];
    inspectorController.translateZ = [NSNumber numberWithFloat:0.0];
    
    inspectorController.scaleX = [NSNumber numberWithFloat:1.0];
    inspectorController.scaleY = [NSNumber numberWithFloat:1.0];
    inspectorController.scaleZ = [NSNumber numberWithFloat:1.0];
    
    inspectorController.rotation = [NSNumber numberWithFloat:0.0];
    
    self.texture = @"None";

    [[inspectorController toolbar ] setSelectedItemIdentifier:@"Primitives"];
}

- (IBAction)showInspector:(id)pId { 
    [self setModelType:[NSNumber numberWithInt:2]];
    [inspectorController showWindow:self]; 
}

@end
