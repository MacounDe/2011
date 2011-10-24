//
//  InspectorController.m
//  OpenGL Demo
//
//  Created by Daniel Dönigus on 15.08.11.
//  Copyright 2011 PRODEVCON. All rights reserved.
//

#import "InspectorController.h"
#include "OpenGL_DemoAppDelegate.h"
#include "Transformation.h"

@implementation InspectorController

@synthesize tabView;
@synthesize toolbar;

@synthesize translateX;
@synthesize translateY;
@synthesize translateZ;

@synthesize scaleX;
@synthesize scaleY;
@synthesize scaleZ;

@synthesize rotation;

- (void)windowDidLoad
{
    [super windowDidLoad];
}

- (IBAction)setAspectToWindow:(id)pId {
    OpenGL_DemoAppDelegate* delegate = [[NSApplication sharedApplication] delegate];
    
    NSWindow* window = [delegate window];
    NSSize size = window.frame.size;
    
    [delegate setAspectRatio:[NSNumber numberWithFloat:size.width/size.height]];
}

- (IBAction)showInspector:(id)pId {
    if ([pId class] == [NSToolbarItem class]) {
        [tabView selectTabViewItemAtIndex:[pId tag]];
        
        NSImage* image = [pId image];
        image = nil;
        [[self window] setTitle:[pId label]]; 
    }
}

- (IBAction)addTranslation:(id)pId {
    OpenGL_DemoAppDelegate* delegate = [[NSApplication sharedApplication] delegate];
    NSMutableArray* transformations = [delegate transformations];
    
    [transformations addObject:[[Transformation alloc] initAsTranslationWithX:[translateX floatValue] Y:[translateY floatValue] andZ:[translateZ floatValue]]];

    delegate.openGLDemoView.needsDisplay = YES;
}

- (IBAction)addScale:(id)pId {
    OpenGL_DemoAppDelegate* delegate = [[NSApplication sharedApplication] delegate];
    NSMutableArray* transformations = [delegate transformations];
    
    [transformations addObject:[[Transformation alloc] initAsScaleWithX:[scaleX floatValue] Y:[scaleY floatValue] andZ:[scaleZ floatValue]]];
    
    delegate.openGLDemoView.needsDisplay = YES;
}

- (IBAction)addRotation:(id)pId {
    OpenGL_DemoAppDelegate* delegate = [[NSApplication sharedApplication] delegate];
    NSMutableArray* transformations = [delegate transformations];
    
    switch ([pId selectedSegment]) {
        case 0: [transformations addObject:[[Transformation alloc] initAsRotationWithRotation:[rotation floatValue] aroundAxis:AXIS_X]]; break;
        case 1: [transformations addObject:[[Transformation alloc] initAsRotationWithRotation:[rotation floatValue] aroundAxis:AXIS_Y]]; break;
        case 2: [transformations addObject:[[Transformation alloc] initAsRotationWithRotation:[rotation floatValue] aroundAxis:AXIS_Z]]; break;
    }
    
    
    
    delegate.openGLDemoView.needsDisplay = YES;
}

- (IBAction)pop:(id)pId {
    OpenGL_DemoAppDelegate* delegate = [[NSApplication sharedApplication] delegate];
    NSMutableArray* transformations = [delegate transformations];

    int lastPop = -1;
    int currentIndex = 0;
    
    for (id trans in transformations) {
        if ([trans transformationType] == TRANSFORMATION_POP) {
            lastPop = currentIndex;
        }
        currentIndex++;
    }
    
    if (lastPop == -1) {
        [transformations removeAllObjects];
    } else {
        while ([transformations count] >= lastPop+1) {
            [transformations removeLastObject];
        }
    }
    
    delegate.openGLDemoView.needsDisplay = YES;
}

- (IBAction)push:(id)pId {
    OpenGL_DemoAppDelegate* delegate = [[NSApplication sharedApplication] delegate];
    NSMutableArray* transformations = [delegate transformations];
    
    [transformations addObject:[[Transformation alloc] initAsPop]];
    
    delegate.openGLDemoView.needsDisplay = YES;
}

