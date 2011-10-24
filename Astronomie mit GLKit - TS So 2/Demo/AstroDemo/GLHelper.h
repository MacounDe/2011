//
//  GLHelper.h
//  AstroDemo
//
//  Created by Dönigus Daniel on 24.09.11.
//  Copyright (c) 2011 PRODEVCON. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

//Calculates the position of a point in 3D world space on the 2D screen
//objectSpacePosition: The point in 3D world space
//model: The model view matrix
//proj: The projection matrix
//viewport: The screen bounds
//windowSpacePosition: The position of the point on 2D screen
bool gluProject(const GLKVector3 objectSpacePosition,
				const GLKMatrix4 model, const GLKMatrix4 proj,
				const int viewport[4],
				GLKVector3* windowSpacePosition);

//Calculates the direction of a ray from the camera position through a point on 2D screen
//windowSpacePosition: The point on 2D screen
//model: The model view matrix
//proj: The projection matrix
//viewport: The screen bounds
//windowSpacePosition: The direction from camera position through point on 2D screen
bool qaUnProject(const GLKVector3 windowSpacePosition,
				 const GLKMatrix4 model, const GLKMatrix4 proj,
				 const int viewport[4],
				 GLKVector3* objectSpacePosition);

//Calculates an approximized size of a sphere on the screen.
//screenOrigin: The origin of 2D screen bounds
//screenSize: Size of the 2D screen
//worldPosition: The 3D world position of the sphere
//radius: The radius of the sphere
//boundaryDirection: Screen direction in 3D world space
//projectionMatrix: The projection matrix at the moment the sphere is displayed on screen
//viewMatrix: The model view matrix at the moment the sphere is displayed on screen
//screenPosition: The position of the sphere on screen, including Z-coordinate
float qaScreenSizeOfSphere(const GLKVector2 screenOrigin, const GLKVector2 screenSize,
						   const GLKVector3 worldPosition, float radius, const GLKVector3 boundaryDirection, 
						   const GLKMatrix4 projectionMatrix, const GLKMatrix4 viewMatrix, 
						   GLKVector3* screenPosition);

//Calculates the horizontal direction of the screen in 3D world space
//screenOrigin: The origin of 2D screen bounds
//screenSize: Size of the 2D screen
//projectionMatrix: The projection matrix at the moment the sphere is displayed on screen
//viewMatrix: The model view matrix at the moment the sphere is displayed on screen
//calculatedDirection: The calculated screen direction
void qaCalculateScreenDirection(const GLKVector2 screenOrigin, const GLKVector2 screenSize, 
								const GLKMatrix4 projectionMatrix, const GLKMatrix4 viewMatrix,
								GLKVector3* calculatedDirection);
