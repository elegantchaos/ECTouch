// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 12/04/2011
//
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECTSection.h"
#import "ECTSimpleCell.h"
#import "ECTSectionDrivenTableController.h"
#import "ECTBinding.h"
#import "ECTKeys.h"

@interface ECTSection()

@property (strong, nonatomic) id source;
@property (strong, nonatomic) NSString* sourcePath;
@property (strong, nonatomic) ECTBinding* addCell;
@property (strong, nonatomic) NSDictionary* sectionProperties;
@property (strong, nonatomic) NSDictionary* everyRowProperties;
@property (strong, nonatomic) NSArray* individualRowProperties;
@property (assign, nonatomic) BOOL sourceChangedInternally;

- (void)bindArray:(NSArray*)array;
- (void)cleanupObservers;
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

@end

@implementation ECTSection

#pragma mark - Debug Channels

ECDefineDebugChannel(ECTSectionControllerChannel);

#pragma mark - Properties

@synthesize addCell;
@synthesize addDisclosureTitle;
@synthesize binding;
@synthesize content;
@synthesize canDelete;
@synthesize canMove;
@synthesize canSelect;
@synthesize cellIdentifier;
@synthesize footer;
@synthesize header;
@synthesize cellClass;
@synthesize source;
@synthesize sourcePath;
@synthesize sourceChangedInternally;
@synthesize table;
@synthesize variableRowHeight;

@synthesize sectionProperties;
@synthesize everyRowProperties;
@synthesize individualRowProperties;

#pragma mark - Constants

#pragma mark - Factory Methods

+ (ECTSection*)sectionWithProperties:(id)propertiesOrPlistName
{
    NSDictionary* properties = [ECCoercion loadDictionary:propertiesOrPlistName];
    ECTSection* section = [[ECTSection alloc] init];

    NSDictionary* sectionProperties = [properties objectForKey:@"section"];

    section.sectionProperties = sectionProperties;
    section.everyRowProperties = [properties objectForKey:@"everyRow"];
    section.individualRowProperties = [properties objectForKey:@"individualRows"];
    [section setValuesForKeysWithDictionary:sectionProperties];
    
    id content = [ECCoercion loadArray:[properties objectForKey:@"content"]];
    if (content)
    {
        [section bindArray:content];
    }

    NSDictionary* addRow = [properties objectForKey:@"add"];
    if (addRow)
    {
        NSString* label = [addRow objectForKey:ECTLabelKey];
        [section makeAddableWithObject:label properties:addRow];
    }

    return [section autorelease];
}

+ (ECTSection*)sectionWithProperties:(id)propertiesOrPlistName boundToArrayAtPath:(NSString *)path object:(id)object
{
    ECTSection* section = [self sectionWithProperties:propertiesOrPlistName];
    [section bindArrayAtPath:path object:object];
    
    return section;
}

+ (ECTSection*)sectionWithProperties:(id)propertiesOrPlistName boundToObject:(id)object
{
    ECTSection* section = [self sectionWithProperties:propertiesOrPlistName];
    [section bindObject:object];

    return section;
}

#pragma mark - Object lifecycle

- (id)init
{
    self = [super init];
    if (self) 
    {
        self.cellIdentifier = @"DefaultCellIdentifier";
        self.cellClass = [ECTSimpleCell class];
    }
    
    return self;
}

- (void)dealloc
{
    [self cleanupObservers];

    [addCell release];
    [binding release];
    [cellIdentifier release];
    [content release];
    [header release];
    [footer release];
    [source release];
    [sourcePath release];
    
    [super dealloc];
}

#pragma mark - Utilities

- (void)cleanupObservers
{
    if (self.sourcePath)
    {
        [self.source removeObserver:self forKeyPath:self.sourcePath];
    }
}

- (NSMutableArray*)mutableSource
{
    NSMutableArray* result;
    if (self.sourcePath)
    {
        result = [self.source mutableArrayValueForKey:self.sourcePath];
    }
    else if (self.source)
    {
        ECAssert([self.source isKindOfClass:[NSMutableArray class]]);
        result = (NSMutableArray*) self.source;
    }
    else
    {
        result = [NSMutableArray array];
        self.source = result;
    }

    return result;
}

#pragma mark - ECTSectionController methods

- (NSArray*)bindingsForObjects:(NSArray*)objects
{
    NSMutableArray* controllers = [NSMutableArray arrayWithCapacity:[objects count]];
	NSDictionary* everyRow = self.everyRowProperties;
	NSArray* individualRows = self.individualRowProperties;
	NSUInteger individualCount = [individualRows count];
	NSUInteger index = 0;
	
    for (id object in objects)
    {
		NSDictionary* properties = everyRow;
		if (index < individualCount)
		{
			NSMutableDictionary* merged = [NSMutableDictionary dictionaryWithDictionary:properties];
			[merged addEntriesFromDictionary:[individualRowProperties objectAtIndex:index]];
			properties = merged;
		}
		
        ECTBinding* item = [[ECTBinding alloc] initWithObject:object];
        [item setValuesForKeysWithDictionary:properties];
        [controllers addObject:item];
        [item release];
		
		++index;
    }
    
    return controllers;
}

