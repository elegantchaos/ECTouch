// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 26/07/2010
//
//  Copyright 2010 Sam Deane, Elegant Chaos. All rights reserved.
// --------------------------------------------------------------------------

#import <UIKit/UIKit.h>

#import "ECDataDrivenView.h"


@interface ECTextItemEditorController : UIViewController<ECDataDrivenView, UITextFieldDelegate>

// --------------------------------------------------------------------------
// Public Properties
// --------------------------------------------------------------------------

@property (strong, nonatomic) ECDataItem* data;
@property (strong, nonatomic) IBOutlet UITextField* editor;
@property (strong, nonatomic) IBOutlet UILabel* label;

// --------------------------------------------------------------------------
// Outlets
// --------------------------------------------------------------------------

#ifndef __OBJC__
@property () IBOutlet UITextField* editor;
#endif

@end
