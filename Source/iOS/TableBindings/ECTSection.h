// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 12/04/2011
//
//  Copyright 2012 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import <Foundation/Foundation.h>

@class ECTBinding;
@class ECTSectionDrivenTableController;

typedef enum
{
    SelectNever,
    SelectAlways,
    SelectIfSelectable
} SelectionMode;

// --------------------------------------------------------------------------
//! Controller for a section in a table.
// --------------------------------------------------------------------------

@interface ECTSection : NSObject

@property (nonatomic, retain) NSString* addDisclosureTitle;
@property (nonatomic, retain) NSString* cellIdentifier;
@property (nonatomic, retain) NSString* header;
@property (nonatomic, retain) NSString* footer;
@property (nonatomic, assign) Class cellClass;
@property (nonatomic, assign) BOOL canDelete;
@property (nonatomic, assign) BOOL canMove;
@property (nonatomic, assign) BOOL canSelect;
@property (nonatomic, assign) BOOL variableRowHeight;
@property (nonatomic, assign) ECTSectionDrivenTableController* table;
@property (nonatomic, retain) NSArray* content;
@property (nonatomic, retain) ECTBinding* binding;

+ (ECTSection*)sectionWithProperties:(id)propertiesOrPlistName;
+ (ECTSection*)sectionWithProperties:(id)propertiesOrPlistName boundToArrayAtPath:(NSString*)path object:(id)object;
+ (ECTSection*)sectionWithProperties:(id)propertiesOrPlistName boundToObject:(id)object;

- (void)addRow:(id)object;
- (void)makeAddableWithObject:(id)object properties:(NSDictionary*)properties;
- (void)bindObject:(id)object;
- (void)bindArrayAtPath:(NSString*)path object:(id)object;
- (void)sourceChanged;

- (BOOL)canEdit;
- (void)reloadData;
- (UITableView*)tableView;

- (NSInteger)numberOfRowsInSection;
- (NSString *)titleForHeaderInSection;
- (NSString *)titleForFooterInSection;
- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (Class)disclosureClassForBinding:(ECTBinding*)binding detail:(BOOL)detail;
- (UIViewController*)disclosureViewForRowAtIndexPath:(NSIndexPath*)indexPath detail:(BOOL)detail;
- (id)bindingForRowAtIndexPath:(NSIndexPath*)indexPath;
- (BOOL)canEditRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)canMoveRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;
- (void)moveRowFromSection:(ECTSection*)section atIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath ;
- (void)commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface ECTSection(Deprecated)
- (void)addRow:(id)object key:(NSString*)key properties:(NSDictionary*)properties EC_DEPRECATED;
- (void)bindSource:(NSArray*)source key:(NSString*)key properties:(NSDictionary*)properties EC_DEPRECATED;
@end

@protocol ECTSectionDrivenTableCell <NSObject>

@property (nonatomic, retain) ECTBinding* binding;

+ (CGFloat)heightForBinding:(ECTBinding*)binding;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)setupForBinding:(ECTBinding*)binding section:(ECTSection*)section;
- (SelectionMode)didSelect;
- (BOOL)canDelete;
- (BOOL)canMove;
@end


@interface UIViewController(ECTTables)

- (id)initWithBinding:(ECTBinding*)binding;

@end

