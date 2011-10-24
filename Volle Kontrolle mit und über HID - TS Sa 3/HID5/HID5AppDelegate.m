//
//  HID5AppDelegate.m
//  HID5
//
//  Created by Matthias Krauß on 18.08.11.
//  Copyright 2011 Matthias Krauß. All rights reserved.
//

#import "HID5AppDelegate.h"
#import "HIDCollection.h"

@interface HID5AppDelegate ()

@property (readwrite, retain) HIDCollection* hidCollection;

@end

@implementation HID5AppDelegate

@synthesize hidCollection;

- (void)applicationDidFinishLaunching:(NSNotification*)notification {
	self.hidCollection = [HIDCollection hidCollection];
}

- (void)applicationWillTerminate:(NSNotification*)notification {
	self.hidCollection = nil;
}

@end
