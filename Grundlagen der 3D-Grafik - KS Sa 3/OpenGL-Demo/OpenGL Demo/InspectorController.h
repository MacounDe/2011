//
//  InspectorController.h
//  OpenGL Demo
//
//  Created by Daniel Dönigus on 15.08.11.
//  Copyright 2011 PRODEVCON. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface InspectorController : NSWindowController <NSToolbarDelegate> {
    NSToolbar* toolbar;
    NSTabView* tabView;
    
    NSNumber* translateX;
    NSNumber* translateY;
    NSNumber* translateZ;
    
    NSNumber* scaleX;
    NSNumber* scaleY;
    NSNumber* scaleZ;
    
    NSNumber* rotation;
}

@property (strong) IBOutlet NSNumber* translateX;
@property (strong) IBOutlet NSNumber* translateY;
@property (strong) IBOutlet NSNumber* translateZ;

@property (strong) IBOutlet NSNumber* scaleX;
@property (strong) IBOutlet NSNumber* scaleY;
@property (strong) IBOutlet NSNumber* scaleZ;

@property (strong) IBOutlet NSNumber* rotation;

@property (strong) IBOutlet NSTabView* tabView;

@property (strong) IBOutlet NSToolbar* toolbar;

- (IBAction)showInspector:(id)pId;

- (IBAction)addTranslation:(id)pId;
- (IBAction)addScale:(id)pId;
- (IBAction)addRotation:(id)pId;
- (IBAction)pop:(id)pId;
- (IBAction)push:(id)pId;
- (IBAction)setAspectToWindow:(id)pId;
- (IBAction)lightingBluePlastic:(id)pId;
- (IBAction)lightingRedMatte:(id)pId;
- (IBAction)lightingInteraction:(id)pId;
- (IBAction)lightingNoReflection:(id)pId;
- (IBAction)lightingStandard:(id)pId;

@end
