//
//  RootViewController.m
//  Macoun Gurke 1
//
//  Created by norbert D. on 20.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "DropboxSDK.h"

@implementation RootViewController


- (void) updateFiles 
{
	[mLocalFilesArray release];
	mLocalFilesArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:nil];
	[mLocalFilesArray retain];
}

- (DBRestClient*)restClient 
{
	if (restClient == nil) 
	{
		restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
		restClient.delegate =  self;
	}
	return restClient;
}

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)localPath 
{
//	NSLog(@"File loaded into path: %@", localPath);
	[self updateFiles];
	[self.tableView reloadData];	// Holzhammer, reicht für Demo, ist aber ineffizient
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error 
{
	NSLog(@"There was an error loading the file - %@", error);
}

- (void)syncDropboxPaths:(NSArray *)dbPaths
{
	for (NSString *onePath in dbPaths)
	{
		// wenn der Dateiname NICHT in mLocalFileArray enthalten ist, HERUNTERLADEN! :-)
		NSString		*oneFileName = [onePath lastPathComponent];
		if ([mLocalFilesArray indexOfObject:oneFileName] == NSNotFound)
		{
			[self.restClient loadFile:onePath intoPath:[documentsPath stringByAppendingPathComponent:oneFileName]];
		}
	}
}  //  syncDropboxPaths

#pragma mark DBRestClientDelegate methods

- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata 
{
	NSArray* validExtensions = [NSArray arrayWithObjects:@"neofinder", nil];
	NSMutableArray* newPaths = [NSMutableArray new];
	for (DBMetadata* child in metadata.contents) 
	{
		if (child.isDirectory == NO)		// für die Demo ignorieren wir Ordner
		{
			NSString* extension = [[child.path pathExtension] lowercaseString];
			if ([validExtensions indexOfObject:extension] != NSNotFound) 
				[newPaths addObject:child.path];
		}
	}
	[self syncDropboxPaths:newPaths];
}  //  loadedMetadata

- (void)restClient:(DBRestClient*)client metadataUnchangedAtPath:(NSString*)path 
{
	NSLog(@"restClient: metadataUnchangedAtPath %@", path);
}

- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error 
{
	NSLog(@"restClient:loadMetadataFailedWithError: %@", [error localizedDescription]);
}

#pragma mark end of DBRestClientDelegate methods

- (void)loadFileListFromDropbox
{
	[self.restClient loadMetadata:@"/NeoFinder" withHash:nil];
}

- (void)loginControllerDidCancel:(DBLoginController*)controller
{
	NSLog (@"loginControllerDidCancel");
}

// Verbindung zu DropBox war erfolgreich, Verbindung steht
- (void)loginControllerDidLogin:(DBLoginController*)controller
{
	[self loadFileListFromDropbox];
}

#pragma mark Anfang
- (void)didPressLink 
{
	// wenn die DropBox API schon verbunden ist, geht es direkt weiter zum Laden der Datei-Infos
	if ([[DBSession sharedSession] isLinked] == YES)
	{
		[self loadFileListFromDropbox];
		return;
	}
	// sonst muß sich der Benutzer mit Email und Passwort authentifizieren
	DBLoginController* controller = [[DBLoginController new] autorelease];
	controller.delegate = self;
	[controller presentFromController:self];
	// das ruft loginControllerDidLogin oder loginControllerDidCancel auf
}

- (void)viewDidLoad 
{
	[super viewDidLoad];
	
	// DropBox Button in die Navigationsleiste UINavigationBar hinzufügen:
	
	UIBarButtonItem		*dbButton = [UIBarButtonItem alloc];
	
	[dbButton initWithTitle:@"DropBox" style:UIBarButtonItemStylePlain target:self action:@selector(didPressLink)];
	[dbButton autorelease];
	self.navigationItem.rightBarButtonItem = dbButton;	
	
	
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	if ([paths count] > 0) 
	{
		documentsPath = [[paths objectAtIndex:0] copy];
	} 
	[self updateFiles];
}

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
