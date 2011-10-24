//
//  MyGyroView.h
//  HID5
//
//  Created by Matthias Krauß on 29.09.11.
//  Copyright 2011 Matthias Krauß. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class HIDDevice;

@interface MyGyroView : NSView {

	HIDDevice* device;
}

@end
