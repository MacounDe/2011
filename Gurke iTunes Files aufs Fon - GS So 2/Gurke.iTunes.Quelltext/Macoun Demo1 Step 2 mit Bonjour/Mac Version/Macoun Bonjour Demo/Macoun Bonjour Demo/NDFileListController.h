//
//  NDFileListController.h
//  Macoun Bonjour Demo
//
//  Created by norbert D. on 26.09.11.
//  Copyright 2011 West-Forest-Systems. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/NSNetServices.h>
#import "Connection.h"

@interface NDFileListController : NSWindowController <NSStreamDelegate, NSNetServiceDelegate, ConnectionDelegate>
{
	IBOutlet NSTableView	*dateiListView;
	IBOutlet NSButton		*hochadenButton;

	NSMutableArray		*dateiListe;

	NSNetService			*theService;
	Connection				*myConnection;
}
- (IBAction)selectFile:(id)sender;

- (void)verbindeMitService:(NSNetService *)service;
@end
