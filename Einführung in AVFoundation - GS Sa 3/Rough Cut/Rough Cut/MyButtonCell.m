//
//  MyButtonCell.m
//  Rough Cut
//
//  Created by Stefan Hafeneger on 9/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyButtonCell.h"

@implementation MyButtonCell

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView
{
	// Draw bezel image.
	[(NSImage *)[NSImage imageNamed:([self isHighlighted] ? @"button-highlighted" : @"button-normal")] drawInRect:frame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f respectFlipped:YES hints:nil];
	
	// Draw play or pause image.
	[(NSImage *)[NSImage imageNamed:(NSOffState == [self state] ? @"button-play" : @"button-pause")] drawInRect:frame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f respectFlipped:YES hints:nil];
}

- (void)drawImage:(NSImage *)image withFrame:(NSRect)frame inView:(NSView *)controlView
{
	// Don't draw image if set.
}

- (NSRect)drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView
{
	return NSZeroRect; // Don't draw text if set.
}

@end
