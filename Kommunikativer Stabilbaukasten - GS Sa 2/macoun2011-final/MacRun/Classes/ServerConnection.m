//
//  ServerConnection.m
//  MacRun
//
//  Created by Pascal Bihler on 15.09.11.
//  Copyright 2011 Universität Bonn. All rights reserved.
//

#import "ServerConnection.h"
#import "NSData+RSA.h"
#import "NSData+AES128.h"
#import "NSData+Base64Encoding.h"

NSString * const MRBaseUrl = @"http://localhost:9000";

@interface ServerConnection()
- (NSData *) generateRandomDataWithLength:(int) length;
@end

@implementation ServerConnection

@synthesize delegate;

- (id) initWithDelegate:(id<ServerConnectionDelegate>)theDelegate
{
    self = [super init];
    if (self) {
        delegate = theDelegate;
        
        // generate dynamic AES encryption key
		symmetricKey = [[self generateRandomDataWithLength:16] retain];
        
        [[LRResty client] setGlobalTimeout:5.0 handleWithBlock:^(LRRestyRequest *request){
            NSLog(@"Timeout");
            if (request.numberOfRetries < 5) {
                [request retry];
            }
        }];
    }
    
    return self;
}

-(void) dealloc {
    [symmetricKey release];
	[token release];
    
	[super dealloc];
}

- (void)restClient:(LRRestyClient *)client receivedResponse:(LRRestyResponse *)response;
{
    if(response.status == 200) {
        NSLog(@"Successful response: %@",[response asString]);
        if (! token) { // connection response
            token = [[NSString alloc] initWithData:[[NSData dataWithBase64EncodedString:[response asString]] AES128DecryptWithKey:symmetricKey] encoding:NSUTF8StringEncoding];
        }
    } else if (response.status == 401) {
        [delegate connectionFailed:@"Benutzername / Kennwort falsch"];
          [token release]; token = nil; // invalidate connection token
    } else if (response.status == 403) {
        [delegate connectionFailed:@"Zugriff nicht erlaubt"];
              [token release]; token = nil; // invalidate connection token
    } else {
        NSLog(@"Error response %d, %@",response.status, [response asString]);
        [delegate connectionFailed:@"Allgemeiner Serverfehler"];
              [token release]; token = nil; // invalidate connection token
    }

}


- (void)restClient:(LRRestyClient *)client request:(LRRestyRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Error: %@",error);
    [delegate connectionFailed:[error localizedDescription]];
    if (! token) {
        [delegate loginFailed:[error localizedDescription]];
    }
}

- (void) sendWaypoint:(Waypoint *) waypoint {
    if (! token) 
        return;
    
    [[LRResty client] post:[NSString stringWithFormat:@"%@/%@/waypoints/new",MRBaseUrl,token] payload:waypoint delegate:self];
}

- (void) loginWithUsername:(NSString *) username passwordHash:(NSString *) passwordHash {
    
    //Encode the symmetric key with the server's public key
    NSString * path = [[NSBundle mainBundle] pathForResource:@"encryption" ofType:@"cer"];
    NSData * encryptedKey = [symmetricKey encryptWithKeyFromCert:path];
    
    NSData * encodedUsername = [[username dataUsingEncoding:NSUTF8StringEncoding] AES128EncryptWithKey:symmetricKey];
    
    NSDictionary * payload = [NSDictionary dictionaryWithObjectsAndKeys:[encodedUsername base64Encoding],@"username",
                              passwordHash,@"passwordHash",
                              [encryptedKey base64Encoding],@"key",
                              nil];
    [[LRResty client] post:[NSString stringWithFormat:@"%@/connect",MRBaseUrl] payload:payload delegate:self];
}

#define RKRandom(x) (arc4random() % ((NSUInteger)(x) + 1))		//!< Nice random method
- (NSData *) generateRandomDataWithLength:(int) length {
    char bytes[length]; 
    for (int i=0; i<length; i++) {
		bytes[i] = (char)(RKRandom(256-32)+32);
	}
	return [NSData dataWithBytes:bytes length:length];
}


@end
