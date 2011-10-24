//
//  HID2AppDelegate.m
//  HID2
//
//  Created by Matthias Krauß on 16.08.11.
//  Copyright 2011 Matthias Krauß. All rights reserved.
//

#import "HID2AppDelegate.h"
#import "HIDCollection.h"

@interface HID2AppDelegate ()

@property (readwrite, retain) HIDCollection* hidCollection;

@end

@implementation HID2AppDelegate

@synthesize hidCollection;

- (void)applicationDidFinishLaunching:(NSNotification*)notification {
	self.hidCollection = [HIDCollection hidCollection];
}

- (void)applicationWillTerminate:(NSNotification*)notification {
	self.hidCollection = nil;
}

@end
