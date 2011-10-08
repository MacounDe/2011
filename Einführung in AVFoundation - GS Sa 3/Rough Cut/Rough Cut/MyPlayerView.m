//
//  MyPlayerView.m
//  Rough Cut
//
//  Created by Stefan Hafeneger on 8/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyPlayerView.h"

#import <AVFoundation/AVFoundation.h>

@implementation MyPlayerView

- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	
	if (self)
	{
		// Create new AVPlayerLayer.
		AVPlayerLayer *playerLayer = [AVPlayerLayer layer];
		
		// Setup AVPlayerLayer.
		[playerLayer setBackgroundColor:CGColorGetConstantColor(kCGColorBlack)];
		[playerLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
		
		// Make AVPlayerLayer view's layer.
		[self setLayer:playerLayer];
		[self setWantsLayer:YES];
	}
	
	return self;
}

#pragma mark -

- (AVPlayer *)player
{
	return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player
{
	[(AVPlayerLayer *)[self layer] setPlayer:player];
}

@end
