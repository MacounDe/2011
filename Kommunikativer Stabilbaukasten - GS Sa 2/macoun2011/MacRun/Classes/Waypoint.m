//
//  Waypoint.m
//  MacRun
//
//  Created by Pascal Bihler on 23.09.11.
//  Copyright 2011 Universität Bonn. All rights reserved.
//

#import "Waypoint.h"

@interface Waypoint()
- (id)initWithLocation:(CLLocation *) location ;
@end

@implementation Waypoint

@synthesize coordinate,timestamp;

+ (id)waypointWithLocation:(CLLocation *)location {
    return [[[Waypoint alloc] initWithLocation:location] autorelease];
}

- (id)initWithLocation:(CLLocation *) location 
{
    self = [super init];
    if (self) {
        coordinate = location.coordinate;
        timestamp = [location.timestamp timeIntervalSince1970];
    }
    return self;
}


- (NSData *)dataForRequest {
    return [[NSString stringWithFormat:@"waypoint.latitude=%f&waypoint.longitude=%f&waypoint.timestamp=%0.f",coordinate.latitude,coordinate.longitude,timestamp] dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)contentTypeForRequest
{
    return @"application/x-www-form-urlencoded";
}

@end
