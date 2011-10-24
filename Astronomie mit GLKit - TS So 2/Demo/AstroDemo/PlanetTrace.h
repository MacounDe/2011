//
//  PlanetTrace.h
//  Space
//
//  Created by Daniel Dönigus on 14.01.11.
//  Copyright 2011 PRODEVCON. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"

@interface PlanetTrace : Model {

}

- (id)initForAstronomicalObjectData:(float) radius andColor:(float*) color;

@end
