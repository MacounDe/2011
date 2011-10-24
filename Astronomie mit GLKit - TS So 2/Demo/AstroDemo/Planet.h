//
//  Planet.h
//  Space
//
//  Created by Daniel Dönigus on 14.01.11.
//  Copyright 2011 PRODEVCON. All rights reserved.
//

#import <GLKit/GLKTextureLoader.h>

#import <Foundation/Foundation.h>
#import "Model.h"

@interface Planet : Model {
	GLKTextureInfo* colorTexture;
}

- (id)initWithRadius:(float) radius 
		colorMapName:(NSString*) colorMapName 
	   normalMapName:(const char*) normalMapName;

@end
