// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 12/04/2011
//
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECTSimpleCell.h"
#import "ECTSection.h"
#import "ECTBinding.h"
#import "ECTKeys.h"

@interface ECTSimpleCell()

- (void)removeBinding;

@end


@implementation ECTSimpleCell

#pragma mark - Channels

ECDefineDebugChannel(ECTSimpleCellChannel);

#pragma mark - Properties

@synthesize canDelete;
@synthesize canMove;
@synthesize binding; // TODO should this be a weak link?
@synthesize section;

#pragma mark - Object lifecycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) != nil)
    {
        ECDebug(ECTSimpleCellChannel, @"new cell %@", self);
    }
    
    return self;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    return [self initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
}

- (void)dealloc
{
    [self removeBinding];
    [section release];
    
    [super dealloc];
}

- (void)removeBinding
{
    if (self.binding)
    {
        ECDebug(ECTSimpleCellChannel, @"removed binding %@ from cell %@", self.binding, self);
        [self.binding removeValueObserver:self];
        self.binding = nil;
    }
}

- (void)prepareForReuse
{
	[self removeBinding]; // TODO - previously this asserted that the binding was nil, but it doesn't always seem to get cleared; need to investigate why
    [super prepareForReuse];
    ECDebug(ECTSimpleCellChannel, @"reusing cell %@", self);

}

- (void)didMoveToSuperview
{
    if (self.superview == nil)
    {
        [self removeBinding];
        ECDebug(ECTSimpleCellChannel, @"removed cell %@", self);
    }
    [super didMoveToSuperview];
}

- (BOOL)updateMainLabel:(NSString*)value event:(UpdateEvent)event
{
	return [self updateLabel:self.textLabel value:value event:event];
}

- (BOOL)updateDetailLabel:(NSString*)detail event:(UpdateEvent)event
{
	return [self updateLabel:self.detailTextLabel value:detail event:event];
}

- (BOOL)updateUIForEvent:(UpdateEvent)event
{
    // get image to use
    UIImage* image = [self.binding image];
    self.imageView.image = image;
    
    // get text to use for value and detail labels
    NSString* mainLabel = [binding label];
    NSString* detailLabel = [binding detail];

    // if detail and value map to the same thing, don't show detail
	if (detailLabel == mainLabel)
    {
        detailLabel = nil;
    }
    
    self.canMove = [binding canMove];
    self.canDelete = [binding canDelete];
    
    self.selectionStyle = binding.enabled ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;

    BOOL changed = [self updateMainLabel:mainLabel event:event];
    if (detailLabel)
    {
		changed = [self updateDetailLabel:detailLabel event:event] || changed;
    }
    
    return changed;
}

- (void)updateAndLayoutUIForEvent:(UpdateEvent)event
{
	BOOL changed = [self updateUIForEvent:event];
    if (changed)
    {
        if (event == ValueChanged)
        {
            [self layoutSubviews];
        }
    }
}

- (void)setupFontForLabel:(UILabel*)label key:(NSString*)key info:(NSDictionary*)fontInfo
{
    NSDictionary* info = [fontInfo objectForKey:key];
    if (info)
    {
        label.font = [UIFont fontFromDictionary:info];
    }
}

- (void)setupForBinding:(ECTBinding*)newBinding section:(ECTSection*)sectionIn
{
    self.section = sectionIn;
    self.binding = newBinding;

    NSDictionary* fontInfo = [self.binding lookupKey:ECTFontKey];
    if (fontInfo)
    {
        [self setupFontForLabel:self.textLabel key:ECTLabelKey info:fontInfo];
        [self setupFontForLabel:self.detailTextLabel key:ECTDetailKey info:fontInfo];
    }
    
    [self setupAccessory];
    [self updateAndLayoutUIForEvent:ValueInitialised];
    [newBinding addValueObserver:self options:NSKeyValueObservingOptionNew];
}

- (void)setupAccessory
{
    UITableViewCellAccessoryType accessory;
    
    if ([self.binding lookupDisclosureKey:ECTDetailKey])
    {
        accessory = UITableViewCellAccessoryDetailDisclosureButton;
    }
    else if ([self.binding lookupDisclosureKey:ECTClassKey])
    {
        accessory = UITableViewCellAccessoryDisclosureIndicator;
    }
    else
    {
        accessory = UITableViewCellAccessoryNone;
    }
    
    self.accessoryType = accessory;
}

- (SelectionMode)didSelect
{
    if (self.binding.actionSelector)
    {
        [[UIApplication sharedApplication] sendAction:self.binding.actionSelector to:self.binding.target from:self forEvent:nil];
    }

    return SelectIfSelectable;
}

+ (CGFloat)heightForBinding:(ECTBinding*)binding
{
    return UITableViewAutomaticDimension;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == self.binding)
    {
        [self updateAndLayoutUIForEvent:ValueChanged];
    }
}

- (BOOL)updateLabel:(UILabel*)label value:(NSString*)value event:(UpdateEvent)event
{
    BOOL enabled = self.binding.enabled;

    BOOL changed = (![value isEqualToString:label.text]) || (enabled != label.enabled);
    if (changed)
    {
        label.text = value;
        label.enabled = enabled;
    }

    return changed;
}

- (BOOL)updateLabel:(UILabel*)label key:(NSString*)key event:(UpdateEvent)event
{
    NSString* value = [[self.binding lookupKey:key] description];
	return [self updateLabel:label value:value event:event];
}

@end
