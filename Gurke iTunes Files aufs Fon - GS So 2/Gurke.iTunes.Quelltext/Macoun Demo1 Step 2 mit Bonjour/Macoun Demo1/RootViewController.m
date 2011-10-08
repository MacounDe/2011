//
//  RootViewController.m
//  Macoun Gurke 1
//
//  Created by norbert D. on 20.09.11.
//  Copyright 2011 West-Forest-Software. All rights reserved.
//

#import "RootViewController.h"

#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>

@implementation RootViewController

#define kMacounDemoServicesTypeIdentifier		@"_gurken._tcp"

@synthesize mLocalFilesArray;

- (void) updateFiles 
{
	[mLocalFilesArray release];
	mLocalFilesArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:nil];
	[mLocalFilesArray retain];
}

// passend etwa beim Programmende aufrufen
- (void)bonjourBeenden 
{
	if (syncNetService != nil)
	{
		[syncNetService stop];
		[syncNetService removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
		syncNetService = nil;
	}
}  //  bonjourBeenden

// ebenso, etwa beim Programmende, den Socket schließen!
- (void) serverBeenden
{
	if (listeningSocket != nil) 
	{
		CFSocketInvalidate(listeningSocket);
		CFRelease(listeningSocket);
		listeningSocket = nil;
	}
}  //  serverBeenden


#pragma mark Connection Delegate Methoden
- (void) connectionAttemptFailed:(Connection*)connection
{
	NSLog (@"connectionAttemptFailed!");
}

- (void) connectionTerminated:(Connection*)connection
{
	NSLog (@"connectionTerminated!");
	[connection release];
}

- (void) receivedNetworkPacket:(NSDictionary*)packet viaConnection:(Connection*)connection 
{
	if ([packet objectForKey:@"liste"] != nil)
	{
		// Dateiliste zurückschicken
		[connection sendNetworkPacket:[NSDictionary dictionaryWithObject:mLocalFilesArray forKey:@"liste"]];
		return;
	}
	if ([packet objectForKey:@"datei"] != nil)
	{
		// Datei mit dem Namen speichern
		NSString		*dateiName = [packet objectForKey:@"name"];
		NSData			*dateiInhalt = [packet objectForKey:@"datei"];
		
		[dateiInhalt writeToFile:[documentsPath stringByAppendingPathComponent:dateiName] atomically:YES];
		[self updateFiles];
		[self.tableView reloadData];
		// aktualisierte Dateiliste zurückschicken
		[connection sendNetworkPacket:[NSDictionary dictionaryWithObject:mLocalFilesArray forKey:@"liste"]];
		return;
	}
}  //  receivedNetworkPacket


- (void)addConnection:(Connection *)newConnection
{
	[newConnection setDelegate:self];
}  //  addConnection

// wenn jemand mit uns sprechen will...
static void serverAcceptCallback(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) 
{
	RootViewController			*myViewController = (RootViewController *)info;
	
	if (type != kCFSocketAcceptCallBack) 
		return;
	
	CFSocketNativeHandle nativeSocketHandle = *(CFSocketNativeHandle*)data;
	Connection* connection = [[Connection alloc] initWithNativeSocketHandle:nativeSocketHandle];
	if (connection == nil) 
	{
		close(nativeSocketHandle);
		return;
	}
	
	if ([connection connect] == NO) 
	{
		[connection close];
		return;
	}
	// dem viewController Bescheid sagen, daß da eine neue Verbindung ist
	[myViewController addConnection:connection];
}  //  serverAcceptCallback

#pragma mark Anfang
// der Button wurde gedrückt, starten wir die Server-Dienste und Bonjour dazu
- (void)didPressBonjourButton 
{
	// Socket anlegen und öffnen
	CFSocketContext socketCtxt = {0, self, NULL, NULL, NULL};	// link auf "self" ist wichtig!
	
	listeningSocket = CFSocketCreate (kCFAllocatorDefault,
						   PF_INET,			// IPv4
						   SOCK_STREAM,    // der Socket soll Streaming sein
						   IPPROTO_TCP,    // wir wollen TCP
						   kCFSocketAcceptCallBack,
						   (CFSocketCallBack)&serverAcceptCallback,
						   &socketCtxt);
	if (listeningSocket == NULL)
		return;
	
    // Socket Adresse wiederverwenden
	int existingValue = 1;
	setsockopt (CFSocketGetNative (listeningSocket), SOL_SOCKET, SO_REUSEADDR, (void *)&existingValue, sizeof(existingValue));
	
	struct sockaddr_in socketAddress;
	memset (&socketAddress, 0, sizeof (socketAddress));
	socketAddress.sin_len = sizeof (socketAddress);
	socketAddress.sin_family = AF_INET;   // IPv4
	socketAddress.sin_port = 0;           // uns ist egal, welchen Port wir bekommen
	socketAddress.sin_addr.s_addr = htonl(INADDR_ANY);
	NSData *socketAddressData = [NSData dataWithBytes:&socketAddress length:sizeof(socketAddress)];

	// das macht das "bind"
	if (CFSocketSetAddress (listeningSocket, (CFDataRef)socketAddressData) != kCFSocketSuccess)
	{
		if (listeningSocket != NULL)
		{
			CFRelease (listeningSocket);
			listeningSocket = NULL;
		}
		return;
	}

	// welche PortNummer haben wir bekommen?
	NSData *socketAddressActualData = [(NSData *)CFSocketCopyAddress (listeningSocket) autorelease];
	struct sockaddr_in *socketAddressActual = (struct sockaddr_in *)[socketAddressActualData bytes];
	port = ntohs (socketAddressActual->sin_port);

	// den CFSocket in die RunLoop hängen
	CFRunLoopRef currentRunLoop = CFRunLoopGetCurrent();
	CFRunLoopSourceRef runLoopSource = CFSocketCreateRunLoopSource (kCFAllocatorDefault, listeningSocket, 0);
	CFRunLoopAddSource (currentRunLoop, runLoopSource, kCFRunLoopCommonModes);
	CFRelease (runLoopSource);

	// Bonjour Bescheid sagen, daß wir einen Dienst anbieten
	syncNetService = [[NSNetService alloc] initWithDomain:@"" type:kMacounDemoServicesTypeIdentifier name:@"" port:port];
	[syncNetService scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	[syncNetService setDelegate:self];
	[syncNetService publish];
}  //  didPressBonjourButton

- (void)viewDidLoad 
{
	[super viewDidLoad];
	
	UIBarButtonItem		*dbButton = [UIBarButtonItem alloc];
	
	[dbButton initWithTitle:@"Bonjour" style:UIBarButtonItemStylePlain target:self action:@selector(didPressBonjourButton)];
	[dbButton autorelease];
	self.navigationItem.rightBarButtonItem = dbButton;	

	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	if ([paths count] > 0) 
	{
		documentsPath = [[paths objectAtIndex:0] copy];
	} 
	[self updateFiles];
}

/*
- (void)applicationWillTerminate:(UIApplication *)application
{
	[syncNetService stop];
	[syncNetService release];
}
 */

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [mLocalFilesArray count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) 
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	
	// Configure the cell.
	NSString *filename = [mLocalFilesArray objectAtIndex:indexPath.row];
	cell.textLabel.text = filename;
	return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete)
 {
 // Delete the row from the data source.
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert)
 {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
	 // ...
	 // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	// Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
	// For example: self.myOutlet = nil;
}

- (void)dealloc
{
	[mLocalFilesArray release];
	[super dealloc];
}

@end
