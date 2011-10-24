//
//  AppDelegate.m
//  BasicExample
//
//  Created by Boris Bügling on 30.09.11.
//  Copyright (c) 2011 - All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize mixer;
@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor yellowColor];
    [self.window makeKeyAndVisible];
    
    self.mixer = [[MixerHostAudio alloc] init];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [self.mixer stopAUGraph];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self.mixer startAUGraph];
}

@end