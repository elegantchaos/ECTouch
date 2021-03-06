// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 05/07/2011
//
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECTBinding.h"

#import "ECTSimpleCell.h"
#import "ECTKeys.h"

#import "ECTSectionDrivenTableController.h"

#pragma mark - Constants

@interface ECTBinding()

- (id)lookupKey:(NSString*)keyIn;

@end

@implementation ECTBinding

#pragma mark - Channels

ECDefineDebugChannel(ECTBindingChannel);

#pragma mark - Properties

@synthesize actionSelector;
@synthesize canDelete;
@synthesize canMove;
@synthesize cellClass;
@synthesize enabled;
@synthesize mappings;
@synthesize object;
@synthesize properties;
@synthesize target;

#pragma mark - Object lifecycle

+ (id)controllerWithObject:(id)object properties:(NSDictionary*)properties
{
    ECTBinding* controller = [[self alloc] initWithObject:object];
    [controller setValuesForKeysWithDictionary:properties];

    return [controller autorelease];
}

- (id)initWithObject:(id)objectIn
{
    if ((self = [super init]) != nil) 
    {
        self.cellClass = [ECTSimpleCell class];
        self.object = objectIn;
        self.enabled = YES;
    }
    
    return self;
}

- (void)dealloc
{
    [mappings release];
    [object release];
    [properties release];
    
    [super dealloc];
}

#pragma mark - Utilities
- (id)valueForUndefinedKey:(NSString *)undefinedKey
{
    return [self.properties objectForKey:undefinedKey];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)undefinedKey
{
    if (!self.properties)
    {
        self.properties = [NSMutableDictionary dictionaryWithObject:value forKey:undefinedKey];
    }
    else
    {
        [self.properties setValue:value forKey:undefinedKey];
    }
}

- (id)lookupDisclosureKey:(NSString *)key
{
    NSDictionary* disclosure = [self lookupKey:ECTDisclosureKey];
    id result = [disclosure objectForKey:key];
    
    return result;
}

#pragma mark - ECSectionDrivenTableObject methods

- (NSString*)identifier
{
    return [ECCoercion asClassName:self.cellClass];
}

- (UIImage*)image
{
    id result = [self lookupKey:ECTImageKey];
    if ([result isMemberOfClass:[NSString class]])
    {
        result = [UIImage imageNamed:result];
    }
    
    return result;
}

- (id)lookupKey:(NSString*)keyIn
{
    // if we've got a fixed string, use it
    NSString* result = [self.properties objectForKey:keyIn];
    if (!result)
    {
        // if we've got a key set, use that to look up a value on the object
        NSString* key = [self.mappings objectForKey:keyIn];
		if (!key)
		{
			key = keyIn;
		}
		@try 
		{
            result = [self.object valueForKeyPath:key];
		}
		@catch (NSException* exception)
		{
			ECDebug(ECTBindingChannel, @"object %@ doesn't support key path %@", object, key);
		}
    }
    
    return result;

}

- (NSString*)label
{
    NSString* result = [self lookupKey:ECTLabelKey];
    if (!result)
    {
        result = [self.value description];
    }
    
    return result;
}


- (NSString*)detail
{
    // if we've got a fixed string, use it
    NSString* result = [self lookupKey:ECTDetailKey];

    // fall back to using the object value, as long as it's not already used for the label
    if (!result && self.label)
    {
        result = [self.value description];
    }
    
    return result;
}

- (Class)disclosureClassWithDetail:(BOOL)useDetail
{
    NSString* key = useDetail ? ECTDetailKey : ECTClassKey;
    id class = [self lookupDisclosureKey:key];
    Class result = [ECCoercion asClass:class];
    
    return result;
}

- (id)value
{
    id result = [self lookupKey:ECTValueKey];
    if (!result)
    {
        result = self.object;
    }
    
    return result;
}

- (void)setValue:(id)value
{
    NSString* key = [self.mappings objectForKey:ECTValueKey];
    [self.object setValue:value forKeyPath:key];
}

- (NSString*)action
{
    return NSStringFromSelector(self.actionSelector);
}

- (void)setAction:(NSString*)actionName
{
    self.actionSelector = NSSelectorFromString(actionName);
}

- (void)addValueObserver:(id)observer options:(NSKeyValueObservingOptions)options
{
    for (NSString* key in self.mappings)
    {
        NSString* mappedKey = [self.mappings objectForKey:key];
        [self.object addObserver:observer forKeyPath:mappedKey options:options context:self];
    }
}

- (void)removeValueObserver:(id)observer
{
    for (NSString* key in self.mappings)
    {
        NSString* mappedKey = [self.mappings objectForKey:key];
        [self.object removeObserver:observer forKeyPath:mappedKey];
    }
}

- (void)setupView:(UIViewController*)view forNavigationController:(UINavigationController*)navigation
{
	NSString* title = [self lookupDisclosureKey:ECTTitleKey];
	if (!title)
	{
		title = [self label];
	}
	if (title)
	{
		view.title = title;   
	}
	
	BOOL isSectionDriven = [view isKindOfClass:[ECTSectionDrivenTableController class]];
	ECTSectionDrivenTableController* asSectionDriven = (ECTSectionDrivenTableController*) view;
	if (isSectionDriven)
	{
		asSectionDriven.navigator = navigation;
	}
	
	BOOL isDisclosure = [view conformsToProtocol:@protocol(ECTBindingViewController)];
	if (isDisclosure)
	{
		[(id<ECTBindingViewController>) view setupForBinding:self];
	}
	
	if (isSectionDriven)
	{
		NSArray* sectionsData = [ECCoercion asArray:[self lookupDisclosureKey:ECTSectionsKey]];
		if (sectionsData)
		{
			for (id sectionData in sectionsData)
			{
				ECTSection* section = [ECTSection sectionWithProperties:sectionData];
				[asSectionDriven addSection:section];
			}
		}
	}
	
}

- (void)pushView:(UIViewController*)view forNavigationController:(UINavigationController*)navigation
{
	NSString* back = [self lookupDisclosureKey:ECTBackKey];
	if (back)
	{
		UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:back style:UIBarButtonItemStylePlain target:nil action:nil];
		navigation.topViewController.navigationItem.backBarButtonItem = backButton;
		[backButton release];
	}
	[navigation pushViewController:view animated:YES];
	ECDebug(ECTBindingChannel, @"pushed %@ into navigation stack for %@", view, navigation);	
}

@end
