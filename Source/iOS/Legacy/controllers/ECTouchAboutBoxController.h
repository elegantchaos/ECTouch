// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 28/07/2010
//
//  Copyright 2010 Sam Deane, Elegant Chaos. All rights reserved.
// --------------------------------------------------------------------------

#import <UIKit/UIKit.h>


@interface ECTouchAboutBoxController : UIViewController 

@property (strong, nonatomic) IBOutlet UILabel* application;
@property (strong, nonatomic) IBOutlet UILabel* version;
@property (strong, nonatomic) IBOutlet UITextField* about;
@property (strong, nonatomic) IBOutlet UILabel* copyright;
@property (strong, nonatomic) IBOutlet UIImageView* logo;

@end
