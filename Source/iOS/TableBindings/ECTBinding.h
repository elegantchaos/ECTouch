// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 05/07/2011
//
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECTSection.h"

// --------------------------------------------------------------------------
//! Cell controller which sets a boolean property on an object.
// --------------------------------------------------------------------------

@interface ECTBinding : NSObject

@property (strong, nonatomic) id object;
@property (strong, nonatomic) NSMutableDictionary* properties;
@property (strong, nonatomic) NSMutableDictionary* mappings;

@property (assign, nonatomic) id cellClass;
@property (assign, nonatomic) BOOL canDelete;
@property (assign, nonatomic) BOOL canMove;
@property (assign, nonatomic) BOOL enabled;
@property (assign, nonatomic) SEL actionSelector;
@property (assign, nonatomic) NSString* action; // this is deliberately assign, since the actual selector is stored
@property (assign, nonatomic) id target;
@property (strong, nonatomic) id value;
@property (strong, nonatomic, readonly) NSString* label;
@property (strong, nonatomic, readonly) NSString* detail;

+ (id)controllerWithObject:(id)object properties:(NSDictionary*)properties;

- (id)initWithObject:(id)object;

- (id)lookupKey:(NSString*)keyIn;

- (id)lookupDisclosureKey:(NSString*)key;

- (Class)disclosureClassWithDetail:(BOOL)detail;
- (UIImage*)image;

- (void)addValueObserver:(id)observer options:(NSKeyValueObservingOptions)options;
- (void)removeValueObserver:(id)observer;

- (void)setupView:(UIViewController*)view forNavigationController:(UINavigationController*)navigation;
- (void)pushView:(UIViewController*)view forNavigationController:(UINavigationController*)navigation;

@end
