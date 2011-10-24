//
//  HIDDevice.m
//  HID3
//
//  Created by Matthias Krauß on 17.08.11.
//  Copyright 2011 Matthias Krauß. All rights reserved.
//

#import "HIDDevice.h"

@interface HIDDevice ()

@property (readwrite, retain) NSString* name;

@property (readwrite, retain) __attribute__((NSObject)) IOHIDDeviceRef deviceRef;
@property (readwrite, retain) __attribute__((NSObject)) IOHIDElementRef axisX1;
@property (readwrite, retain) __attribute__((NSObject)) IOHIDElementRef axisY1;
@property (readwrite, retain) __attribute__((NSObject)) IOHIDElementRef axisX2;
@property (readwrite, retain) __attribute__((NSObject)) IOHIDElementRef axisY2;
@property (readwrite, retain) __attribute__((NSObject)) IOHIDElementRef btn1;
@property (readwrite, retain) __attribute__((NSObject)) IOHIDElementRef btn2;
@property (readwrite, retain) __attribute__((NSObject)) IOHIDElementRef btn3;
@property (readwrite, retain) __attribute__((NSObject)) IOHIDElementRef btn4;

@property (readwrite, assign) NSPoint joystick1;
@property (readwrite, assign) NSPoint joystick2;
@property (readwrite, assign) BOOL button1;
@property (readwrite, assign) BOOL button2;
@property (readwrite, assign) BOOL button3;
@property (readwrite, assign) BOOL button4;

- (BOOL) findElements;
- (IOHIDElementRef) findElementWithType:(IOHIDElementType)type
							  usagePage:(uint32_t)usagePage
								  usage:(uint32_t)usage;
- (void) startListening;
- (void) stopListening;
- (void) valueCallback:(IOHIDValueRef)value;

//----------------------------------------
- (void) dumpElements;
- (void) dumpElement:(IOHIDElementRef)element;

@end

void myValueCallback(void* context, IOReturn result, void* sender, IOHIDValueRef value) {
	if (result) return;
	HIDDevice* device = (HIDDevice*)context;
	[device valueCallback:value];
}

@implementation HIDDevice

@synthesize deviceRef;
@synthesize name;
@synthesize axisX1;
@synthesize axisY1;
@synthesize axisX2;
@synthesize axisY2;
@synthesize btn1;
@synthesize btn2;
@synthesize btn3;
@synthesize btn4;

@synthesize joystick1;
@synthesize joystick2;
@synthesize button1;
@synthesize button2;
@synthesize button3;
@synthesize button4;

+ (HIDDevice*) deviceWithRef:(IOHIDDeviceRef)ref {
	return [[[HIDDevice alloc] initWithHIDDeviceRef:ref] autorelease];
}

