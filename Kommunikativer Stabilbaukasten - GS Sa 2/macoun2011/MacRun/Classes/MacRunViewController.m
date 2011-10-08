/*
 *  MacRunViewController.m
 *  Main View Controller
 *
 *  Created by Pascal Bihler on 23.08.09.
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *  
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 * 
 */

#import "MacRunViewController.h"
#import "PBSimLocationManager.h"
#import "Waypoint.h"
#import </usr/include/objc/objc-class.h>

NSString * const MRTargetDistanceKey = @"MRTargetDistanceKey";
NSInteger const MRStandardDistance = 100;
NSInteger const MRMinDistance = 50;
NSInteger const MRMaxDistance = 100000;
NSInteger const MRDistanceWheelSteps = 12;
NSString * const MRHighscoreKey = @"Highscore-%d";


@interface MacRunViewController ()

- (void) initTargetDistanceSelection;
- (void) initLocationService;
- (void) initSound;
- (void) animateCircle;
- (void) updateTimeDisplay;
- (void) updateDistanceLabel;
- (double) normalizeArc:(double) arc;
- (double) calcWheelAngleOfPoint:(CGPoint) point;
@end

@implementation MacRunViewController



#pragma mark ---- General View Controller Methods ----

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self initTargetDistanceSelection];
	[self initSound];
	[self initLocationService];
	
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
       return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	[timeUpdateTimer release];
	[startTime release];
	[lastLocation release];
	[infoLabel release];
	[circleImage release];
}


- (void)dealloc {
	[locationManager release];
    [super dealloc];
}

#pragma mark ---- Extra Init code ----


- (void) initTargetDistanceSelection {
	wheelTransform = CGAffineTransformTranslate(CGAffineTransformIdentity,-pointerImage.frame.origin.x-pointerImage.frame.size.width/2,-pointerImage.frame.origin.y-pointerImage.frame.size.height/2);
	
	targetDistance = [[NSUserDefaults standardUserDefaults] integerForKey:MRTargetDistanceKey];
	if (! targetDistance) 
		targetDistance = MRStandardDistance;
	[self updateDistanceLabel];
}

- (void) initLocationService {
	
#if TARGET_IPHONE_SIMULATOR
    locationManager = [[PBSimLocationManager alloc] initWithNMEAFile:[[[NSBundle mainBundle] resourcePath]stringByAppendingPathComponent:@"data3.nmea"]speedup:3]; 
    
    // Aufgrund eines Fehlers in der Kombination Lion + XCode 4.1 meldet der
    // CLLocationManager immer "false" bei Aufruf von "locationServicesEnabled".
    // Daher überschreiben wir einfach diese fehlerhafte Methode für die Simulation:
    Method orig_method = class_getClassMethod([CLLocationManager class], @selector(locationServicesEnabled));
    Method alt_method = class_getClassMethod([PBSimLocationManager class], @selector(locationServicesEnabled));
    method_setImplementation(orig_method, method_getImplementation(alt_method));
    // Ende Workaround
    
#else
	locationManager = [[CLLocationManager alloc] init];
#endif
	
	locationManager.delegate = self;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	[locationManager startUpdatingLocation];
	
	//  Test if location services are activated:
	if (! [CLLocationManager locationServicesEnabled]) {
		infoLabel.text = @"Ortung deaktiviert";
	} else {
		[self startAnimatingCircle];
	}
}

- (void) initSound {
	
	// Get the main bundle for the app
    CFBundleRef mainBundle = CFBundleGetMainBundle ();
	
    // Get the URL to the sound file to play and create a system sound object representing the sound file
    CFURLRef soundFileURLRefSonar  =    CFBundleCopyResourceURL (mainBundle,CFSTR ("sonar"),CFSTR ("caf"),NULL);
	AudioServicesCreateSystemSoundID (soundFileURLRefSonar,&sonarSound);
	
	CFURLRef soundFileURLRefGo  =    CFBundleCopyResourceURL (mainBundle,CFSTR ("go"),CFSTR ("caf"),NULL);
	AudioServicesCreateSystemSoundID (soundFileURLRefGo,&goSound);
	
	CFURLRef soundFileURLRefApplause  =    CFBundleCopyResourceURL (mainBundle,CFSTR ("applause"),CFSTR ("caf"),NULL);
	AudioServicesCreateSystemSoundID (soundFileURLRefApplause,&applauseSound);
	
	CFURLRef soundFileURLRefClaps  =    CFBundleCopyResourceURL (mainBundle,CFSTR ("claps"),CFSTR ("caf"),NULL);
	AudioServicesCreateSystemSoundID (soundFileURLRefClaps,&clapsSound);
	
}


