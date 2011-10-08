//
//  MCDocument.m
//  ImageTest
//
//  Created by Frank Illenberger on 21.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MCDocument.h"

@implementation MCDocument
@synthesize view;

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        // If an error occurs here, return nil.
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MCDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
}


+ (BOOL)autosavesInPlace
{
    return YES;
}

@end
