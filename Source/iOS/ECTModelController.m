// --------------------------------------------------------------------------
//  Copyright 2015 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECTModelController.h"
#import "ECTAppDelegate.h"

@interface ECTModelController()
@property (strong, nonatomic, readwrite) ECModelControllerStartupCallbackBlock startupBlock;
@end

@implementation ECTModelController

ECDefineDebugChannel(ModelChannel);

+ (id)sharedInstance
{
	ECTAppDelegate* app = [ECTAppDelegate sharedInstance];
    return app.model;
}

- (void)startupWithCallback:(ECModelControllerStartupCallbackBlock)callback
{
    self.startupBlock = callback;
	ECDebug(ModelChannel, @"model startup");
}

- (void)shutdown
{
	ECDebug(ModelChannel, @"model shutdown");
}

- (void)load
{
	ECDebug(ModelChannel, @"model load");
}

- (void)save
{
	ECDebug(ModelChannel, @"model save");
}

@end
