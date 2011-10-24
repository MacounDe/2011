//
//  HID3AppDelegate.m
//  HID3
//
//  Created by Matthias Krauß on 18.08.11.
//  Copyright 2011 Matthias Krauß. All rights reserved.
//

#import "HID3AppDelegate.h"
#import "HIDCollection.h"

@interface HID3AppDelegate ()

@property (readwrite, retain) HIDCollection* hidCollection;

@end

@implementation HID3AppDelegate

@synthesize hidCollection;

- (void)applicationDidFinishLaunching:(NSNotification*)notification {
	self.hidCollection = [HIDCollection hidCollection];
}

- (void)applicationWillTerminate:(NSNotification*)notification {
	self.hidCollection = nil;
}

@end
