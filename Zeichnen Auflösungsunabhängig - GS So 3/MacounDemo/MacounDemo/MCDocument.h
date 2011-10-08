//
//  MCDocument.h
//  MacounDemo
//
//  Created by Frank Illenberger on 20.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MCDocument : NSPersistentDocument

@property (copy)             NSArray*        nodes;
@property (assign)  IBOutlet NSOutlineView*  outlineView;

@end
