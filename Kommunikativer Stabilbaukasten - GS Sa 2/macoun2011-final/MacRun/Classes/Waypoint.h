//
//  Waypoint.h
//  MacRun
//
//  Created by Pascal Bihler on 23.09.11.
//  Copyright 2011 Universität Bonn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LRResty/LRResty.h>

@interface Waypoint : NSObject<LRRestyRequestPayload> {
    CLLocationCoordinate2D coordinate;
    NSTimeInterval timestamp;
}
@property(readonly) CLLocationCoordinate2D coordinate;
@property(readonly) NSTimeInterval timestamp;

+ (id)waypointWithLocation:(CLLocation *) location;

@end
