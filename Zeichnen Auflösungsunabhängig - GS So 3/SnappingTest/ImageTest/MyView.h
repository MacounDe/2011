//
//  MyView.h
//  ImageTest
//
//  Created by Frank Illenberger on 22.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MyView : NSView

@property BOOL    drawsWithSnapping;
@property BOOL    animatesLineWidth;
@property BOOL    animatesPosition;
@property BOOL    animatesSize;

@property CGFloat lineWidth;
@property CGFloat posX;
@property CGFloat posY;
@property CGFloat boxSize;

- (IBAction)startAnimation:(id)sender;

@end
