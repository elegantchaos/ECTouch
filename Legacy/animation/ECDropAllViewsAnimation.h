// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 12/04/2011
//
//  Copyright 2011 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import <UIKit/UIKit.h>

@interface ECDropAllViewsAnimation : NSObject 
{

}

+ (void) dropViewsIntoView: (UIView*) view withDuration: (NSTimeInterval) duration ignoreTag: (NSInteger) tagToIgnore;

+ (void) slideViewsIntoView: (UIView*) view withDuration: (NSTimeInterval) duration ignoreTag: (NSInteger) tagToIgnore;

@end
