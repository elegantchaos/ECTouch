// --------------------------------------------------------------------------
//! @author Sam Deane
//
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECTSingleTableViewController.h"
#import "ECTSectionDrivenTableController.h"

@interface ECTSingleTableViewController()

@end

@implementation ECTSingleTableViewController

#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.table.navigator = self.navigationController;
}

@end
