//
//  MCPromptTextField.m
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import "MCPromptTextField.h"

#import "NSAttributedString+Minecraft.h"

@implementation MCPromptTextField

- (id)init {
    if ((self = [super init])) {
        self.backgroundColor = [UIColor darkGrayColor];
        
        self.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.spellCheckingType = UITextSpellCheckingTypeNo;
        self.enablesReturnKeyAutomatically = YES;
        self.returnKeyType = UIReturnKeySend;
        
        self.minecraftAttributes = [NSAttributedString defaultMinecraftAttributes];
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    CGRect orig = [super textRectForBounds:bounds];
    UIEdgeInsets textPadding = UIEdgeInsetsMake(0, 5, 0, 5);
    return UIEdgeInsetsInsetRect(orig, textPadding);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    CGRect orig = [super editingRectForBounds:bounds];
    UIEdgeInsets textPadding = UIEdgeInsetsMake(0, 5, 0, 5);
    return UIEdgeInsetsInsetRect(orig, textPadding);
}

@end
