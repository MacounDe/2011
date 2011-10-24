//
//  Scene.m
//  Space
//
//  Created by Daniel Dönigus on 04.01.11.
//  Copyright 2011 PRODEVCON. All rights reserved.
//

#import "Scene.h"
#import "AstronomicalObject.h"
#import "Planet.h"

const float starUpperColorDifference = 0.2;
const float starNoColorDifference = 0.8;

@implementation Scene

@synthesize star;

- (AstronomicalObject*) createAstronomicalObjectWithName:(NSString*) name andParent:(AstronomicalObject*) parent {
    return [[AstronomicalObject alloc] initWithName:name andParent:parent];
}

//Creating Astronomical Objects for solar system.
- (void) createAstronomicalObjects {
	star = [self createAstronomicalObjectWithName:@"Sun" andParent:nil];
    [self createAstronomicalObjectWithName:@"Mercury" andParent:star];
    [self createAstronomicalObjectWithName:@"Venus" andParent:star];
	AstronomicalObject* earth = [self createAstronomicalObjectWithName:@"Earth" andParent:star];
    [self createAstronomicalObjectWithName:@"Moon" andParent:earth];
    [self createAstronomicalObjectWithName:@"Mars" andParent:star];
    [self createAstronomicalObjectWithName:@"Jupiter" andParent:star];
    [self createAstronomicalObjectWithName:@"Saturn" andParent:star];
    [self createAstronomicalObjectWithName:@"Uranus" andParent:star];
    [self createAstronomicalObjectWithName:@"Neptune" andParent:star];
}

- (id) init {
    if ((self = [super init]))
    {
		[self createAstronomicalObjects];
	}
	return self;
}

-(AstronomicalObject*) findObjectWithName:(NSString*) name byChildOrObject:(AstronomicalObject*) astroObject {
	if([[astroObject name] isEqualToString:name]) {
		return astroObject;
	}
	
	for(AstronomicalObject* child in [astroObject children]) {
		AstronomicalObject* foundObject = [self findObjectWithName:name byChildOrObject:child];
		
		if(foundObject != nil) {
			return foundObject;
		}
	}
	
	return nil;
}

//Returns recursively the astronomical object with the given name.
-(AstronomicalObject*) getObjectWithName:(NSString*) name {
    AstronomicalObject* foundObject = [self findObjectWithName:name byChildOrObject:star];
    
    if(foundObject != nil) {
        return foundObject;
    }
	
	return nil;
}

- (void)dealloc {
}

@end
