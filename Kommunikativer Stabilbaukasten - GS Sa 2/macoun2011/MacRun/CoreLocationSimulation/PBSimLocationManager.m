/*
 *  PBSimLocationManager.m
 *
 *  Created by Pascal Bihler on 13.08.08.
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

#import "PBSimLocationManager.h"
#include <time.h>

#import "tm.h"
#import "nmea.h"


@interface PBSimLocationManager ()
- (time_t) getGNMEADataTime;
- (BOOL) readNextNmeaLine;
@end


@implementation PBSimLocationManager

@synthesize simulationSpeedup;



#pragma mark ---- initialisations ----


- (id) initWithNMEAFile:(NSString *) path {
	return [self initWithNMEAFile:path speedup:1];
}
- (id) initWithNMEAFile:(NSString *) path speedup:(double) speedup {
	self = [super init];
	if (self) {
		//Load NMEA-Data from file
        NSError * error;
		NSString *fileString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error]; // reads file into memory as an NSString
		nmeaLines = [[fileString componentsSeparatedByString:@"\n"] retain]; // each line, adjust character for line endings

		if (speedup <= 0)
			speedup = 1;
		simulationSpeedup = speedup;
	}
	
	return self;	
}


#pragma mark ---- overwrite parent methods ----

+ (BOOL) locationServicesEnabled {
    return YES;
}

- (void)startUpdatingHeading {
	[NSException raise:@"Not implemented" format:@"Heading methods not implemented in PBSimLocationManager"];
}
- (void)stopUpdatingHeading {
	[NSException raise:@"Not implemented" format:@"Heading methods not implemented in PBSimLocationManager"];
}

- (void) startUpdatingLocation {
	if (! [CLLocationManager locationServicesEnabled]) {
		UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Location Sensing disabled"
											   message:@"Please activate location sensing in Settings -> General."
											  delegate:nil
									 cancelButtonTitle:nil
									 otherButtonTitles:@"OK", nil];
		[alertView show];
		[alertView release];
		return;
	}
	
	// start timer to playback
	if (! timer) {
		
		// Init processing
		fileNotEnded = YES;
		nmeaStartTime = [self getGNMEADataTime];
		
		while (nmeaStartTime == -1 && fileNotEnded) {
			fileNotEnded = [self readNextNmeaLine];			
			nmeaStartTime = [self getGNMEADataTime];
		}
		
		timeDelta = time(NULL) - nmeaStartTime;
		
		if (fileNotEnded) {
			timer = [NSTimer scheduledTimerWithTimeInterval:1 
												 target:self 
											   selector:@selector(callFromTimer:) 
											   userInfo:nil 
												repeats:YES];
		}
	}
	
}
- (void) stopUpdatingLocation {
	[timer invalidate];
	[timer release];
	timer = nil;	
}

- (CLLocation *) location {
	return location;
}


#pragma mark ---- Process NMEA file: ----

- (time_t) getGNMEADataTime {
	if (gNMEAdata.year != 0) {
		struct tm t;
		t.tm_year = gNMEAdata.year - 1900;
		t.tm_mon = gNMEAdata.month;
		t.tm_mday = gNMEAdata.day;
		t.tm_hour = gNMEAdata.hours;
		t.tm_min = gNMEAdata.minutes;
		t.tm_sec = gNMEAdata.seconds;
		t.tm_isdst = 0;
		
		return mktime(&t);
	}
	return -1;
}

- (void) callFromTimer:(NSTimer *)t {	
	
	BOOL updated = NO;
	
	while ((([self getGNMEADataTime]-nmeaStartTime)/simulationSpeedup + nmeaStartTime + timeDelta <= time(NULL)) && fileNotEnded ) {
		if (coordinate.latitude != gNMEAdata.latitude) {
			coordinate.latitude = gNMEAdata.latitude;
			updated = YES;
		}
		if (coordinate.longitude != gNMEAdata.longitude) {
			coordinate.longitude = gNMEAdata.longitude;
			updated = YES;
		}
		fileNotEnded = [self readNextNmeaLine];
	}
	
	
	if (updated) { // Position was updated
		
		CLLocationAccuracy horizontalAccuracy = gNMEAdata.hdop * gNMEAdata.pdop;
		CLLocationAccuracy verticalAccuracy = gNMEAdata.vdop * gNMEAdata.pdop;
		NSDate * timestamp = [NSDate dateWithTimeIntervalSince1970:[self getGNMEADataTime]];
		CLLocation * newLocation =  [[CLLocation alloc] initWithCoordinate:coordinate altitude:gNMEAdata.altitude horizontalAccuracy:horizontalAccuracy verticalAccuracy:verticalAccuracy timestamp:timestamp];
		
		if (! location || (self.distanceFilter == kCLDistanceFilterNone) || ([location distanceFromLocation:newLocation] > self.distanceFilter)) {
			
			[oldLocation release];
			oldLocation = location;
			
			location = [newLocation retain];
			
			//Call Callback selector
			if ([self.delegate respondsToSelector:@selector(locationManager:didUpdateToLocation:fromLocation:)])
				[self.delegate locationManager:self didUpdateToLocation:location fromLocation:oldLocation];
			
		}
		[newLocation release];
		
	}

}

- (void)dealloc {
	[oldLocation release];
	[location release];
    [nmeaLines release];
	[timer release];
	[super dealloc];
}

- (BOOL) readNextNmeaLine {
	static int lineCounter=0;
	if (lineCounter < [nmeaLines count]) {
		
		NSString *line = [[nmeaLines objectAtIndex:lineCounter] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		handle_message([line UTF8String]);
		
		lineCounter++;
		return YES;
	} 
	return NO;
}

@end
