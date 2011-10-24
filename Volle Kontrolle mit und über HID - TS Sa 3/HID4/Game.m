//
//  Game.m
//  HID4
//
//  Created by Matthias Krauß on 20.08.11.
//  Copyright 2011 Matthias Krauß. All rights reserved.
//

#import "Game.h"
#import "Player.h"
#import "Terrain.h"
#import "HID4AppDelegate.h"
#import <OpenGL/OpenGL.h>
#import <OpenGL/glu.h>
#import "glTools.h"
#import "Sky.h"

@interface Game ()

@property (readwrite, retain) NSTimer* timer;
@property (readwrite, retain) Terrain* terrain;
@property (readwrite, retain) NSArray* players;
@property (readwrite, retain) Sky* sky;

- (void) gameStep:(NSTimer*)timer;

- (void) addPlayer:(NSNotification*)notification;
- (void) removePlayer:(NSNotification*)notification;

@end


@implementation Game

@synthesize timer;
@synthesize terrain;
@synthesize players;
@synthesize sky;

- (id) init {
	self = [super init];
	self.terrain = [Terrain terrain];
	self.sky = [Sky sky];
	self.players = [NSArray array];
	self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0
												  target:self
												selector:@selector(gameStep:)
												userInfo:nil
												 repeats:YES];
	NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(addPlayer:) name:HIDPluggedNotification object:nil];
	[nc addObserver:self selector:@selector(removePlayer:) name:HIDUnpluggedNotification object:nil];
	return self;
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self.timer invalidate];
	self.timer = nil;
	self.terrain = nil;
	self.players = nil;
	self.sky = nil;
	[super dealloc];
}

- (void) gameStep:(NSTimer*)timer {
	for (Player* player in self.players) [player behave];
 	[[NSNotificationCenter defaultCenter] postNotificationName:@"Game step" object:self];
}


- (void) renderWithCamera:(Camera*)camera resources:(OGLResourceManager*)resources {
	GLfloat lightPos[] = {-1,2,-1,0};
	glLightfv(GL_LIGHT0, GL_POSITION, lightPos);	//main light direction, in OpenGL world space
	glPushMatrix();
	glLoadIdentity();
	glLightfv(GL_LIGHT1, GL_POSITION, lightPos);	//main light direction, in our world space
	glPopMatrix();
	
	[self.terrain renderWithCamera:camera resources:resources];
	[self.sky renderWithCamera:camera resources:resources];
	for (Player* player in self.players) [player renderWithCamera:camera resources:resources];
	glError();
}

// ----------- private -------------

- (void) addPlayer:(NSNotification*)notification {
	HIDDevice* controller = [notification object];
	NSLog(@"setting up player for %@",controller);
	vec3 spawnPosition;
	if ([self.players count] < 1) set(&spawnPosition,0,500,0);
	else {
		set(&spawnPosition,0,0,0);
		for (Player* player in self.players) {
			vec3 playerPos = [player pos];
			add(&spawnPosition,&playerPos,&spawnPosition);
		}
		scale(&spawnPosition,1.0/[self.players count]);
		vec3 offset = { 30,0,0 };
		add(&spawnPosition,&offset,&spawnPosition);
	}
    Player* newPlayer = [Player playerWithHIDDevice:controller];
	newPlayer.pos = spawnPosition;
	self.players = [self.players arrayByAddingObject:newPlayer];
}

- (void) removePlayer:(NSNotification*)notification {
	HIDDevice* controller = [notification object];
	NSLog(@"removing player for %@",controller);
	NSMutableArray* remaining = [NSMutableArray array];
	for (Player* player in self.players) {
		if (![player.hidDevice isEqual:controller]) [remaining addObject:player];
	}
	self.players = remaining;
}


@end
