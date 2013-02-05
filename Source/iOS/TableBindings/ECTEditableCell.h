// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 02/09/2011
//
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECTSimpleCell.h"

@interface ECTEditableCell : ECTSimpleCell<UITextFieldDelegate>

@property (strong, nonatomic) UILabel* label;
@property (strong, nonatomic) UITextField* text;

@end
