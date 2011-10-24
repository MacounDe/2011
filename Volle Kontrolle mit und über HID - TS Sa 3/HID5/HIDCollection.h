//
//  HIDCollection.h
//  HID5
//
//  Created by Matthias Krauß on 16.08.11.
//  Copyright 2011 Matthias Krauß. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOKit/hid/IOHIDLib.h>

extern NSString* HIDPluggedNotification;
extern NSString* HIDUnpluggedNotification;

@interface HIDCollection : NSObject {

	IOHIDManagerRef hidManager;
	NSArray* pluggedDevices;
}

@property (readonly, retain) NSArray* pluggedDevices;	//in order of plugging

+ (HIDCollection*) hidCollection;

@end
