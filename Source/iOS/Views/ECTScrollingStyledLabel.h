// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 18/10/2011
//
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

@class ECTStyledLabel;
@class ECTScrollView;

@interface ECTScrollingStyledLabel : UIView

@property (strong, nonatomic) ECTStyledLabel* label;
@property (strong, nonatomic) ECTScrollView* scroller;

- (NSAttributedString*)attributedText;
- (void)setAttributedText:(NSAttributedString*)text;

@end
