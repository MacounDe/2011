//
//  MyGyroView.m
//  HID5
//
//  Created by Matthias Krauß on 29.09.11.
//  Copyright 2011 Matthias Krauß. All rights reserved.
//

#import "MyGyroView.h"
#import "HIDCollection.h"
#import "HIDDevice.h"

@interface MyGyroView ()

@property (readwrite, retain) HIDDevice* device;

- (void) devicePlugged:(NSNotification*)notification;
- (void) deviceUnplugged:(NSNotification*)notification;

@end

@implementation MyGyroView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
	NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(devicePlugged:)
			   name:HIDPluggedNotification
			 object:nil];
	[nc addObserver:self
		   selector:@selector(deviceUnplugged:)
			   name:HIDUnpluggedNotification
			 object:nil];
	
    return self;
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (void) devicePlugged:(NSNotification*)notification {
	if (!self.device) self.device = [notification object];
}

- (void) deviceUnplugged:(NSNotification*)notification {
	if ([[notification object] isEqual:self.device]) self.device = nil;
}

- (void)drawRect:(NSRect)dirtyRect {
	[[NSColor blackColor] set];
	NSRectFill(dirtyRect);
	NSRect bounds = [self bounds];
	float slotWidth = NSWidth(bounds)/12.0;
	
	NSRect r;

	[[NSColor redColor] set];
	r = NSMakeRect(NSMinX(bounds),NSMinY(bounds),
						  slotWidth, self.device.gyro1 * NSHeight(bounds));
	NSRectFill(r);
	r = NSMakeRect(NSMinX(bounds)+1.0*slotWidth,NSMinY(bounds),
				   slotWidth, self.device.gyro2 * NSHeight(bounds));
	NSRectFill(r);
	r = NSMakeRect(NSMinX(bounds)+2.0*slotWidth,NSMinY(bounds),
				   slotWidth, self.device.gyro3 * NSHeight(bounds));
	NSRectFill(r);
	r = NSMakeRect(NSMinX(bounds)+3.0*slotWidth,NSMinY(bounds),
				   slotWidth, self.device.gyro4 * NSHeight(bounds));
	NSRectFill(r);
	[[NSColor greenColor] set];
	r = NSMakeRect(NSMinX(bounds)+4.0*slotWidth,NSMinY(bounds),
				   slotWidth, self.device.button1 * NSHeight(bounds));
	NSRectFill(r);
	r = NSMakeRect(NSMinX(bounds)+5.0*slotWidth,NSMinY(bounds),
				   slotWidth, self.device.button2 * NSHeight(bounds));
	NSRectFill(r);
	r = NSMakeRect(NSMinX(bounds)+6.0*slotWidth,NSMinY(bounds),
				   slotWidth, self.device.button3 * NSHeight(bounds));
	NSRectFill(r);
	r = NSMakeRect(NSMinX(bounds)+7.0*slotWidth,NSMinY(bounds),
				   slotWidth, self.device.button4 * NSHeight(bounds));
	NSRectFill(r);
	r = NSMakeRect(NSMinX(bounds)+8.0*slotWidth,NSMinY(bounds),
				   slotWidth, self.device.button5 * NSHeight(bounds));
	NSRectFill(r);
	r = NSMakeRect(NSMinX(bounds)+9.0*slotWidth,NSMinY(bounds),
				   slotWidth, self.device.button6 * NSHeight(bounds));
	NSRectFill(r);
	r = NSMakeRect(NSMinX(bounds)+10.0*slotWidth,NSMinY(bounds),
				   slotWidth, self.device.button7 * NSHeight(bounds));
	NSRectFill(r);
	r = NSMakeRect(NSMinX(bounds)+11.0*slotWidth,NSMinY(bounds),
				   slotWidth, self.device.button8 * NSHeight(bounds));
	NSRectFill(r);
}

- (HIDDevice*) device {
	return device;
}

- (void) setDevice:(HIDDevice*)newDevice {
	if (device==newDevice) return;
	HIDDevice* oldDevice = device;
	[oldDevice removeObserver:self forKeyPath:@"gyro1"];
	[oldDevice removeObserver:self forKeyPath:@"gyro2"];
	[oldDevice removeObserver:self forKeyPath:@"gyro3"];
	[oldDevice removeObserver:self forKeyPath:@"gyro4"];
	[oldDevice removeObserver:self forKeyPath:@"button1"];
	[oldDevice removeObserver:self forKeyPath:@"button2"];
	[oldDevice removeObserver:self forKeyPath:@"button3"];
	[oldDevice removeObserver:self forKeyPath:@"button4"];
	[oldDevice removeObserver:self forKeyPath:@"button5"];
	[oldDevice removeObserver:self forKeyPath:@"button6"];
	[oldDevice removeObserver:self forKeyPath:@"button7"];
	[oldDevice removeObserver:self forKeyPath:@"button8"];
	
	[newDevice addObserver:self forKeyPath:@"gyro1" options:0 context:NULL];
	[newDevice addObserver:self forKeyPath:@"gyro2" options:0 context:NULL];
	[newDevice addObserver:self forKeyPath:@"gyro3" options:0 context:NULL];
	[newDevice addObserver:self forKeyPath:@"gyro4" options:0 context:NULL];
	[newDevice addObserver:self forKeyPath:@"button1" options:0 context:NULL];
	[newDevice addObserver:self forKeyPath:@"button2" options:0 context:NULL];
	[newDevice addObserver:self forKeyPath:@"button3" options:0 context:NULL];
	[newDevice addObserver:self forKeyPath:@"button4" options:0 context:NULL];
	[newDevice addObserver:self forKeyPath:@"button5" options:0 context:NULL];
	[newDevice addObserver:self forKeyPath:@"button6" options:0 context:NULL];
	[newDevice addObserver:self forKeyPath:@"button7" options:0 context:NULL];
	[newDevice addObserver:self forKeyPath:@"button8" options:0 context:NULL];
	device = [newDevice retain];
	[oldDevice release];
}

- (void)observeValueForKeyPath:(NSString*)keyPath
					  ofObject:(id)object
						change:(NSDictionary*)change
					   context:(void*)context {
	[self setNeedsDisplay:YES];
}


@end
