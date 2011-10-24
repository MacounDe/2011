//
//  HID2AppDelegate.h
//  HID2
//
//  Created by Matthias Krauß on 16.08.11.
//  Copyright 2011 Matthias Krauß. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class HIDCollection;

@interface HID2AppDelegate : NSObject <NSApplicationDelegate> {

	HIDCollection* hidCollection;
}

@property (readonly, retain) HIDCollection* hidCollection;

@end
