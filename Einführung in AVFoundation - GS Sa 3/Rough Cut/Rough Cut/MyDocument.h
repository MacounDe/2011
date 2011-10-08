//
//  MyDocument.h
//  Rough Cut
//
//  Created by Stefan Hafeneger on 8/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AVPlayer;
@class MyPlayerView;

@interface MyDocument : NSDocument

@property (nonatomic, readonly) AVPlayer *player;

@property (nonatomic, assign) IBOutlet MyPlayerView *playerView;
@property (nonatomic, assign) IBOutlet NSButton *playPauseButton;
@property (nonatomic, assign) IBOutlet NSSlider *currentTimeSlider;

- (IBAction)togglePlayback:(id)sender;
- (IBAction)seekToTime:(id)sender;

- (IBAction)addClips:(id)sender;
- (IBAction)export:(id)sender;

@end
