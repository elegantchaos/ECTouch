// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 12/04/2011
//
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECTSwitchCell.h"
#import "ECTBinding.h"

@interface ECTSwitchCell()

@property (nonatomic, retain) UISwitch* switchControl;

- (IBAction)switched:(id)sender;

@end

@implementation ECTSwitchCell

#pragma mark - Debug channels

ECDefineDebugChannel(ECTSwitchSectionCellChannel);

#pragma mark - Properties

@synthesize switchControl;

#pragma mark - Object lifecycle

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) != nil)
    {
        UISwitch* view = [[UISwitch alloc] initWithFrame:CGRectZero];
        [view addTarget:self action:@selector(switched:) forControlEvents:UIControlEventValueChanged];
        self.accessoryView = view;
        self.switchControl = view;
        [view release];
    }
    
    return self;
}

- (void)dealloc
{
    [switchControl release];
    
    [super dealloc];
}

#pragma mark - UITableViewCell

// --------------------------------------------------------------------------
//! Custom selection handling.
// --------------------------------------------------------------------------

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (selected && self.switchControl.enabled)
    {
        [self.switchControl setOn:!self.switchControl.on animated:YES];
        [self switched:self];
    }
}

// --------------------------------------------------------------------------
//! Custom hilight handling.
// --------------------------------------------------------------------------

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    // we don't want the cell to highlight
}

#pragma mark - ECTSimpleSectionCell methods

- (BOOL)updateUIForEvent:(UpdateEvent)event
{
    BOOL value = [((NSNumber*) self.binding.value) boolValue];
	BOOL enabled = self.binding.enabled;
	BOOL changed = (self.switchControl.on != value) || (self.switchControl.enabled != enabled);
	if (changed)
	{
		self.switchControl.on = value;
		self.switchControl.enabled = enabled;
	}

    changed = [super updateUIForEvent:event] || changed;

	return changed;
}

#pragma mark - Actions

- (IBAction)switched:(id)sender
{
    ECDebug(ECTSwitchSectionCellChannel, @"switch %@ to %d", self.switchControl, switchControl.on); 
    
    self.binding.value = [NSNumber numberWithBool:switchControl.on];
}

@end
