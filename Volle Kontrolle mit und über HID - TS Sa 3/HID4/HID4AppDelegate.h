//
//  HID4AppDelegate.h
//  HID4
//
//  Created by Matthias Krauß on 18.08.11.
//  Copyright 2011 Matthias Krauß. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HIDCollection.h"

@class MyOpenGLView, HIDCollection;

@interface HID4AppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	MyOpenGLView* view;
	HIDCollection* hidCollection;
}

@property (assign) IBOutlet NSWindow* window;
@property (assign) IBOutlet MyOpenGLView* view;

@end
