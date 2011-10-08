//
//  MCDocument.m
//  MacounDemo
//
//  Created by Frank Illenberger on 20.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MCDocument.h"
#import "MCNode.h"

@implementation MCDocument

@synthesize nodes       = nodes_;
@synthesize outlineView = outlineView_;

- (NSArray*)createNodes
{
    NSManagedObjectContext* moc = self.managedObjectContext;
    
    NSMutableArray* nodes = [[NSMutableArray alloc] init];
    for(NSUInteger index=0; index<10; index++)
    {
        MCNode* node = [NSEntityDescription insertNewObjectForEntityForName:@"Node"
                                                     inManagedObjectContext:moc];
        node.name = [NSString stringWithFormat:@"Knoten %ld", index];
        [nodes addObject:node];
        
        for(NSUInteger subIndex=0; subIndex<10; subIndex++)
        {
            MCNode* subNode = [NSEntityDescription insertNewObjectForEntityForName:@"Node"
                                                            inManagedObjectContext:moc];
            subNode.name = [NSString stringWithFormat:@"Knoten %ld.%ld", index, subIndex];
            [node addSubNodesObject:subNode];
        } 
    }
    return nodes;
}

- (id)init
{
    if (self = [super init]) 
    {
        self.nodes = [self createNodes];
    }
    return self;
}

- (NSString *)windowNibName
{
    return @"MCDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
}

- (NSPrintOperation *)printOperationWithSettings:(NSDictionary *)printSettings error:(NSError **)outError
{
    return [NSPrintOperation printOperationWithView:outlineView_.superview.superview];
}

- (NSArray*)sortDescriptors
{
    NSSortDescriptor* desc = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    return [NSArray arrayWithObject:desc];
}
@end
