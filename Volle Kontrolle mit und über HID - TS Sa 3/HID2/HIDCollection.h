//
//  HIDCollection.h
//  HID2
//
//  Created by Matthias Krauß on 16.08.11.
//  Copyright 2011 Matthias Krauß. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOKit/hid/IOHIDLib.h>

@interface HIDCollection : NSObject {

	IOHIDManagerRef hidManager;
	NSArray* pluggedDevices;
}

@property (readonly, retain) NSArray* pluggedDevices;	//in order of plugging

+ (HIDCollection*) hidCollection;

@end
