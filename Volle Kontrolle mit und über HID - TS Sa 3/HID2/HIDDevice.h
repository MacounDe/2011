//
//  HIDDevice.h
//  HID2
//
//  Created by Matthias Krauß on 17.08.11.
//  Copyright 2011 Matthias Krauß. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOKit/hid/IOHIDLib.h>

@interface HIDDevice : NSObject {
	IOHIDDeviceRef deviceRef;
	NSString* name;
}

@property (readonly, retain) __attribute__((NSObject)) IOHIDDeviceRef deviceRef;
@property (readonly, retain) NSString* name;

+ (HIDDevice*) deviceWithRef:(IOHIDDeviceRef)ref;

- (id) initWithHIDDeviceRef:(IOHIDDeviceRef)ref;

@end