- (void)bindArrayAtPath:(NSString *)path object:(id)object
{
    [self cleanupObservers];
    self.source = object;
    self.sourcePath = path;
    NSArray* array = [object valueForKeyPath:path];
    self.content = [NSMutableArray arrayWithArray:[self bindingsForObjects:array]];
    [object addObserver:self forKeyPath:path options:NSKeyValueObservingOptionNew context:nil];
}

- (void)bindArray:(NSArray*)array
{
    [self cleanupObservers];
    self.source = array;
    self.sourcePath = nil;
    self.content = [NSMutableArray arrayWithArray:[self bindingsForObjects:array]];
}

- (void)sourceChanged
{
    NSMutableArray* array = [self mutableSource];
    self.content = [NSMutableArray arrayWithArray:[self bindingsForObjects:array]];
    [self reloadData];
}

- (void)addContent:(id)object atIndex:(NSUInteger)index properties:(NSDictionary*)properties
{
    NSMutableArray* array;
    if (self.content)
    {
        array = (NSMutableArray*)self.content;
        ECAssert([array isKindOfClass:[NSMutableArray class]]);
    }
    else
    {
        array = [NSMutableArray array];
        self.content = array;
    }

    NSMutableDictionary* combined = [NSMutableDictionary dictionaryWithDictionary:self.everyRowProperties];
    [combined addEntriesFromDictionary:properties];
    if (index < [self.individualRowProperties count])
    {
        [combined addEntriesFromDictionary:[self.individualRowProperties objectAtIndex:index]];
    }
    
    ECTBinding* newBinding = [ECTBinding controllerWithObject:object properties:combined];
    [array insertObject:newBinding atIndex:index];
}

- (void)bindObject:(id)object
{
    NSUInteger count = [self.individualRowProperties count];
    for (NSUInteger index = 0; index < count; ++index)
    {
        [[self mutableSource] addObject:object];
        [self addContent:object atIndex:index properties:nil];
    }
    
}

- (void)addRow:(id)object
{
    [[self mutableSource] addObject:object];
    [self addContent:object atIndex:[self.content count] properties:nil];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"

- (void)addRow:(id)object key:(NSString*)key properties:(NSDictionary*)properties
{
    [[self mutableSource] addObject:object];
    NSMutableDictionary* combined = [NSMutableDictionary dictionaryWithDictionary:properties];
    [combined setObject:key forKey:ECTValueKey];
    [self addContent:object atIndex:[self.content count] properties:combined];
}

#pragma clang diagnostic pop

- (void)makeAddableWithObject:(id)object properties:(NSDictionary*)properties
{
    if (object)
    {
        self.addCell = [ECTBinding controllerWithObject:object properties:properties];
    }
    else
    {
        self.addCell = nil;
    }
}

- (UITableView*)tableView
{
    return (UITableView*)self.table.view;
}

- (BOOL)canEdit
{
    return self.canMove || self.canDelete; // - should add cell cause Edit button to show? || (self.addCell != nil);
}

- (void)reloadData
{
    [[self tableView] reloadData];
}

#pragma mark - TableView methods

- (ECTBinding*)bindingForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id result;
    
    if (self.addCell && ((NSUInteger) indexPath.row == [self.content count]))
    {
        result = self.addCell;
    }
    else
    {
        result = [self.content objectAtIndex:indexPath.row];
    }
    
    return result;
}

- (NSInteger)numberOfRowsInSection
{
    NSInteger result = [self.content count];
    if (self.addCell)
    {
        ++result;
    }
    
    return result;
}

- (NSString *)titleForHeaderInSection
{
    return self.header;
}

- (NSString *)titleForFooterInSection
{
    return self.footer;
}


- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ECTBinding* rowBinding = [self bindingForRowAtIndexPath:indexPath];

    NSString* identifier = [ECCoercion asClassName:rowBinding.cellClass];
    UITableViewCell<ECTSectionDrivenTableCell>* cell = (UITableViewCell<ECTSectionDrivenTableCell>*) [[self tableView] dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) 
    {
        Class class = [ECCoercion asClass:rowBinding.cellClass];
        cell = [[[class alloc] initWithReuseIdentifier:identifier] autorelease];
    }
    
    [cell setupForBinding:rowBinding section:self];
    
    return cell;
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat result = self.tableView.rowHeight;
    
    if (self.variableRowHeight)
    {
        ECTBinding* rowBinding = [self bindingForRowAtIndexPath:indexPath];
        Class<ECTSectionDrivenTableCell> class = [ECCoercion asClass:rowBinding.cellClass];
        result = [class heightForBinding:rowBinding];
        if (result == UITableViewAutomaticDimension)
        {
            result = self.tableView.rowHeight;
        }
    }
    
    return result;
}

