// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 12/12/2011
//
//  Copyright 2012 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECTAppDelegate.h"
#import "ECTModelController.h"


@interface ECTAppDelegate()

@property (strong, nonatomic) UIImageView* splash;

- (void)showSplash;
- (void)hideSplash;
- (void)hiddenSplash;
- (void)shutdownLogging;
@end

@implementation ECTAppDelegate

@synthesize model = _model;
@synthesize splash = _splash;
@synthesize window = _window;

ECDefineDebugChannel(ApplicationChannel);

// --------------------------------------------------------------------------
//! Return the normal instance.
// --------------------------------------------------------------------------

+ (id)sharedInstance
{
	return [UIApplication sharedApplication].delegate;
}

// --------------------------------------------------------------------------
//! Clean up.
// --------------------------------------------------------------------------

- (void)dealloc 
{
    [_model release];
    [_window release];
	
    [super dealloc];
}

// --------------------------------------------------------------------------
//! Set up the app after launching.
// --------------------------------------------------------------------------

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    ECDebug(ApplicationChannel, @"did finish launching");

	ECTModelController* nm = [self newModelController];
	self.model = nm;
	[nm startup];
	[nm load];
	[nm release];

	UIViewController* nrvc = [self newRootViewController];
	UIWindow* nw = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window = nw;
	nw.rootViewController = nrvc;
	[nw makeKeyAndVisible];
	[nrvc release];
	[nw release];
	
	[self showSplash];
	
	return YES;
}

// --------------------------------------------------------------------------
//! Handle becoming inactive.
// --------------------------------------------------------------------------

- (void)applicationWillResignActive:(UIApplication *)application 
{
    ECDebug(ApplicationChannel, @"will resign active");
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

	[self.model save];
    [[ECLogManager sharedInstance] saveChannelSettings];
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
    
	[self.model shutdown];
    [self shutdownLogging];
}


#pragma mark - Logging

// --------------------------------------------------------------------------
//! Shut down standard logging.
// --------------------------------------------------------------------------

- (void)shutdownLogging
{
    [[ECLogManager sharedInstance] saveChannelSettings];
    [[ECLogManager sharedInstance] shutdown];
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

#pragma mark - Splash Screen

- (void)showSplash
{
    UIImage* image = [UIImage imageNamed:@"Default.png"];
	if (image)
	{
		UIImageView* iv = [[UIImageView alloc] initWithImage:image];
		iv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		iv.contentMode = UIViewContentModeCenter;
		[self.window.rootViewController.view addSubview:iv];
		[self performSelector:@selector(hideSplash) withObject:nil afterDelay:0.0];
		self.splash = iv;
		[iv release];
	}
}

- (void)hideSplash
{
    [UIView beginAnimations:@"fade out splash" context:nil];
    [UIView setAnimationDidStopSelector:@selector(hiddenSplash)];
    self.splash.alpha = 0.0;
    [UIView commitAnimations];
    self.splash = nil;
}

- (void)hiddenSplash
{
    [self.splash removeFromSuperview];
    self.splash = nil;
}

@end
