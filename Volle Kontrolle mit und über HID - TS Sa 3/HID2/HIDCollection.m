//
//  HIDCollection.m
//  HID2
//
//  Created by Matthias Krauß on 16.08.11.
//  Copyright 2011 Matthias Krauß. All rights reserved.
//

#import "HIDCollection.h"
#import "HIDDevice.h"



@interface HIDCollection ()

@property (readwrite, retain) __attribute__((NSObject)) IOHIDManagerRef hidManager;
@property (readwrite, retain) NSArray* pluggedDevices;

- (void) startListening;
- (void) stopListening;
- (void) devicePlugged:(IOHIDDeviceRef)device;
- (void) deviceUnplugged:(IOHIDDeviceRef)device;

@end

void myPlugCallback(void* context, IOReturn result, void* sender, IOHIDDeviceRef device) {
	HIDCollection* collection = (HIDCollection*)context;
	[collection devicePlugged:device];
}

void myUnplugCallback(void* context, IOReturn result, void* sender, IOHIDDeviceRef device) {
	HIDCollection* collection = (HIDCollection*)context;
	[collection deviceUnplugged:device];
}

@implementation HIDCollection

@synthesize hidManager;
@synthesize pluggedDevices;

+ (HIDCollection*) hidCollection {
	return [[[HIDCollection alloc] init] autorelease];
}

- (id) init {
	self = [super init];
	if (!self) return nil;
	self.hidManager = IOHIDManagerCreate(kCFAllocatorDefault, 0);
	CFRelease(self.hidManager);
	IOHIDManagerOpen(self.hidManager, 0);
	self.pluggedDevices = [NSArray array];
	[self startListening];
	return self;
}

- (void) dealloc {
	[self stopListening];
	IOHIDManagerClose(self.hidManager, 0);
	self.hidManager = NULL;
	[super dealloc];
}

- (void) startListening {
	NSDictionary* matchDict = [NSDictionary dictionaryWithObjectsAndKeys:
							   [NSNumber numberWithInt:kHIDPage_GenericDesktop], @ kIOHIDDeviceUsagePageKey,
							   [NSNumber numberWithInt:kHIDUsage_GD_Joystick], @ kIOHIDDeviceUsageKey,
							   nil];
	
	IOHIDManagerSetDeviceMatching(self.hidManager, (CFDictionaryRef)matchDict);
	IOHIDManagerRegisterDeviceMatchingCallback(self.hidManager, myPlugCallback, self);
	IOHIDManagerRegisterDeviceRemovalCallback(self.hidManager, myUnplugCallback, self);
	IOHIDManagerScheduleWithRunLoop(self.hidManager, CFRunLoopGetMain(), kCFRunLoopDefaultMode);
}

- (void) stopListening {
	IOHIDManagerUnscheduleFromRunLoop(self.hidManager, CFRunLoopGetMain(), kCFRunLoopDefaultMode);
}

- (void) devicePlugged:(IOHIDDeviceRef)ref {
	HIDDevice* device = [HIDDevice deviceWithRef:ref];
	if (device) {
		self.pluggedDevices = [self.pluggedDevices arrayByAddingObject:device];
		NSLog(@"device plugged: %@", device);
	}
}

- (void) deviceUnplugged:(IOHIDDeviceRef)ref {
	NSMutableArray* remaining = [NSMutableArray array];
	for (HIDDevice* device in self.pluggedDevices) {
		if (device.deviceRef != ref) [remaining addObject:device];
		else NSLog(@"device unplugged: %@",device);
	}	
	self.pluggedDevices = remaining;
}

@end
