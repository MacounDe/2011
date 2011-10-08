//
//  ServerConnection.h
//  MacRun
//
//  Created by Pascal Bihler on 15.09.11.
//  Copyright 2011 Universität Bonn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LRResty/LRResty.h>
#import "Waypoint.h"

@protocol ServerConnectionDelegate<NSObject>

- (void) connectionFailed:(NSString*) reason;

@end

@interface ServerConnection : NSObject<LRRestyClientResponseDelegate> {
    id<ServerConnectionDelegate> delegate;
        NSString * token;
    	NSData * symmetricKey; 		//!< Dynamically generated key for AES encryption
}
@property(readonly) id<ServerConnectionDelegate> delegate;

- (id) initWithDelegate:(id<ServerConnectionDelegate>)theDelegate;
- (void) sendWaypoint:(Waypoint *) waypoint;
- (void) loginWithUsername:(NSString *) username passwordHash:(NSString *) passwordHash;
@end
