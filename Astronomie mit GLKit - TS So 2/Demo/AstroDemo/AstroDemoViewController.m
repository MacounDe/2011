//
//  AstroDemoViewController.m
//  AstroDemo
//
//  Created by Daniel Dönigus on 25.08.11.
//  Copyright 2011 PRODEVCON. All rights reserved.
//

#import "AstroDemoViewController.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

GLfloat gCubeVertexData[216] = 
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    0.5f, -0.5f, -0.5f,        1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
    
    0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,
    
    -0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,
    
    -0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,
    
    0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,
    
    0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f
};

@interface AstroDemoViewController () {
    float time;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
}

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;
@property (strong, nonatomic) GLKTextureInfo* skyboxTexture;
@property (strong, nonatomic) GLKSkyboxEffect *skyboxEffect;
@property GLKMatrix4 cameraRotationAroundSelectedPlanet;
@property float cameraDistanceToSelectedPlanet;
@property (strong, nonatomic) Scene* scene;
@property (strong, nonatomic) AstronomicalObject* selectedPlanet;
@property GLKMatrixStackRef matrixStack;

- (void)setupGL;
- (void)tearDownGL;
@end

@implementation AstroDemoViewController

@synthesize context = _context;
@synthesize effect = _effect;
@synthesize skyboxEffect;
@synthesize skyboxTexture;
@synthesize cameraRotationAroundSelectedPlanet;
@synthesize cameraDistanceToSelectedPlanet;
@synthesize scene;
@synthesize selectedPlanet;
@synthesize matrixStack;

- (void) registerGestureRecognizer {
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
	[panRecognizer setDelegate:self];
	[self.view addGestureRecognizer:panRecognizer];
	
	UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
	[pinchRecognizer setDelegate:self];
	[self.view addGestureRecognizer:pinchRecognizer];
	
	UIRotationGestureRecognizer *rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotationGesture:)];
	[rotationRecognizer setDelegate:self];
	[self.view addGestureRecognizer:rotationRecognizer];
    
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
	[tapRecognizer setDelegate:self];
	[self.view addGestureRecognizer:tapRecognizer];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    //Initialize view and needed GL parameters
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    //Initializes the transformation values
    self.cameraRotationAroundSelectedPlanet = GLKMatrix4Identity;
    self.cameraDistanceToSelectedPlanet = 0.015;

    self.matrixStack = GLKMatrixStackCreate(kCFAllocatorDefault);
    
    [self registerGestureRecognizer];
    
    [self setupGL];
    
    //Initialize scene after GL-initialization, because textures have to be loaded
    //in the current GL-context
    self.scene = [[Scene alloc] init];
    self.selectedPlanet = [scene getObjectWithName:@"Earth"];
}

- (void)viewDidUnload
{    
    [super viewDidUnload];
    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
	self.context = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc. that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    //Initialize base effect
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.lightingType = GLKLightingTypePerPixel;

    self.effect.textureOrder = [NSArray arrayWithObjects: self.effect.texture2d0, nil];
    self.effect.texture2d0.enabled = GL_TRUE;
    self.effect.texture2d0.envMode = GLKTextureEnvModeModulate;
    self.effect.texture2d0.target = GLKTextureTarget2D;
    self.effect.light0.ambientColor = GLKVector4Make(0.8, 0.8, 0.8, 1.0);
    
    //Loading skybox texture and initialize skybox effect
    NSString *path = [[NSBundle mainBundle] pathForResource: @"CubeMap" ofType:@"jpg"];
    skyboxTexture = [GLKTextureLoader cubeMapWithContentsOfFile:path  
                                                        options:nil  
                                                          error:nil];
    skyboxEffect = [[GLKSkyboxEffect alloc] init];
    skyboxEffect.label = @"Universe";
    skyboxEffect.center = GLKVector3Make(0, 0, 0);
    skyboxEffect.textureCubeMap.name = skyboxTexture.   name;
    skyboxEffect.xSize = 40;
    skyboxEffect.ySize = 40;
    skyboxEffect.zSize = 40;

    glEnable(GL_DEPTH_TEST);
    
    //Initialize OpenGL transparency mode
    glDepthFunc(GL_LEQUAL);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    self.effect = nil;
}

//Returns camera transformation
- (GLKMatrix4) viewMatrix {
    GLKVector3 selectedPlanetPosition = [selectedPlanet retrievePosition];
    
    GLKMatrix4 zoomMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0, 0, -cameraDistanceToSelectedPlanet);
    GLKMatrix4 cameraMatrix = GLKMatrix4Multiply(zoomMatrix, cameraRotationAroundSelectedPlanet);
    return GLKMatrix4TranslateWithVector3(cameraMatrix, GLKVector3Negate(selectedPlanetPosition));
}