- (UIViewController*)disclosureViewForRowAtIndexPath:(NSIndexPath*)indexPath detail:(BOOL)detail
{
    ECTBinding* rowBinding = [self bindingForRowAtIndexPath:indexPath];
    Class class = [self disclosureClassForBinding:rowBinding detail:detail];
    
    UIViewController* view = [class alloc];
    NSString* nib = NSStringFromClass([self class]);
    if ([[NSBundle mainBundle] pathForResource:nib ofType:@"nib"])
    {
        view = [view initWithNibName:nib bundle:nil];
    }
    else
    {
        view = [view initWithBinding:rowBinding];
    }
    
    ECDebug(ECTSectionControllerChannel, @"made disclosure view of class %@ for path %@", nib, indexPath);
    
    return [view autorelease];
}

- (Class)disclosureClassForBinding:(ECTBinding*)rowBinding detail:(BOOL)detail
{
    id class = [rowBinding disclosureClassWithDetail:detail];
    Class result = [ECCoercion asClass:class];
    
    return result;
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id selectedCell = [[self tableView] cellForRowAtIndexPath:indexPath];
    if ([selectedCell conformsToProtocol:@protocol(ECTSectionDrivenTableCell)])
    {
        UITableViewCell<ECTSectionDrivenTableCell>* cell = selectedCell;
        SelectionMode selectionMode = [cell didSelect];
        BOOL keepSelected = (selectionMode == SelectAlways) || ((selectionMode == SelectIfSelectable) && self.canSelect);
        if (keepSelected)
        {
            self.binding.value = cell.binding.object;
            if ([[self.binding lookupDisclosureKey:ECTAutoPopKey] boolValue])
            {
                [self.table.navigator popViewControllerAnimated:YES];
            }
        }
        else
        {
            [[self tableView] deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
}

- (BOOL)canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL result = self.canMove || self.canDelete;
    if (result)
    {
        id cell = [[self tableView] cellForRowAtIndexPath:indexPath];
        if ([cell conformsToProtocol:@protocol(ECTSectionDrivenTableCell)])
        {
            result = [cell canMove] || [cell canDelete];
        }
    }
    
    return result;
}

- (BOOL)canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL result = self.canMove;
    if (result)
    {
        id cell = [[self tableView] cellForRowAtIndexPath:indexPath];
        if ([cell conformsToProtocol:@protocol(ECTSectionDrivenTableCell)])
        {
            result = [cell canMove];
        }
    }

    return result;
}

- (void)moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    self.sourceChangedInternally = YES;
    
    NSUInteger fromRow = fromIndexPath.row;
    NSUInteger toRow = toIndexPath.row;
    NSMutableArray* mc = (NSMutableArray*) self.content;
    NSMutableArray* ms = [self mutableSource];
    [mc moveObjectFromIndex:fromRow toIndex:toRow];
    [ms moveObjectFromIndex:fromRow toIndex:toRow];
    
    self.sourceChangedInternally = NO;
}

- (void)moveRowFromSection:(ECTSection*)section atIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    
}

- (void)commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [(NSMutableArray*)self.content removeObjectAtIndex:indexPath.row];
        NSMutableArray* array = [self mutableSource];
        self.sourceChangedInternally = YES;
        [array removeObjectAtIndex:indexPath.row];
        self.sourceChangedInternally = NO;
    }

    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (!sourceChangedInternally && [keyPath isEqualToString:self.sourcePath])
    {
        NSKeyValueChange kind = [[change objectForKey:NSKeyValueChangeKindKey] intValue];
        NSIndexSet* indexes = [change objectForKey:NSKeyValueChangeIndexesKey];
        switch (kind)
        {
            case NSKeyValueChangeRemoval:
            {    
                NSMutableArray* mutableContent = (NSMutableArray*) self.content;
                [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) 
                {
                    [mutableContent removeObjectAtIndex:idx];
                }];
                break;
            }

            case NSKeyValueChangeInsertion:
            {    
                NSArray* newValues = [change objectForKey:NSKeyValueChangeNewKey];
                __block NSUInteger valueIndex = 0;
                [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) 
                 {
                     id newValue = [newValues objectAtIndex:valueIndex++];
                     [self addContent:newValue atIndex:idx properties:nil];
                 }];
                break;
            }

            case NSKeyValueChangeSetting:
            case NSKeyValueChangeReplacement:
            {
                [self sourceChanged];
                break;
            }
                
            default:
                ECDebug(ECTSectionControllerChannel, @"unhandled change kind %d for change %@", kind, change);
        }
        
        [self reloadData];
    }
}

@end

@implementation UIViewController(ECTTables)

- (id)initWithBinding:(ECTBinding*)binding
{
    self = [self initWithNibName:nil bundle:nil];
    
    return self;
}

@end