- (IBAction)lightingBluePlastic:(id)pId {
    OpenGL_DemoAppDelegate* delegate = [[NSApplication sharedApplication] delegate];

    delegate.materialAmbient = [NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.5 alpha:1.0];
    delegate.materialDiffuse = [NSColor colorWithDeviceRed:0.4 green:0.4 blue:1.0 alpha:1.0];
    delegate.materialSpecular = [NSColor colorWithDeviceRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    
    delegate.lightAmbient = [NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.5 alpha:1.0];
    delegate.lightDiffuse = [NSColor colorWithDeviceRed:0.4 green:0.4 blue:1.0 alpha:1.0];
    delegate.lightSpecular = [NSColor colorWithDeviceRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    delegate.lightSpecularExponent = [NSNumber numberWithInt:40];
}

- (IBAction)lightingRedMatte:(id)pId {
    OpenGL_DemoAppDelegate* delegate = [[NSApplication sharedApplication] delegate];
    
    delegate.materialAmbient = [NSColor colorWithDeviceRed:0.5 green:0.0 blue:0.0 alpha:1.0];
    delegate.materialDiffuse = [NSColor colorWithDeviceRed:1.0 green:0.2 blue:0.2 alpha:1.0];
    delegate.materialSpecular = [NSColor colorWithDeviceRed:1.0 green:0.5 blue:0.5 alpha:1.0];
    
    delegate.lightAmbient = [NSColor colorWithDeviceRed:0.5 green:0.0 blue:0.0 alpha:1.0];
    delegate.lightDiffuse = [NSColor colorWithDeviceRed:1.0 green:0.2 blue:0.2 alpha:1.0];
    delegate.lightSpecular = [NSColor colorWithDeviceRed:1.0 green:0.5 blue:0.5 alpha:1.0];
    delegate.lightSpecularExponent = [NSNumber numberWithInt:5];
}

- (IBAction)lightingInteraction:(id)pId {
    OpenGL_DemoAppDelegate* delegate = [[NSApplication sharedApplication] delegate];
    
    delegate.materialAmbient = [NSColor colorWithDeviceRed:0.5 green:0.0 blue:0.0 alpha:1.0];
    delegate.materialDiffuse = [NSColor colorWithDeviceRed:1.0 green:0.2 blue:0.2 alpha:1.0];
    delegate.materialSpecular = [NSColor colorWithDeviceRed:1.0 green:0.5 blue:0.5 alpha:1.0];
    
    delegate.lightAmbient = [NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.5 alpha:1.0];
    delegate.lightDiffuse = [NSColor colorWithDeviceRed:0.4 green:0.4 blue:1.0 alpha:1.0];
    delegate.lightSpecular = [NSColor colorWithDeviceRed:1.0 green:1.0 blue:1.0 alpha:1.0];
}

- (IBAction)lightingNoReflection:(id)pId {
    OpenGL_DemoAppDelegate* delegate = [[NSApplication sharedApplication] delegate];
    
    delegate.materialAmbient = [NSColor colorWithDeviceRed:0.5 green:0.0 blue:0.0 alpha:1.0];
    delegate.materialDiffuse = [NSColor colorWithDeviceRed:1.0 green:0.2 blue:0.0 alpha:1.0];
    delegate.materialSpecular = [NSColor colorWithDeviceRed:1.0 green:0.5 blue:0.0 alpha:1.0];
    
    delegate.lightAmbient = [NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.5 alpha:1.0];
    delegate.lightDiffuse = [NSColor colorWithDeviceRed:0.0 green:0.0 blue:1.0 alpha:1.0];
    delegate.lightSpecular = [NSColor colorWithDeviceRed:0.0 green:0.0 blue:1.0 alpha:1.0];
}

- (IBAction)lightingStandard:(id)pId {
    OpenGL_DemoAppDelegate* delegate = [[NSApplication sharedApplication] delegate];
    
    delegate.materialAmbient = [NSColor colorWithDeviceRed:0.4 green:0.4 blue:0.4 alpha:1.0];
    delegate.materialDiffuse = [NSColor colorWithDeviceRed:0.7 green:0.7 blue:0.7 alpha:1.0];
    delegate.materialSpecular = [NSColor colorWithDeviceRed:0.5 green:0.5 blue:0.5 alpha:1.0];
    
    delegate.lightAmbient = [NSColor colorWithDeviceRed:0.4 green:0.4 blue:0.4 alpha:1.0];
    delegate.lightDiffuse = [NSColor colorWithDeviceRed:0.7 green:0.7 blue:0.7 alpha:1.0];
    delegate.lightSpecular = [NSColor colorWithDeviceRed:0.5 green:0.5 blue:0.5 alpha:1.0];
    delegate.lightSpecularExponent = [NSNumber numberWithInt:5];
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolBar {
    return [[toolBar items] valueForKey:@"itemIdentifier"];
}

@end
