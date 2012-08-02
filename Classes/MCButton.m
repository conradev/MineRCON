//
//  MCButton.m
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import "MCButton.h"

@implementation MCButton

- (id)init {
    if ((self = [super init])) {
        self.titleLabel.font = [UIFont fontWithName:@"Minecraft" size:16.0f];
        self.titleLabel.shadowColor = [UIColor colorWithHue:0.0f saturation:0.0f brightness:0.21875f alpha:1.0f];
        self.titleLabel.shadowOffset = CGSizeMake(2, 2);
        
        [self setBackgroundImage:[UIImage imageNamed:@"Button"] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor colorWithHue:0.0f saturation:0.0f brightness:0.87843f alpha:1.0f] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"Button_highlighted"] forState:UIControlStateHighlighted];
        [self setTitleColor:[UIColor colorWithRed:1.0f green:1.0f blue:0.625f alpha:1.0f] forState:UIControlStateHighlighted];
        [self setBackgroundImage:[UIImage imageNamed:@"Button_disabled"] forState:UIControlStateDisabled];
        [self setTitleColor:[UIColor colorWithHue:0.0f saturation:0.0f brightness:0.62745f alpha:1.0f] forState:UIControlStateDisabled];        
    }
    return self;
}

- (CGSize)intrinsicContentSize {
    return (CGSize){ 280, 40 };
}

@end