//Draw planet model of astronomical object
- (void) drawPlanet:(AstronomicalObject*) astronomicalObject {
    GLKMatrix4 transformation = [astronomicalObject modelTransformation];
    GLKMatrixStackMultiplyMatrix4(matrixStack, transformation);
    GLKMatrixStackScale(matrixStack, astronomicalObject.scaleFactor, astronomicalObject.scaleFactor, astronomicalObject.scaleFactor);
    
    self.effect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(matrixStack);
    //Lighting has to be disabled for sun
    if (astronomicalObject.useLighting) {
        self.effect.light0.enabled = GL_TRUE;
    } else {
        self.effect.light0.enabled = GL_FALSE;
    }
    self.effect.texture2d0.enabled = GL_TRUE;
    self.effect.texture2d0.name = [astronomicalObject.model.textureInfo name];
    
    glBindVertexArrayOES(astronomicalObject.model.vertexArray);
    
    [self.effect prepareToDraw];
    
    glDrawElements(GL_TRIANGLES, astronomicalObject.model.elementCount, GL_UNSIGNED_SHORT, (void*)0);
}

//Draw planet trace of astronomical object
- (void) drawTrace:(AstronomicalObject*) astronomicalObject {
    if (astronomicalObject.parent == nil) {
        return;
    }
    
    GLKMatrix4 transformation = [astronomicalObject.parent modelTransformationForChildren];
    GLKMatrixStackMultiplyMatrix4(matrixStack, transformation);
    if (astronomicalObject.orbitalPeriod != 0) {
        GLKMatrixStackRotateY(matrixStack, -time/astronomicalObject.orbitalPeriod);
    } 
    
    self.effect.texture2d0.enabled = GL_FALSE;
    self.effect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(matrixStack);
    self.effect.light0.enabled = GL_FALSE;
    
    glBindVertexArrayOES(astronomicalObject.trace.vertexArray);
    
    [self.effect prepareToDraw];
    
    glDrawArrays(GL_LINE_STRIP, 0, astronomicalObject.trace.elementCount);
    
    glBindVertexArrayOES(0);
    
}

//Draw both models for astronomical object
- (void) drawAstronomicalObject:(AstronomicalObject*) astronomicalObject {
    for (AstronomicalObject* child in [astronomicalObject children]) {
        [self drawAstronomicalObject: child];
    }
    
    GLKMatrixStackPush(matrixStack);
    [self drawPlanet:astronomicalObject];
    GLKMatrixStackPop(matrixStack);
    GLKMatrixStackPush(matrixStack);
    [self drawTrace:astronomicalObject];
    GLKMatrixStackPop(matrixStack);
}

//Calculate transformation for planet and recursively for all children
- (void) calculateTransformationForPlanet:(AstronomicalObject*) astronomicalObject {
    [astronomicalObject calculateTransformationForTime:time];
    
    for (AstronomicalObject* child in [astronomicalObject children]) {
        [self calculateTransformationForPlanet: child];
    }
}

#pragma mark - GLKView and GLKViewController delegate methods
- (GLKMatrix4) projection {
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    return GLKMatrix4MakePerspective(GLKMathDegreesToRadians(45.0f), aspect, 0.001f, 100.0f);
}

//Calculate scale factor for planet and recursively for all children
//This is needed, so every planet is drawn with an approximately minimum size of 10 pixels
- (void) recalculateScaleFactorForChildrenAndObject:(AstronomicalObject*) astronomicalObject {
    for (AstronomicalObject* child in astronomicalObject.children) {
        [self recalculateScaleFactorForChildrenAndObject:child];
    }
    
    [astronomicalObject updateScaleFactor:[self projection] viewMatrix:[self viewMatrix] bounds:self.view.bounds];
}


//Update is called in advance to the drawing method
- (void)update
{ 
    [self calculateTransformationForPlanet:scene.star];
 
    [self recalculateScaleFactorForChildrenAndObject:scene.star];

    GLKMatrixStackLoadMatrix4(matrixStack, [self viewMatrix]);

    GLKMatrix4 projectionMatrix = [self projection];
    
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    self.skyboxEffect.transform.projectionMatrix = projectionMatrix;
    self.skyboxEffect.transform.modelviewMatrix = cameraRotationAroundSelectedPlanet;
    
    //Set the transformation of the light to the identity matrix instead of the effect transformation
    //I dunno why and where the transformation is set back, if you do this right after initialization
    //of the effect?!?
    if (self.effect.transform == self.effect.light0.transform) {
        GLKEffectPropertyTransform* transform = [[GLKEffectPropertyTransform alloc] init];
        [self.effect.light0 setTransform:transform];
    }
    
    //Set the position of the light with respect to the camera position, so all planets
    //seem to be illuminated from the sun object
    GLKMatrix4 viewMatrix = [self viewMatrix];
    GLKVector4 cameraPosition = GLKMatrix4MultiplyVector4(viewMatrix, GLKVector4Make(0,0,0,1));
    self.effect.light0.position = cameraPosition;

    time += self.timeSinceLastUpdate * 0.5f;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glDisable(GL_DEPTH_TEST);
    //Draw skybox background
    [skyboxEffect prepareToDraw];
    [skyboxEffect draw];
    glEnable(GL_DEPTH_TEST);
    
    //Recursively draw planets and planet traces
    [self drawAstronomicalObject: scene.star];
}