#pragma mark ---- CoreLocation Delegate Methods ----

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	
	if (newLocation.verticalAccuracy < 0) // We use only GPS-Locations
		return;
	
	//remember location
	[lastLocation release];
	lastLocation = [newLocation retain];
	
	if (! running) {
		if (! initialized) {
			initialized = YES;
			[self stopAnimatingCircle];
			infoLabel.text = @"Ortung erfolgreich.";
			startButton.hidden = NO;
		}
	} else {
        
		totalDistance += [newLocation distanceFromLocation:oldLocation];
		
		CLLocationDistance distanceToGo = (int) (targetDistance- totalDistance);
		
		if (distanceToGo > 0) {
			infoLabel.text = [NSString stringWithFormat:@"Noch %d Meter!",(int)distanceToGo];
			
			if (locationManager.distanceFilter > distanceToGo)
				locationManager.distanceFilter = distanceToGo;
			
		} else {
			[self stopRun];		
			
		}
	}
	

	
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	
	if ([error domain] == kCLErrorDomain) { // Only CoreLocation Errors
		
		switch ([error code]) {
			case kCLErrorDenied:
				infoLabel.text = @"Keine Ortung erlaubt";
				[self stopAnimatingCircle];
				break;
			case kCLErrorNetwork:
				infoLabel.text = @"Netzwerkfehler...";
				break;
			case kCLErrorLocationUnknown:
				infoLabel.text = @"Unbekannte Position...";
				break;
			default:
				infoLabel.text = [NSString stringWithFormat:@"Fehler: %@",[error localizedDescription]];
				[self stopAnimatingCircle];
		}
	}
}

#pragma mark ---- running data ----

- (IBAction) startRun:(id)sender {
	
	
	locationManager.distanceFilter = 10; // meters
	
	running = YES;
	startButton.hidden = YES;
	totalDistance = 0;
	infoLabel.text = @"Los gehts!";
	[UIDevice currentDevice].proximityMonitoringEnabled = YES;

	timeLabel.hidden = NO;
	[startTime release];
	startTime = [[NSDate date] retain];
	[self updateTimeDisplay];
	timeUpdateTimer = [[NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateTimeDisplay) userInfo:nil repeats:YES] retain];
	
	AudioServicesPlaySystemSound(goSound);
}

- (void) updateTimeDisplay {
	if (! running)
		return;
	
	NSTimeInterval secondsSinceStart = -[startTime timeIntervalSinceNow];
	NSInteger minutesSinceStart = (int) (secondsSinceStart / 60);
	secondsSinceStart -= minutesSinceStart*60;
	
	timeLabel.text = [NSString stringWithFormat:(secondsSinceStart < 10 ? @"%d:0%#.3f": @"%d:%#.3f"),minutesSinceStart,secondsSinceStart];
	
}

