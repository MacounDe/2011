//
//  HID5AppDelegate.h
//  HID5
//
//  Created by Matthias Krauß on 18.08.11.
//  Copyright 2011 Matthias Krauß. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class HIDCollection;

@interface HID5AppDelegate : NSObject <NSApplicationDelegate> {

	HIDCollection* hidCollection;

}

@property (readonly, retain) HIDCollection* hidCollection;

@end
