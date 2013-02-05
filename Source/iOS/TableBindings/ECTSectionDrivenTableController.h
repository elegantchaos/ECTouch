// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 12/04/2011
//
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECTBindingViewController.h"

@class ECTSection;
@class ECTBinding;

// --------------------------------------------------------------------------
//! Table view controller which uses section controllers to populate and
//! control the table.
// --------------------------------------------------------------------------

@interface ECTSectionDrivenTableController : UITableViewController<ECTBindingViewController>

@property (strong, nonatomic, readonly) NSMutableArray* sections;
@property (strong, nonatomic) ECTBinding* representedObject;
@property (assign, nonatomic) UINavigationController* navigator;

- (void)clearSections;
- (void)addSection:(ECTSection*)section;
- (void)setupForBinding:(ECTBinding*)binding;
- (void)deselectAllRowsAnimated:(BOOL)animated;

@end