- (void) stopRun {
	running = NO;
	
	[timeUpdateTimer invalidate];
	[timeUpdateTimer release];
	timeUpdateTimer = nil;
	
	infoLabel.text = @"Geschafft!";
	startButton.hidden = NO;
	timeLabel.hidden = YES;
	[UIDevice currentDevice].proximityMonitoringEnabled = NO;
	
	
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	
	NSTimeInterval secondsSinceStart = -[startTime timeIntervalSinceNow];
	NSTimeInterval highscore = [[NSUserDefaults standardUserDefaults] doubleForKey:[NSString stringWithFormat:MRHighscoreKey,targetDistance]];
	
	UIAlertView* alertView = nil;
	if (! highscore || (secondsSinceStart < highscore)) {
		
		AudioServicesPlaySystemSound(applauseSound);
		
		[[NSUserDefaults standardUserDefaults] setDouble:secondsSinceStart forKey:[NSString stringWithFormat:MRHighscoreKey,targetDistance]];
		
		alertView = [[UIAlertView alloc] initWithTitle:timeLabel.text
											   message:[NSString stringWithFormat:@"Neue Bestzeit für die %dm-Strecke!",targetDistance]
											  delegate:nil
									 cancelButtonTitle:nil
									 otherButtonTitles:@"Super!", nil];
		
	} else {
		AudioServicesPlaySystemSound(clapsSound);
		
		alertView = [[UIAlertView alloc] initWithTitle:timeLabel.text
											   message:[NSString stringWithFormat:@"Leider keine neue Bestzeit für die %dm-Strecke, es fehlen %.1f Sekunden.",targetDistance,secondsSinceStart-highscore]
											  delegate:nil
									 cancelButtonTitle:nil
									 otherButtonTitles:@"Schade", nil];
	}				
	[alertView show];
	[alertView release];
	
	
	
}


#pragma mark ---- Turning wheel ----

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	
	if (running)
		return;
	
	UITouch *touch = [touches anyObject];
	if ([pointerImage pointInside:[touch locationInView:pointerImage] withEvent:event]) {
		startAngle = currentAngle + [self calcWheelAngleOfPoint:[touch locationInView:nil]];
		
		turningWheel= YES;
	}
	
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if (turningWheel) {
		UITouch *touch = [touches anyObject];
		
		currentAngle = startAngle-[self calcWheelAngleOfPoint:[touch locationInView:nil]];
		
		pointerImage.transform = CGAffineTransformRotate(CGAffineTransformIdentity, currentAngle);
		
		NSInteger selectedSection = ((int) (MRDistanceWheelSteps+(-1*[self normalizeArc:currentAngle]/(2*M_PI)*MRDistanceWheelSteps+0.5)) % MRDistanceWheelSteps);
		

		
		if ((lastSelectedSection < selectedSection) || (lastSelectedSection == 0 && selectedSection == 12)) {
			if (targetDistance > MRMinDistance) {
				targetDistance -= (int) pow(10,((int) log10(targetDistance-1)));
				[self updateDistanceLabel];
			}
		} else if (lastSelectedSection > selectedSection)  {
			if (targetDistance < MRMaxDistance) {
				targetDistance += (int) pow(10,((int) log10(targetDistance)));
				[self updateDistanceLabel];
			}
		}
		lastSelectedSection = selectedSection;
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if (turningWheel) {
		turningWheel = NO;
		[[NSUserDefaults standardUserDefaults] setInteger:targetDistance forKey:MRTargetDistanceKey];
		
	}
}

- (double) normalizeArc:(double) arc {
    if (arc < 0)
		return [self normalizeArc:(arc + 2*M_PI)];
	else if (arc >= 2*M_PI) 
		return [self normalizeArc:(arc - 2*M_PI)];
	else return arc;
}

- (double) calcWheelAngleOfPoint:(CGPoint) point {
	
	point =  CGPointApplyAffineTransform(point, wheelTransform);
	double length = sqrt(point.x*point.x + point.y*point.y);
	point.x /= length;
	point.y /= length;
	
	double angle = acos(point.y);
	if (point.x < 0)
		angle = 2*M_PI-angle;
	
	return angle;
}

- (void) updateDistanceLabel {
	distanceLabel.text = [NSString stringWithFormat:@"%d m",targetDistance];
}


#pragma mark ---- Location Animation ----

- (void) startAnimatingCircle {
	circleImage.hidden = NO;
	[self animateCircle];
}
- (void) stopAnimatingCircle {
	circleImage.hidden = YES;
}

- (void) animateCircle {
	if (circleImage.hidden) // no animation if the circle is hidden
		return;
	
	AudioServicesPlaySystemSound(sonarSound);
	
	circleImage.transform = CGAffineTransformIdentity;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animateCircle)];
	
	
	circleImage.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.01, 0.01);
	
	[UIView commitAnimations];
	
}


@end
