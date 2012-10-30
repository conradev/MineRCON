//
//  MCEditTextField.m
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "MCEditTextField.h"

#import "NSAttributedString+Minecraft.h"
#import "UIColor+Minecraft.h"

@implementation MCEditTextField

- (id)init {
    if ((self = [super init])) {
        self.backgroundColor = [UIColor blackColor];
        self.layer.borderColor = [[UIColor minecraftSecondaryInterfaceForegroundColor] CGColor];
        self.layer.borderWidth = 2.0f;
        
        self.minecraftAttributes = [NSAttributedString minecraftInterfaceAttributes];
    }
    return self;
}

- (CGSize)intrinsicContentSize {
    BOOL isPad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    return (CGSize){ isPad ? 404 : 280 , isPad ? 44 : 30.5 };
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    CGRect orig = [super textRectForBounds:bounds];
    UIEdgeInsets textPadding = UIEdgeInsetsMake(0, 10, 0, 10);
    return UIEdgeInsetsInsetRect(orig, textPadding);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    CGRect orig = [super editingRectForBounds:bounds];
    UIEdgeInsets textPadding = UIEdgeInsetsMake(0, 10, 0, 10);
    return UIEdgeInsetsInsetRect(orig, textPadding);
}

@end
