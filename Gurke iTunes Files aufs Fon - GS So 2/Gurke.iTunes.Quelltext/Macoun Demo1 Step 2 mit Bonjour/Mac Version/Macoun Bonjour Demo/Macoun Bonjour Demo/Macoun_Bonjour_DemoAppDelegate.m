//
//  Macoun_Bonjour_DemoAppDelegate.m
//  Macoun Bonjour Demo
//
//  Created by norbert D. on 26.09.11.
//  Copyright 2011 West-Forest-Systems. All rights reserved.
//

#import "Macoun_Bonjour_DemoAppDelegate.h"

#define kMacounDemoServicesTypeIdentifier		@"_gurken._tcp"

@implementation Macoun_Bonjour_DemoAppDelegate

@synthesize window;


- (void)sortAndUpdateUI 
{
	// Sort the services by name.
	[services sortUsingSelector:@selector(compare:)];
	[bonjourListView reloadData];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing
{
	[services addObject:netService];
	if (moreServicesComing == NO)
		[self sortAndUpdateUI];	
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didRemoveService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing
{
	[services removeObject:netService];
	if (moreServicesComing == NO)
		[self sortAndUpdateUI];
}

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)netServiceBrowser
{
	[bonjourProgress startAnimation:self];
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)netServiceBrowser
{
	[bonjourProgress stopAnimation:self];	
}

#pragma mark Programmstart
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	services = [[NSMutableArray alloc] init];
	// nach Bonjour Knoten suchen:
	
	netServiceBrowser = [[NSNetServiceBrowser alloc] init];
	[netServiceBrowser setDelegate:self];
	[netServiceBrowser searchForServicesOfType:kMacounDemoServicesTypeIdentifier inDomain:@""];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	[netServiceBrowser stop];
	[netServiceBrowser release];
}

#pragma mark Verbindung zum gewaehlten Service herstellen
- (IBAction)verbinden:(id)sender 
{
	NSNetService		*selectedService = [services objectAtIndex:[bonjourListView selectedRow]];
	
	dateiLister = [[NDFileListController alloc] init];
	[dateiLister window];
	[dateiLister verbindeMitService:selectedService];
	[netServiceBrowser stop];	// damit der nicht endlos weiter rödelt
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [services count];
}  //  numberOfRowsInTableView

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	return [[services objectAtIndex:rowIndex] name];
}  //  objectValueForTableColumn

@end
