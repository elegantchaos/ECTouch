// --------------------------------------------------------------------------
//  Copyright 2015 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

ECDeclareDebugChannel(ModelChannel);

typedef void (^ECModelControllerStartupCallbackBlock)(NSError* error);

@interface ECTModelController : NSObject

@property (strong, nonatomic, readonly) ECModelControllerStartupCallbackBlock startupBlock;


+ (id)sharedInstance;

- (void)startupWithCallback:(ECModelControllerStartupCallbackBlock)callback;
- (void)shutdown;
- (void)load;
- (void)save;

@end
