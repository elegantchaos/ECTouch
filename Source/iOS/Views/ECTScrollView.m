// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 05/07/2011
//
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECTScrollView.h"

#import <objc/message.h>

#pragma mark - Constants


@implementation ECTScrollView

#pragma mark - Channels

ECDefineDebugChannel(ECTScrollViewChannel);

#pragma mark - Properties

@synthesize action;
@synthesize swallowTouches;
@synthesize target;

-(void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event 
{	
    if (!self.dragging)
    {
        // drop the touchesEnded call through to the responder chain?
        if (!self.swallowTouches)
        {
            [self.nextResponder touchesEnded: touches withEvent:event]; 
        }		
        
        // perform custom action?
        if (self.target && self.action)
        {
            objc_msgSend(self.target, self.action, event);
        }
    }
    
	[super touchesEnded: touches withEvent: event];
}

@end
