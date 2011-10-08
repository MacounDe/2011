//
//  ServerConnection.m
//  MacRun
//
//  Created by Pascal Bihler on 15.09.11.
//  Copyright 2011 Universität Bonn. All rights reserved.
//

#import "ServerConnection.h"

NSString * const MRBaseUrl = @"http://localhost:9000";

@implementation ServerConnection

@synthesize delegate;

- (id) initWithDelegate:(id<ServerConnectionDelegate>)theDelegate
{
    self = [super init];
    if (self) {
        delegate = theDelegate;
        
        [[LRResty client] setGlobalTimeout:5.0 handleWithBlock:^(LRRestyRequest *request){
            NSLog(@"Timeout");
            if (request.numberOfRetries < 5) {
                [request retry];
            }
        }];
    }
    
    return self;
}


- (void)restClient:(LRRestyClient *)client receivedResponse:(LRRestyResponse *)response;
{
    if(response.status == 200) {
        NSLog(@"Successful response: %@",[response asString]);
    } else if (response.status == 401) {
        [delegate connectionFailed:@"Benutzername / Kennwort falsch"];
    } else if (response.status == 403) {
        [delegate connectionFailed:@"Zugriff nicht erlaubt"];
    } else {
        NSLog(@"Error response %d, %@",response.status, [response asString]);
        [delegate connectionFailed:@"Allgemeiner Serverfehler"];
    }

}


- (void)restClient:(LRRestyClient *)client request:(LRRestyRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Error: %@",error);
    [delegate connectionFailed:[error localizedDescription]];
}





@end
