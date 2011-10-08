//
//  Macoun_Bonjour_DemoAppDelegate.h
//  Macoun Bonjour Demo
//
//  Created by norbert D. on 26.09.11.
//  Copyright 2011 West-Forest-Systems. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/NSNetServices.h>
#import "NDFileListController.h"

@interface Macoun_Bonjour_DemoAppDelegate : NSObject <NSApplicationDelegate, NSNetServiceDelegate, NSNetServiceBrowserDelegate>
{
	NSWindow				*window;
	IBOutlet NSTableView	*bonjourListView;
	IBOutlet NSButton		*verbindenButton;
	IBOutlet NSProgressIndicator *bonjourProgress;

	NSMutableArray		*services;
	NSNetServiceBrowser	*netServiceBrowser;
	NSNetService			*currentResolve;
	NSTimer				*timer;
	
	NDFileListController	*dateiLister;
}

- (IBAction)verbinden:(id)sender;

@property (assign) IBOutlet NSWindow *window;

@end
