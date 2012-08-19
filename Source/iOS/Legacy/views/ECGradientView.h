//
//  GradientView.h
//  pod point
//
//  Created by Sam Deane on 02/09/2010.
//  Copyright 2010 Elegant Chaos. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CAGradientLayer;

@interface ECGradientView : UIView 
{
}

@property (strong, nonatomic) UIColor* topColour;
@property (strong, nonatomic) UIColor* bottomColour;
@property (strong, nonatomic) CAGradientLayer* gradient;

- (void) updateColours;
- (void) slideIn;

@end
