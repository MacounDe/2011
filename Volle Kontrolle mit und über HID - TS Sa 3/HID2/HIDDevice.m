//
//  HIDDevice.m
//  HID2
//
//  Created by Matthias Krauß on 17.08.11.
//  Copyright 2011 Matthias Krauß. All rights reserved.
//

#import "HIDDevice.h"

@interface HIDDevice ()

@property (readwrite, retain) __attribute__((NSObject)) IOHIDDeviceRef deviceRef;
@property (readwrite, retain) NSString* name;

@end


@implementation HIDDevice

@synthesize deviceRef;
@synthesize name;

+ (HIDDevice*) deviceWithRef:(IOHIDDeviceRef)ref {
	return [[[HIDDevice alloc] initWithHIDDeviceRef:ref] autorelease];
}

- (id) initWithHIDDeviceRef:(IOHIDDeviceRef)ref {
	self = [super init];
	if (!self) return nil;
	self.deviceRef = ref;
	self.name = (NSString*)IOHIDDeviceGetProperty(self.deviceRef, CFSTR(kIOHIDProductKey));
	return self;
}

- (void) dealloc {
	self.name = nil;
	self.deviceRef = NULL;
	[super dealloc];
}

- (NSString*) description {
	return [NSString stringWithFormat:@"Device %@",self.name];
}

@end
