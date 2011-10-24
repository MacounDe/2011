//
//  HIDDevice.m
//  HID5
//
//  Created by Matthias Krauß on 17.08.11.
//  Copyright 2011 Matthias Krauß. All rights reserved.
//

#import "HIDDevice.h"

@interface HIDDevice ()

@property (readwrite, retain) __attribute__((NSObject)) IOHIDDeviceRef deviceRef;
@property (readwrite, retain) NSString* name;
@property (readwrite, retain) NSMutableData* reportBufferData;

@property (readwrite, assign) float gyro1;
@property (readwrite, assign) float gyro2;
@property (readwrite, assign) float gyro3;
@property (readwrite, assign) float gyro4;
@property (readwrite, assign) float button1;
@property (readwrite, assign) float button2;
@property (readwrite, assign) float button3;
@property (readwrite, assign) float button4;
@property (readwrite, assign) float button5;
@property (readwrite, assign) float button6;
@property (readwrite, assign) float button7;
@property (readwrite, assign) float button8;

- (void) startListening;
- (void) stopListening;
- (void) reportCallback:(uint8_t*)report;

@end

void myReportCallback (void* context, IOReturn result, void* sender,  IOHIDReportType type, 
					   uint32_t reportID, uint8_t* report, CFIndex reportLength) {
	if ((type == kIOHIDReportTypeInput) && (reportID == 1) && (reportLength == 49)) {
		[(HIDDevice*)context reportCallback:report];
	}
}

@implementation HIDDevice


@synthesize deviceRef;
@synthesize name;
@synthesize reportBufferData;

@synthesize gyro1;
@synthesize gyro2;
@synthesize gyro3;
@synthesize gyro4;
@synthesize button1;
@synthesize button2;
@synthesize button3;
@synthesize button4;
@synthesize button5;
@synthesize button6;
@synthesize button7;
@synthesize button8;

+ (HIDDevice*) deviceWithRef:(IOHIDDeviceRef)ref {
	return [[[HIDDevice alloc] initWithHIDDeviceRef:ref] autorelease];
}

- (id) initWithHIDDeviceRef:(IOHIDDeviceRef)ref {
	self = [super init];
	if (!self) return nil;
	self.deviceRef = ref;
	self.reportBufferData = [NSMutableData dataWithLength:1024];
	self.name = (NSString*)IOHIDDeviceGetProperty(self.deviceRef, CFSTR(kIOHIDProductKey));
	if (![self.name isEqualToString:@"PLAYSTATION(R)3 Controller"]) {
		[self release];
		return nil;
	}
	[self startListening];
	return self;
}

- (void) dealloc {
	[self stopListening];
	self.name = nil;
	self.deviceRef = NULL;
	self.reportBufferData = nil;
	[super dealloc];
}

- (NSString*) description {
	return [NSString stringWithFormat:@"Device %@",self.name];
}

- (void) reportCallback:(uint8_t*)report {
	self.gyro1 = (report[41] * 256 + report[42]) / 1023.0;
	self.gyro2 = (report[43] * 256 + report[44]) / 1023.0;
	self.gyro3 = (report[45] * 256 + report[46]) / 1023.0;
	self.gyro4 = (report[47] * 256 + report[48]) / 1023.0;
	self.button1 = report[24] / 255.0;
	self.button2 = report[23] / 255.0;
	self.button3 = report[22] / 255.0;
	self.button4 = report[25] / 255.0;
	self.button5 = report[21] / 255.0;
	self.button6 = report[20] / 255.0;
	self.button7 = report[19] / 255.0;
	self.button8 = report[18] / 255.0;
	for (int i=0;i<49;i++) printf("%i->%02x ",i,report[i]);
	printf("\n");
}	

- (void) startListening {
	IOReturn err = IOHIDDeviceOpen(self.deviceRef, 0);
	NSAssert(!err,@"Could not open device");
	IOHIDDeviceRegisterInputReportCallback(self.deviceRef, [self.reportBufferData mutableBytes],
										   [self.reportBufferData length], myReportCallback, self);
}

- (void) stopListening {
	IOHIDDeviceClose(self.deviceRef, 0);
}




@end
