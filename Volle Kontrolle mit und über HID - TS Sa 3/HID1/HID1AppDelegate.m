//
//  HID1AppDelegate.m
//  HID1
//
//  Created by Matthias Krauß on 16.08.11.
//  Copyright 2011 Matthias Krauß. All rights reserved.
//

#import "HID1AppDelegate.h"
#import <IOKit/hid/IOHIDLib.h>

@implementation HID1AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification*)notification {

	IOHIDManagerRef hidManager = IOHIDManagerCreate(kCFAllocatorDefault, 0);
	NSAssert(hidManager, @"IOHIDManagerCreate failed");
	
	IOReturn ioErr = IOHIDManagerOpen(hidManager, 0);
	NSAssert(!ioErr, @"IOHIDManagerOpen failed");

	NSDictionary* matchDict = [NSDictionary dictionary];
	IOHIDManagerSetDeviceMatching(hidManager, (CFDictionaryRef)matchDict);
	
	CFSetRef devices = IOHIDManagerCopyDevices(hidManager);
	
	for (id dev in (NSSet*)devices) {
		IOHIDDeviceRef device = (IOHIDDeviceRef)dev;
		CFTypeRef product = IOHIDDeviceGetProperty(device, CFSTR(kIOHIDProductKey));
		CFTypeRef manufacturer = IOHIDDeviceGetProperty(device, CFSTR(kIOHIDManufacturerKey));
		CFTypeRef transport = IOHIDDeviceGetProperty(device, CFSTR(kIOHIDTransportKey));
		CFTypeRef usagePage = IOHIDDeviceGetProperty(device, CFSTR(kIOHIDPrimaryUsagePageKey));
		CFTypeRef usage = IOHIDDeviceGetProperty(device, CFSTR(kIOHIDPrimaryUsageKey));

		NSLog(@"Found device %@ by %@ on %@ usage %@/%@",product,manufacturer,transport,usagePage,usage);
	}
	
	CFRelease(devices);
	
	IOHIDManagerClose(hidManager, 0);
	CFRelease(hidManager);
}

@end
