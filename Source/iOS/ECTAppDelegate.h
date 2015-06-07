// --------------------------------------------------------------------------
//  Copyright 2015 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import <Foundation/Foundation.h>

@class ECTModelController;

@interface ECTAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) id model;
@property (strong, nonatomic) UIWindow* window;

+ (instancetype)sharedInstance;

- (id)newModelController;
- (UIViewController*)newRootViewController;

- (NSString*)backgroundImageNameWithBaseName:(NSString*)base;

@end
