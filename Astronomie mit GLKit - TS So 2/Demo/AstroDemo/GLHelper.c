//
//  GLHelper.c
//  AstroDemo
//
//  Created by Daniel Dönigus on 10.10.11.
//  Copyright (c) 2011 PRODEVCON. All rights reserved.
//

#import "GLHelper.h"

//Calculates the position of a point in 3D world space on the 2D screen.
//See gluProject
//objectSpacePosition: The point in 3D world space
//model: The model view matrix
//proj: The projection matrix
//viewport: The screen bounds
//windowSpacePosition: The position of the point on 2D screen
bool gluProject(const GLKVector3 objectSpacePosition,
				const GLKMatrix4 model, const GLKMatrix4 proj,
				const int viewport[4],
				GLKVector3* windowSpacePosition)
{
	GLKVector4 in, out;
    
	in = GLKVector4MakeWithVector3(objectSpacePosition, 1.0);
    
    out = GLKMatrix4MultiplyVector4(model, in);
    in = GLKMatrix4MultiplyVector4(proj, out);
	
	if (in.v[3] == 0.0)
		return false;
	
	in.v[0] /= in.v[3];
	in.v[1] /= in.v[3];
	in.v[2] /= in.v[3];
	
	windowSpacePosition->v[0] = viewport[0] + (1 + in.v[0]) * viewport[2] / 2;
	windowSpacePosition->v[1] = viewport[1] + (1 + in.v[1]) * viewport[3] / 2;
	windowSpacePosition->v[2] = (1 + in.v[2]) / 2;
	return true;
}

//Calculates an approximized size of a sphere on the screen.
//The calculation is done by calculating the position of the sphere origin and a point on the sphere
//boundary on 2D screen and returning the length of the difference.
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
						   GLKVector3* screenPosition) {
	int viewPort[4];
	viewPort[0] = screenOrigin.x;
	viewPort[1] = screenOrigin.y;
	viewPort[2] = screenSize.x;
	viewPort[3] = screenSize.y;
	
	GLKVector3 position;
    
	GLKVector3 pointOnBoundary;
	pointOnBoundary.v[0] = worldPosition.v[0] + boundaryDirection.v[0] * radius;
	pointOnBoundary.v[1] = worldPosition.v[1] + boundaryDirection.v[1] * radius;
	pointOnBoundary.v[2] = worldPosition.v[2] + boundaryDirection.v[2] * radius;
	
	gluProject(worldPosition,
			   viewMatrix, projectionMatrix,
			   viewPort,
			   &position);
	position.v[1] = viewPort[3] - position.v[1];
	
	GLKVector3 pointOnBoundaryProjectedVec3;
	gluProject(pointOnBoundary,
			   viewMatrix, projectionMatrix,
			   viewPort,
			   &pointOnBoundaryProjectedVec3);
	pointOnBoundaryProjectedVec3.v[1] = viewPort[3] - pointOnBoundaryProjectedVec3.v[1];
	
	GLKVector3 objectDirection;
    objectDirection = GLKVector3Subtract(pointOnBoundaryProjectedVec3, position);
	
	if(screenPosition != NULL) {
        screenPosition->v[0] = position.v[0];
        screenPosition->v[1] = position.v[1];
        screenPosition->v[2] = position.v[2];
	}
	
    return GLKVector3Length(objectDirection);
}

//Calculates the direction of a ray from the camera position through a point on 2D screen.
//See gluUnProject.
//windowSpacePosition: The point on 2D screen
//model: The model view matrix
//proj: The projection matrix
//viewport: The screen bounds
//windowSpacePosition: The direction from camera position through point on 2D screen
bool qaUnProject(const GLKVector3 windowSpacePosition,
				 const GLKMatrix4 model, const GLKMatrix4 proj,
				 const int viewport[4],
				 GLKVector3* objectSpacePosition)
{
	GLKMatrix4 m, A;
	GLKVector4 in, out;
	
	in.v[0] = (windowSpacePosition.v[0] - viewport[0]) * 2 / viewport[2] - 1.0;
	in.v[1] = (windowSpacePosition.v[1] - viewport[1]) * 2 / viewport[3] - 1.0;
	in.v[2] = 2 * windowSpacePosition.v[2] - 1.0;
	in.v[3] = 1.0;
	
    A = GLKMatrix4Multiply(proj, model);
    m = GLKMatrix4Invert(A, NULL);
	
    out = GLKMatrix4MultiplyVector4(m, in);
	if (out.v[3] == 0.0)
		return false;
	
	objectSpacePosition->v[0] = out.v[0] / out.v[3];
	objectSpacePosition->v[1] = out.v[1] / out.v[3];
	objectSpacePosition->v[2] = out.v[2] / out.v[3];
	return true;
}

//Calculates the horizontal direction of the screen in 3D world space.
//The calculation is done by calculating the 3D position of the lower left and lower right coordinates of the
//2D screen and returning the difference as horizontal direction.
//screenOrigin: The origin of 2D screen bounds
//screenSize: Size of the 2D screen
//projectionMatrix: The projection matrix at the moment the sphere is displayed on screen
//viewMatrix: The model view matrix at the moment the sphere is displayed on screen
//calculatedDirection: The calculated screen direction
void qaCalculateScreenDirection(const GLKVector2 screenOrigin, const GLKVector2 screenSize, 
								const GLKMatrix4 projectionMatrix, const GLKMatrix4 viewMatrix,
								GLKVector3* calculatedDirection) {
	int viewPort[4];
	viewPort[0] = screenOrigin.x;
	viewPort[1] = screenOrigin.y;
	viewPort[2] = screenSize.x;
	viewPort[3] = screenSize.y;
	
	GLKVector3 viewPosStart;
	GLKVector3 viewPosEnd;
	
    viewPosStart.v[0] = screenOrigin.x;
    viewPosStart.v[1] = screenOrigin.y;
    viewPosStart.v[2] = 0;
    viewPosEnd.v[0] = screenOrigin.x + screenSize.x;
    viewPosEnd.v[1] = screenOrigin.y;
    viewPosEnd.v[2] = 0;
	
	GLKVector3 objectSpaceTopLeft;
	GLKVector3 objectSpaceTopRight;
	qaUnProject(viewPosStart,
				viewMatrix, projectionMatrix,
				viewPort,
				&objectSpaceTopLeft);
	
	qaUnProject(viewPosEnd,
				viewMatrix, projectionMatrix,
				viewPort,
				&objectSpaceTopRight);
	
    GLKVector3 direction = GLKVector3Subtract(objectSpaceTopRight, objectSpaceTopLeft);
    direction = GLKVector3Normalize(direction);
    calculatedDirection->v[0] = direction.v[0];
    calculatedDirection->v[1] = direction.v[1];
    calculatedDirection->v[2] = direction.v[2];
}
