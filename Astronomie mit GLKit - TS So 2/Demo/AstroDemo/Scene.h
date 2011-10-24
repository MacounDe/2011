//
//  Scene.h
//  Space
//
//  Created by Daniel Dönigus on 04.01.11.
//  Copyright 2011 PRODEVCON. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AstronomicalObject.h"

@interface Scene : NSObject {
	AstronomicalObject* star;
}

-(AstronomicalObject*) getObjectWithName:(NSString*) name;

@property (retain) AstronomicalObject* star;

@end
