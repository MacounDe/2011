//
//  RootViewController.h
//  Macoun Gurke 1
//
//  Created by norbert D. on 20.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropboxSDK.h"

@interface RootViewController : UITableViewController <DBRestClientDelegate, DBLoginControllerDelegate>
{
	NSArray			*mLocalFilesArray;
	NSString			*documentsPath;

	DBRestClient		*restClient;
}
@end
