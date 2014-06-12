// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 03/02/2012
//
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECTTabbedTableViewController.h"

@interface ECTTabbedTableViewController ()

- (void)showContentForTabWithIndex:(NSUInteger)index;

@end

@implementation ECTTabbedTableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSUInteger index = [self.tabs.items indexOfObject:self.tabs.selectedItem];
    [self showContentForTabWithIndex:index];
}

#pragma mark - TabBarDelegate

- (void)tabBar:(UITabBar*)tabBar didSelectItem:(UITabBarItem *)item
{
    NSUInteger index = [tabBar.items indexOfObject:item];
    [self showContentForTabWithIndex:index];
}

#pragma mark - Content

- (void)selectTabWithIndex:(NSUInteger)index
{
    self.tabs.selectedItem = [self.tabs.items objectAtIndex:index];
    [self showContentForTabWithIndex:index];
}

- (void)showContentForTabWithIndex:(NSUInteger)index
{
    id<UITableViewDataSource, UITableViewDelegate> controller = [self.controllers objectAtIndex:index];
    self.table.delegate = controller;
    self.table.dataSource = controller;
    [self.table reloadData];
}

@end
