//
//  HIDDevice.h
//  HID5
//
//  Created by Matthias Krauß on 17.08.11.
//  Copyright 2011 Matthias Krauß. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOKit/hid/IOHIDLib.h>

@interface HIDDevice : NSObject {
	IOHIDDeviceRef deviceRef;
	NSString* name;
	NSMutableData* reportBufferData;
	
	float gyro1;
	float gyro2;
	float gyro3;
	float gyro4;
	float button1;
	float button2;
	float button3;
	float button4;
	float button5;
	float button6;
	float button7;
	float button8;
}

@property (readonly, retain) __attribute__((NSObject)) IOHIDDeviceRef deviceRef;
@property (readonly, retain) NSString* name;

@property (readonly, assign) float gyro1;
@property (readonly, assign) float gyro2;
@property (readonly, assign) float gyro3;
@property (readonly, assign) float gyro4;
@property (readonly, assign) float button1;
@property (readonly, assign) float button2;
@property (readonly, assign) float button3;
@property (readonly, assign) float button4;
@property (readonly, assign) float button5;
@property (readonly, assign) float button6;
@property (readonly, assign) float button7;
@property (readonly, assign) float button8;

+ (HIDDevice*) deviceWithRef:(IOHIDDeviceRef)ref;

- (id) initWithHIDDeviceRef:(IOHIDDeviceRef)ref;

@end
