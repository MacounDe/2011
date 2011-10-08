//
//  RootViewController.h
//  Macoun Gurke 1
//
//  Created by norbert D. on 20.09.11.
//  Copyright 2011 West-Forest-Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Connection.h"

@interface RootViewController : UITableViewController <NSNetServiceDelegate, ConnectionDelegate>
{
	NSArray			*mLocalFilesArray;
	NSString			*documentsPath;
	
	NSNetService		*syncNetService;
	CFSocketRef		listeningSocket;
	uint16_t			port;
	
	Connection			*networkConnection;
}

@property (assign) NSArray *mLocalFilesArray;

- (void)addConnection:(Connection *)newConnection;
@end
