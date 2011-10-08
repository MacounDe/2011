//
//  NDFileListController.m
//  Macoun Bonjour Demo
//
//  Created by norbert D. on 26.09.11.
//  Copyright 2011 West-Forest-Systems. All rights reserved.
//

#import "NDFileListController.h"

@implementation NDFileListController

- (id)init
{
	self = [super initWithWindowNibName:@"NDFileListController"];
	return self;
}

#pragma mark Connection Delegate Methoden
- (void)connectionAttemptFailed:(Connection*)connection
{
	NSLog (@"connectionAttemptFailed!");
}

- (void)connectionTerminated:(Connection*)connection
{
	NSLog (@"connectionTerminated!");
	[connection release];
	myConnection = nil;
}

- (void)receivedNetworkPacket:(NSDictionary*)packet viaConnection:(Connection*)connection 
{
	NSArray	*neueDateiListe = [packet objectForKey:@"liste"];

	if (neueDateiListe != nil)		// Liste angekommen
	{
		dateiListe = [[neueDateiListe mutableCopy] retain];
		[dateiListView reloadData];
	}
}

// lade eine Liste aller bekannten Dateien vom iOS-Gerät
- (void)dateiListeHolen
{
	[dateiListe removeAllObjects];
	[dateiListe release];

	if (myConnection == nil)
	{
		myConnection = [[Connection alloc] initWithNetService:theService];
		[myConnection setDelegate:self];
		[myConnection connect];
	}
	[myConnection sendNetworkPacket:[NSDictionary dictionaryWithObject:@" " forKey:@"liste"]];
}  //  dateiListeHolen

// lade die Datei hoch
- (void)dateiHochladen:(NSString *)path
{
	NSData			*fileData = [NSData dataWithContentsOfFile:path];
	NSString		*fileName = [path lastPathComponent];

	if (myConnection == nil)
	{
		myConnection = [[Connection alloc] initWithNetService:theService];
		[myConnection setDelegate:self];
		[myConnection connect];
	}

	NSMutableDictionary		*dict = [[NSMutableDictionary dictionary] autorelease];
	[dict setObject:fileName forKey:@"name"];
	[dict setObject:fileData	forKey:@"datei"];
	[myConnection sendNetworkPacket:dict];
}  //  dateiHochladen

// Bonjour konnte den Dienst doch nicht finden...
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
	NSLog (@"didNotResolve");
}

// Bonjour hat den DNS-Namen des Services aufgelöst, wir können jetzt verbinden
- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
	[self dateiListeHolen];
}

- (void)verbindeMitService:(NSNetService *)service
{
	[[self window] makeKeyAndOrderFront:self];
	theService = [service retain];
	[theService setDelegate:self];
	
	[theService resolveWithTimeout:5.0];
}  //  verbindeMitService

// wähle eine Datei aus und lade sie zum iOS Gerät hoch
- (IBAction)selectFile:(id)sender
{
	NSOpenPanel			*myPanel = [NSOpenPanel openPanel];

	[myPanel setCanChooseDirectories:NO];
	[myPanel setCanChooseFiles:YES];
	[myPanel setAllowsMultipleSelection:NO];
	[myPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"neofinder", nil]];
	if ([myPanel runModal] == NSFileHandlingPanelOKButton)
	{
		NSArray			*selectedFiles = [myPanel filenames];
		
		for (NSString *onePath in selectedFiles)
		{
			[self dateiHochladen:onePath];
		}
	}
}  //  selectFile

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [dateiListe count];
}  //  numberOfRowsInTableView

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	return [dateiListe objectAtIndex:rowIndex];
}  //  objectValueForTableColumn

@end
