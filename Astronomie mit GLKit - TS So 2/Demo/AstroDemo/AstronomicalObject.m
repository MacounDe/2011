//
//  AstronomicalObject.m
//  Space
//
//  Created by Daniel Dönigus on 11.01.11.
//  Copyright 2011 PRODEVCON. All rights reserved.
//

#import <GLKit/GLKVector4.h>

#import "AstronomicalObject.h"
#import <math.h>
#import "Planet.h"
#import "PlanetTrace.h"
#import "GLHelper.h"

@implementation AstronomicalObject

@synthesize scaleFactor;

@synthesize radius;
@synthesize semiMajorAxis;
@synthesize orbitalPeriod;
@synthesize siderealRotationPeriod;

@synthesize parent;
@synthesize children;

@synthesize model;
@synthesize trace;

@synthesize name;

@synthesize showSymbol;

@synthesize modelTransformation;
@synthesize modelTransformationForChildren;
@synthesize relativeTransformation;

@synthesize useLighting;

//Initializes the astronomical object and planet-model and trace-line-model with 
//data loaded from AstronomicalObjects.plist
- (id) initWithName:(NSString*) objectName andParent:(AstronomicalObject*) parentObject {
    if ((self = [super init])) {
        modelTransformation = GLKMatrix4Identity;
        modelTransformationForChildren = GLKMatrix4Identity;

		name = objectName;
		
		NSString* bundlePath = [[NSBundle mainBundle] bundlePath];
		NSString* filePath = [bundlePath stringByAppendingPathComponent:@"AstronomicalObjects.plist"];
		NSDictionary* allPlanetData = [NSDictionary dictionaryWithContentsOfFile:filePath];
	
		NSDictionary* planetData = [allPlanetData valueForKey:name];
	
		radius = [[planetData valueForKey:@"Radius"] floatValue] * planetScaleFactor;
		semiMajorAxis = [[planetData valueForKey:@"SemiMajorAxis"] floatValue] * rangeScaleFactor;
		orbitalPeriod = [[planetData valueForKey:@"OrbitalPeriod"] floatValue];
		siderealRotationPeriod = [[planetData valueForKey:@"SiderealRotationPeriod"] floatValue];
		
		useLighting = [[planetData valueForKey:@"UseLighting"] boolValue];
	
		NSString* colorMapName = [planetData valueForKey:@"ColorMapName"];
	
		NSDictionary* colorDict = [planetData valueForKey:@"Color"];
		GLKVector4 color = GLKVector4Make([[colorDict valueForKey:@"Red"] floatValue], [[colorDict valueForKey:@"Green"] floatValue], [[colorDict valueForKey:@"Blue"] floatValue], 1.0);
		
		if(parentObject != nil) {
			radius *= 0.1;
		} else {
			radius *= 0.1;
		}
		
        glGetError();
        model = [[Planet alloc] initWithRadius:radius 
                                       colorMapName:colorMapName 
                                      normalMapName:nil];

		trace = [[PlanetTrace alloc] initForAstronomicalObjectData: semiMajorAxis andColor:color.v];

		[self setParent:parentObject];
		NSMutableArray* childrenOfParent = [NSMutableArray arrayWithArray:[parent children]];
		[childrenOfParent addObject:self];
		[parent setChildren:childrenOfParent];
        
        scaleFactor = 1.0;
	}

	return self;
}

//Calculates the position of the astronomical object in 3D world space.
- (GLKVector3) retrievePosition {
	GLKVector4 origin;
	GLKVector4 result;
	
    origin = GLKVector4Make(0, 0, 0, 1);
    result = GLKMatrix4MultiplyVector4(modelTransformation, origin);
	
    return GLKVector3Make(result.v[0], result.v[1], result.v[2]);
}

//Calculates the position of the astronomical object relative to the parent object.
- (GLKVector3) retrieveRelativePosition:(GLKVector3*) position {
	GLKVector4 origin;
	GLKVector4 result;
	
    origin = GLKVector4Make(0, 0, 0, 1);
    result = GLKMatrix4MultiplyVector4(relativeTransformation, origin);
	
    return GLKVector3Make(result.v[0], result.v[1], result.v[2]);
}

//Calculates the position of the astronomical object on screen.
//Also returns the size of the object on 2D screen.
- (float) calculateScreenPositionOfObject:(GLKVector3*) screenPosition perspective:(GLKMatrix4) projectionMatrix viewMatrix:(GLKMatrix4) viewMatrix bounds:(CGRect) bounds {
	GLKVector2 origin;
	GLKVector2 size;
	
	origin.x = bounds.origin.x;
	origin.y = bounds.origin.y;
	size.x = bounds.size.width;
	size.y = bounds.size.height;
	
	GLKVector3 objectPosition = [self retrievePosition];
	float screenRadius = radius;
	
	GLKVector3 screenDirection;
	qaCalculateScreenDirection(origin, size, 
                               projectionMatrix, viewMatrix,
                               &screenDirection);
    
    float screenSize = qaScreenSizeOfSphere(origin, size, objectPosition, screenRadius, screenDirection, projectionMatrix, viewMatrix, screenPosition);
    
	return screenSize;
}

//Updates the transformations for the given time.
//relativeTransformation is relative transformation to the parent astronomical object
//modelTransformation is the complete transformation including all parent transformations
//modelTransformationForChildren is the relative transformation without the spin around own axis
- (void) calculateTransformationForTime:(float) time {
    GLKMatrix4 siderealRotation;

    if (siderealRotationPeriod != 0) {
        siderealRotation = GLKMatrix4MakeYRotation(time/siderealRotationPeriod);
    } else {
        siderealRotation = GLKMatrix4Identity;
    }
    GLKMatrix4 orbitalRotation;
    if (orbitalPeriod != 0) {
        orbitalRotation = GLKMatrix4MakeYRotation(-time/orbitalPeriod);
    } else {
        orbitalRotation = GLKMatrix4Identity;
    }
    GLKMatrix4 parentTransformation;
    if (self.parent != nil) {
        parentTransformation = [parent modelTransformationForChildren];
    } else {
        parentTransformation = GLKMatrix4Identity;
    }
    
    GLKMatrix4 translation = GLKMatrix4MakeTranslation(semiMajorAxis, 0, 0);
    
    GLKMatrix4 tmp = GLKMatrix4Multiply(orbitalRotation, translation);
    self.relativeTransformation = GLKMatrix4Multiply(tmp, siderealRotation);
    self.modelTransformation = GLKMatrix4Multiply(parentTransformation, relativeTransformation);
    self.modelTransformationForChildren = GLKMatrix4Multiply(orbitalRotation, translation);
}

//Calculates the screen size of the object. If the result is smaller 10, the scaleFactor is adapted, that
//the position of the sphere is approximately 10 pixels on screen.
- (void) updateScaleFactor:(GLKMatrix4) projectionMatrix viewMatrix:(GLKMatrix4) viewMatrix bounds:(CGRect) bounds {
    GLKVector3 vec;
    
    float screenSize = [self calculateScreenPositionOfObject:&vec perspective: projectionMatrix viewMatrix: viewMatrix bounds: bounds];

    if (screenSize >= 10) {
        scaleFactor = 1.0;
    } else {
        scaleFactor = 10.0 / screenSize;
    }
}

@end