//The x-component of the finger translation is used to rotate the camera transformation
//around the y-axis, while the y-component is used to rotate around the x-axis.
- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint translate = [gestureRecognizer translationInView:self.view];
	
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan ||
		gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        GLKMatrix4 rotX = GLKMatrix4MakeXRotation(-translate.y/180*M_PI);
        [self setCameraRotationAroundSelectedPlanet: GLKMatrix4Multiply(rotX, [self cameraRotationAroundSelectedPlanet])];

        GLKMatrix4 rotY = GLKMatrix4MakeYRotation(-translate.x/180*M_PI);
        [self setCameraRotationAroundSelectedPlanet: GLKMatrix4Multiply(rotY, [self cameraRotationAroundSelectedPlanet])];
		
		[gestureRecognizer setTranslation:CGPointZero inView:self.view];
	}
}

//The rotation is used to rotate the camera transformation around the z-axis.
- (IBAction)handleRotationGesture:(UIRotationGestureRecognizer *)gestureRecognizer {
    CGFloat rotation = [gestureRecognizer rotation];
	
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan ||
		gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        GLKMatrix4 rotZ = GLKMatrix4MakeZRotation(-rotation);
        [self setCameraRotationAroundSelectedPlanet: GLKMatrix4Multiply(rotZ, [self cameraRotationAroundSelectedPlanet])];
		
		[gestureRecognizer setRotation:0.0];
	}
}

//The pinch gesture is used to zoom the camera back and forth from the planet.
- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)gestureRecognizer {
    CGFloat scale = [gestureRecognizer scale];
	
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan ||
		gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
        float distance = [self cameraDistanceToSelectedPlanet]/scale;
        distance = MAX(distance, 0.0005);
        [self setCameraDistanceToSelectedPlanet:distance];
		
		[gestureRecognizer setScale:1.0];
	}
}

const float gestureMinimumRadius = 20;

- (BOOL) didUserTapOnAstroObject:(AstronomicalObject*) astroObject onTapPosition:(CGPoint)tapPosition {
	GLKVector3 objectPositionOnScreen;
	
	float radius = [astroObject calculateScreenPositionOfObject:&objectPositionOnScreen perspective:[self projection] viewMatrix:[self viewMatrix] bounds:self.view.bounds];
	
	if(radius < gestureMinimumRadius) {
		radius = gestureMinimumRadius;
	}
	
	if(objectPositionOnScreen.v[0]-radius < tapPosition.x && objectPositionOnScreen.v[0]+radius > tapPosition.x &&
	   objectPositionOnScreen.v[1]-radius < tapPosition.y && objectPositionOnScreen.v[1]+radius > tapPosition.y) {
		return YES;
	} 
	
	return FALSE;
}

//Checks recursively if the user has tapped on the given astronomical object or one of its children.
- (AstronomicalObject*) didUserTapOnChildrenOrPlanet:(AstronomicalObject*) astroObject withPosition:(CGPoint) positionScreenSpace {
	if([self didUserTapOnAstroObject:astroObject onTapPosition:positionScreenSpace]) {
		return astroObject;
	}
	
	for(AstronomicalObject* child in [astroObject children]) {
		AstronomicalObject* hitObject = [self didUserTapOnChildrenOrPlanet:child withPosition:positionScreenSpace];
		
		if(hitObject != nil) {
			return hitObject;
		}
	}
	
	return nil;
}

//If the user taps on the screen, it is checked if the user has tapped on a planet.
//If the user tapped on a planet this planet is used as new selected planet.
- (IBAction)handleTapGesture:(UITapGestureRecognizer *)gestureRecognizer {
    CGPoint position = [gestureRecognizer locationInView:self.view];
	
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
		AstronomicalObject* newSelectedObject = [self didUserTapOnChildrenOrPlanet:scene.star withPosition:position];
		
		if(newSelectedObject != nil && newSelectedObject != self.selectedPlanet) {
			self.selectedPlanet = newSelectedObject;
		}
	}
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	if(gestureRecognizer.view == otherGestureRecognizer.view) {
		return YES;
	}
	
	return NO;
}

@end
