//
//  HID4AppDelegate.m
//  HID4
//
//  Created by Matthias Krauß on 18.08.11.
//  Copyright 2011 Matthias Krauß. All rights reserved.
//

#import "HID4AppDelegate.h"
#import "MyOpenGLView.h"
#import "HIDCollection.h"

@interface HID4AppDelegate ()

@property (readwrite, retain) HIDCollection* hidCollection;

@end

@implementation HID4AppDelegate

@synthesize window;
@synthesize view;
@synthesize hidCollection;

- (void)awakeFromNib {
	self.hidCollection = [HIDCollection hidCollection];
}

- (void)applicationWillTerminate:(NSNotification*)notification {
	self.hidCollection = nil;
}

@end
