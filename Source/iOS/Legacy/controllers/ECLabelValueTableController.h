// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 20/07/2010
//
//  Copyright 2010 Sam Deane, Elegant Chaos. All rights reserved.
// --------------------------------------------------------------------------


#import "ECDataItem.h"
#import "ECDataDrivenView.h"

#import <UIKit/UIKit.h>

@interface ECLabelValueTableController : UITableViewController <UITableViewDataSource, UITableViewDelegate, ECDataDrivenView>
{
}

@property (strong, nonatomic) ECDataItem* data;
@property (assign, nonatomic) Class cellClass;

- (id) initWithNibName: (NSString*) nibNameOrNil bundle:(NSBundle *)nibBundleOrNil data: (ECDataItem*) data;

@end

