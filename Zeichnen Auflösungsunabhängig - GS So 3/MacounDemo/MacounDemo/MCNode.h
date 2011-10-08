//
//  MCNode.h
//  MacounDemo
//
//  Created by Frank Illenberger on 20.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MCNode;

@interface MCNode : NSManagedObject

@property (nonatomic, retain) NSString*         name;
@property (nonatomic, retain) NSOrderedSet*     subNodes;
@property (nonatomic, retain) MCNode*           parentNode;
@end

@interface MCNode (CoreDataGeneratedAccessors)
- (void)addSubNodesObject:(MCNode *)value;
- (void)removeSubNodesObject:(MCNode *)value;
@end
