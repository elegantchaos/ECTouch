// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 05/07/2011
//
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

// --------------------------------------------------------------------------
//! UIScrollView with some extra properties
// --------------------------------------------------------------------------

@interface ECTScrollView : UIScrollView

@property (assign, nonatomic) BOOL swallowTouches;
@property (assign, nonatomic) SEL action;
@property (assign, nonatomic) id target;

@end
