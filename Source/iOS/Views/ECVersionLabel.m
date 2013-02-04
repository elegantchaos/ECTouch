// --------------------------------------------------------------------------
//! @author Sam Deane
//
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECVersionLabel.h"

@implementation ECVersionLabel

- (void)setVersion
{
    self.text = [[UIApplication sharedApplication] aboutShortVersion];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]) != nil)
    {
        [self setVersion];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]) != nil)
    {
        [self setVersion];
    }
    
    return self;
}

@end
