//
//  HIDDevice.h
//  HID3
//
//  Created by Matthias Krauß on 17.08.11.
//  Copyright 2011 Matthias Krauß. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOKit/hid/IOHIDLib.h>

@interface HIDDevice : NSObject {
	IOHIDDeviceRef deviceRef;
	NSString* name;
	IOHIDElementRef axisX1;
	IOHIDElementRef axisY1;
	IOHIDElementRef axisX2;
	IOHIDElementRef axisY2;
	IOHIDElementRef btn1;
	IOHIDElementRef btn2;
	IOHIDElementRef btn3;
	IOHIDElementRef btn4;

	NSPoint joystick1;
	NSPoint joystick2;
	BOOL button1;
	BOOL button2;
	BOOL button3;
	BOOL button4;
}

@property (readonly, retain) __attribute__((NSObject)) IOHIDDeviceRef deviceRef;
@property (readonly, retain) NSString* name;

@property (readonly, assign) NSPoint joystick1;
@property (readonly, assign) NSPoint joystick2;
@property (readonly, assign) BOOL button1;
@property (readonly, assign) BOOL button2;
@property (readonly, assign) BOOL button3;
@property (readonly, assign) BOOL button4;

+ (HIDDevice*) deviceWithRef:(IOHIDDeviceRef)ref;

- (id) initWithHIDDeviceRef:(IOHIDDeviceRef)ref;

@end
