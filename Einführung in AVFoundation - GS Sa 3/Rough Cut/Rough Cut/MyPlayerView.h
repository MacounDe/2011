//
//  MyPlayerView.h
//  Rough Cut
//
//  Created by Stefan Hafeneger on 8/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AVPlayer;

@interface MyPlayerView : NSView

@property (nonatomic, assign) AVPlayer *player;

@end
