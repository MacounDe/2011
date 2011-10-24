//
//  AppDelegate.h
//  BasicExample
//
//  Created by Boris Bügling on 30.09.11.
//  Copyright (c) 2011 - All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MixerHostAudio.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) MixerHostAudio* mixer;
@property (strong, nonatomic) UIWindow *window;

@end