// --------------------------------------------------------------------------
//  Copyright 2015 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECTAppDelegate.h"
#import "ECTModelController.h"


@interface ECTAppDelegate()

@property (strong, nonatomic) UIImageView* splash;

@end

@implementation ECTAppDelegate

ECDefineDebugChannel(ApplicationChannel);

// --------------------------------------------------------------------------
//! Return the normal instance.
// --------------------------------------------------------------------------

+ (id)sharedInstance
{
	return [UIApplication sharedApplication].delegate;
}

// --------------------------------------------------------------------------
//! Set up the app before launching.
// --------------------------------------------------------------------------

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    ECDebug(ApplicationChannel, @"will finish launching");

    return YES;
}

// --------------------------------------------------------------------------
//! Set up the app after launching.
// --------------------------------------------------------------------------

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    ECDebug(ApplicationChannel, @"did finish launching");

	ECTModelController* nm = [self newModelController];
	self.model = nm;
	[nm startupWithCallback:^(NSError* error){
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self application:application didFinishSettingUpModel:nm])
            {
                [self hideSplash];
            }
        });
    }];
	[nm load];

	UIViewController* nrvc = [self newRootViewController];
	UIWindow* nw = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window = nw;
	nw.rootViewController = nrvc;
	[nw makeKeyAndVisible];

	[self showSplash];
	
	return YES;
}

- (BOOL)application:(UIApplication *)application didFinishSettingUpModel:(ECTModelController*)model
{
    ECDebug(ApplicationChannel, @"model is set up");
    return YES;
}

// --------------------------------------------------------------------------
//! Handle becoming inactive.
// --------------------------------------------------------------------------

- (void)applicationWillResignActive:(UIApplication *)application 
{
    ECDebug(ApplicationChannel, @"will resign active");
    [self saveModel];
}

// --------------------------------------------------------------------------
//! Handle becoming active again.
// --------------------------------------------------------------------------

- (void)applicationDidBecomeActive:(UIApplication *)application 
{
    ECDebug(ApplicationChannel, @"did become active");
}

// --------------------------------------------------------------------------
//! Handle low memory.
// --------------------------------------------------------------------------

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application 
{
    ECDebug(ApplicationChannel, @"did receive memory warning");
}

// --------------------------------------------------------------------------
//! Handle moving into the background.
// --------------------------------------------------------------------------

-(void) applicationDidEnterBackground:(UIApplication*)application 
{
    ECDebug(ApplicationChannel, @"did enter background");
    [self saveModel];
}

// --------------------------------------------------------------------------
//! Handle returning to foreground.
// --------------------------------------------------------------------------

-(void) applicationWillEnterForeground:(UIApplication*)application 
{
    ECDebug(ApplicationChannel, @"will enter foreground");
}

// --------------------------------------------------------------------------
//! Handle app termination.
// --------------------------------------------------------------------------

- (void)applicationWillTerminate:(UIApplication *)application
{
    ECDebug(ApplicationChannel, @"will terminate");
    
    [self.model saveWithCallback:^(NSError *error) {
        [self.model shutdown];
        [self shutdownLogging];
    }];
}


#pragma mark - Logging

// --------------------------------------------------------------------------
//! Shut down standard logging.
// --------------------------------------------------------------------------

- (void)shutdownLogging
{
    ECLogManager* logManager = [ECLogManager sharedInstance];
    [logManager saveChannelSettings];
    [logManager shutdown];
}

#pragma mark - To Be Overridden

// --------------------------------------------------------------------------
//! Create and return the global modal controller.
//! Should be provided by subclass.
// --------------------------------------------------------------------------

- (id)newModelController
{
    ECTModelController* emptyModel = [[ECTModelController alloc] init];

	return emptyModel;
}

// --------------------------------------------------------------------------
//! Create and return the root view controller.
//! Should be provided by subclass.
// --------------------------------------------------------------------------

- (UIViewController*)newRootViewController
{
	ECAssertShouldntBeHere();
	
	return nil;
}

- (void)saveModel
{
    [self.model saveWithCallback:^(NSError *error) {
        if (error)
        {
            ECDebug(ApplicationChannel, @"error saving model %@", error);
        }
    }];
    [[ECLogManager sharedInstance] saveChannelSettings];
}

#pragma mark - Splash Screen

- (NSString*)backgroundImageNameWithBaseName:(NSString*)base
{
    NSString* name;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    if (height > 480)
    {
        name = [NSString stringWithFormat:@"%@-%ldh", base, (long) height];
    }
    else
    {
        name = base;
    }
    ECDebug(ApplicationChannel, @"background %@ height %lf, scale %lf, name %@", base, height, [UIScreen mainScreen].scale, name);
    
    return [name stringByAppendingPathExtension:@"png"];;
}

- (BOOL)splashShowing
{
    return self.splash != nil;
}

- (void)showSplash
{
    NSString* name = [self backgroundImageNameWithBaseName:@"Default"];
    UIImage* image = [UIImage imageNamed:name];
	if (image)
	{
		UIImageView* iv = [[UIImageView alloc] initWithImage:image];
		iv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		iv.contentMode = UIViewContentModeCenter;
        UIView* rootView = self.window.rootViewController.view;
        iv.frame = CGRectMake(0, -rootView.frame.origin.y, image.size.width, image.size.height);
		[rootView addSubview:iv];
		self.splash = iv;
	}
}

- (void)hideSplash
{
	UIView* splash = self.splash;
	[UIView animateWithDuration:1.0 animations:^
	{
		splash.alpha = 0.0;
	} completion:^(BOOL finished) {
        [self hiddenSplash];
    }];
    self.splash = nil;
}

- (void)hiddenSplash
{
    [self.splash removeFromSuperview];
    self.splash = nil;
}

@end