- (id) initWithHIDDeviceRef:(IOHIDDeviceRef)ref {
	self = [super init];
	if (!self) return nil;
	self.deviceRef = ref;
	self.name = (NSString*)IOHIDDeviceGetProperty(self.deviceRef, CFSTR(kIOHIDProductKey));
	
	BOOL ok = [self findElements];
	if (!ok) {
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
	[super dealloc];
}

- (NSString*) description {
	return [NSString stringWithFormat:@"Device %@",self.name];
}

- (BOOL) findElements {
	self.axisX1 = [self findElementWithType:kIOHIDElementTypeInput_Misc
								  usagePage:kHIDPage_GenericDesktop
									  usage:kHIDUsage_GD_X];
	self.axisY1 = [self findElementWithType:kIOHIDElementTypeInput_Misc
								  usagePage:kHIDPage_GenericDesktop
									  usage:kHIDUsage_GD_Y];
	self.axisX2 = [self findElementWithType:kIOHIDElementTypeInput_Misc
								  usagePage:kHIDPage_GenericDesktop
									  usage:kHIDUsage_GD_Z];
	self.axisY2 = [self findElementWithType:kIOHIDElementTypeInput_Misc
								  usagePage:kHIDPage_GenericDesktop
									  usage:kHIDUsage_GD_Rz];
	self.btn1 = [self findElementWithType:kIOHIDElementTypeInput_Button
								   usagePage:kHIDPage_Button
									   usage:1];
	self.btn2 = [self findElementWithType:kIOHIDElementTypeInput_Button
								   usagePage:kHIDPage_Button
									   usage:2];
	self.btn3 = [self findElementWithType:kIOHIDElementTypeInput_Button
								   usagePage:kHIDPage_Button
									   usage:3];
	self.btn4 = [self findElementWithType:kIOHIDElementTypeInput_Button
								   usagePage:kHIDPage_Button
									   usage:4];
	return (self.axisX1 && self.axisY1 && self.axisY1 && self.axisY2 &&
			self.btn1 && self.btn2 && self.btn3 && self.btn4) ? YES : NO;
}

- (IOHIDElementRef) findElementWithType:(IOHIDElementType)type
							  usagePage:(uint32_t)usagePage
								  usage:(uint32_t)usage {
	NSDictionary* matchDict = [NSDictionary dictionaryWithObjectsAndKeys:
							   [NSNumber numberWithInt:type],@ kIOHIDElementTypeKey,
							   [NSNumber numberWithInt:usagePage],@ kIOHIDElementUsagePageKey,
							   [NSNumber numberWithInt:usage],@ kIOHIDElementUsageKey,
							   nil];
	CFArrayRef elements = IOHIDDeviceCopyMatchingElements(self.deviceRef, (CFDictionaryRef)matchDict, 0);
	if (!elements) return NULL;
	if (CFArrayGetCount(elements) < 0) return NULL;
	IOHIDElementRef element = (IOHIDElementRef)CFArrayGetValueAtIndex(elements, 0);
	CFRelease(elements);
	return element;
}

- (void) valueCallback:(IOHIDValueRef)value {
	IOHIDElementRef element = IOHIDValueGetElement(value);
	int unscaled = IOHIDValueGetIntegerValue(value);
	int min = IOHIDElementGetLogicalMin(element);
	int max = IOHIDElementGetLogicalMax(element);
	double scaled = ((double)unscaled-(double)min)/((double)max-(double)min)*2.0-1.0;
	
	if (element==self.axisX1) self.joystick1 = NSMakePoint(scaled, self.joystick1.y);
	if (element==self.axisY1) self.joystick1 = NSMakePoint(self.joystick1.x, scaled);
	if (element==self.axisX2) self.joystick2 = NSMakePoint(scaled, self.joystick2.y);
	if (element==self.axisY2) self.joystick2 = NSMakePoint(self.joystick2.x, scaled);
	if (element==self.btn1) self.button1 = unscaled;
	if (element==self.btn2) self.button2 = unscaled;
	if (element==self.btn3) self.button3 = unscaled;
	if (element==self.btn4) self.button4 = unscaled;
}

- (void) startListening {
	IOReturn err = IOHIDDeviceOpen(self.deviceRef, 0);
	NSAssert(!err,@"IOHIDDeviceOpen failed");
	NSArray* matchArray = [NSArray arrayWithObjects:
						   [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:(unsigned int)IOHIDElementGetCookie(self.axisX1)]
													   forKey:@ kIOHIDElementCookieKey],
						   [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:(unsigned int)IOHIDElementGetCookie(self.axisX2)]
													   forKey:@ kIOHIDElementCookieKey],
						   [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:(unsigned int)IOHIDElementGetCookie(self.axisY1)]
													   forKey:@ kIOHIDElementCookieKey],
						   [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:(unsigned int)IOHIDElementGetCookie(self.axisY2)]
													   forKey:@ kIOHIDElementCookieKey],
						   [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:(unsigned int)IOHIDElementGetCookie(self.btn1)]
													   forKey:@ kIOHIDElementCookieKey],
						   [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:(unsigned int)IOHIDElementGetCookie(self.btn2)]
													   forKey:@ kIOHIDElementCookieKey],
						   [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:(unsigned int)IOHIDElementGetCookie(self.btn3)]
													   forKey:@ kIOHIDElementCookieKey],
						   [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:(unsigned int)IOHIDElementGetCookie(self.btn4)]
													   forKey:@ kIOHIDElementCookieKey],
						   nil];
	IOHIDDeviceSetInputValueMatchingMultiple(self.deviceRef, (CFArrayRef)matchArray);
	IOHIDDeviceRegisterInputValueCallback(self.deviceRef, myValueCallback, self);
}

- (void) stopListening {
	IOHIDDeviceClose(self.deviceRef, 0);
}





//----------------------------------------------------


- (void) dumpElements {
	NSDictionary* matchDict = [NSDictionary dictionary];
	CFArrayRef elements = IOHIDDeviceCopyMatchingElements(self.deviceRef, (CFDictionaryRef)matchDict, 0);
	for (id element in (NSArray*)elements) {
		[self dumpElement:(IOHIDElementRef)element];
	}
	CFRelease(elements);
}

- (void) dumpElement:(IOHIDElementRef) element {
	IOHIDElementType type = IOHIDElementGetType(element);
	uint32_t usagePage = IOHIDElementGetUsagePage(element);
	uint32_t usage = IOHIDElementGetUsage(element);
	CFIndex min = IOHIDElementGetLogicalMin(element);
	CFIndex max = IOHIDElementGetLogicalMax(element);
	uint32_t reportId = IOHIDElementGetReportID(element);
	uint32_t reportSize = IOHIDElementGetReportSize(element);
	uint32_t reportCount = IOHIDElementGetReportCount(element);
	NSString* relative = (IOHIDElementIsRelative(element))? @"Relative" : @"Absolute";
	NSString* wrapping = (IOHIDElementIsWrapping(element))? @"Wrapping" : @"Not wrapping";
	NSString* nullstate = (IOHIDElementHasNullState(element))? @"Has Null state" : @"No Null state";
	NSString* prefstate = (IOHIDElementHasPreferredState(element))? @"Has preferred state" : @"No preferred state";
	
	switch (type) {
		case kIOHIDElementTypeInput_Misc: NSLog(@"Element type: Input"); break;
		case kIOHIDElementTypeInput_Button: NSLog(@"Element type: Button"); break;
		case kIOHIDElementTypeInput_Axis: NSLog(@"Element type: Axis"); break;
		case kIOHIDElementTypeInput_ScanCodes: NSLog(@"Element type: Scan Codes"); break;
		case kIOHIDElementTypeOutput: NSLog(@"Element type: Output"); break;
		case kIOHIDElementTypeFeature: NSLog(@"Element type: Feature"); break;
		case kIOHIDElementTypeCollection: NSLog(@"Element type: Collection"); break;
		default: NSLog(@"Element type unknown!");
	}
	NSLog(@"Usage page: 0x%04x usage: 0x%04x", usagePage, usage);
	NSLog(@"Logical min: %i max: %i", (int)min, (int)max);
	NSLog(@"Report ID: %i size: %i count: %i",reportId, reportSize, reportCount);
	NSLog(@"Properties: %@ | %@ | %@ | %@",relative, wrapping, nullstate, prefstate);
}


@end
