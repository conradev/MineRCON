//
//  MCTextField.m
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "MCTextField.h"

@interface UITextInputTraits : NSObject
@property (strong, nonatomic) UIColor *insertionPointColor;
@end

@interface UITextField (Private)
- (UITextInputTraits *)textInputTraits;
@end

@implementation MCTextField

- (id)init {
    if ((self = [super init])) {
        // UITextInputTraits
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.spellCheckingType = UITextSpellCheckingTypeNo;
        self.keyboardType = UIKeyboardTypeASCIICapable;
        
        // Display characteristics
        self.font = [UIFont fontWithName:@"Minecraft" size:16.0f];
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.backgroundColor = [UIColor blackColor];
        self.textColor = [UIColor colorWithHue:0.0f saturation:0.0f brightness:0.87843f alpha:1.0f];
        self.layer.borderColor = [[UIColor colorWithHue:0.0f saturation:0.0f brightness:0.63f alpha:1.0f] CGColor];
        self.layer.borderWidth = 2.0f;
        
        [[self textInputTraits] setInsertionPointColor:[UIColor colorWithHue:0.0f saturation:0.0f brightness:0.87843f alpha:1.0f]];
    }
    return self;
}

- (CGSize)intrinsicContentSize {
    CGFloat width = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? 400 : 280;
    return (CGSize){ width, 44 };
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, 44)];
}

- (CGRect)caretRectForPosition:(UITextPosition *)position {
    CGRect orig = [super caretRectForPosition:position];
    if (![[self textInRange:[self textRangeFromPosition:position toPosition:[self endOfDocument]]] length]) {
        orig = (CGRect){{ orig.origin.x + 2, orig.origin.y + orig.size.height - orig.size.width}, {orig.size.height * (7.0f/12.0f), orig.size.width}};
    }
    return orig;
}
 
- (void)drawTextInRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
        
    // Disable font smoothing and anti-aliasing
    CGContextSetAllowsAntialiasing(context, false);
    CGContextSetAllowsFontSubpixelPositioning(context, false);
    CGContextSetAllowsFontSmoothing(context, false);
    
    // Create shadow color
    float colorValues[] = {0.21875, 0.21875, 0.21875, 1.0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef shadowColor = CGColorCreate(colorSpace, colorValues);
    CGColorSpaceRelease(colorSpace);
    
    // Create shadow
    CGSize shadowOffset = CGSizeMake(2, 2);
    CGContextSetShadowWithColor(context, shadowOffset, 0, shadowColor);
    CGColorRelease(shadowColor);
    
    // Render text
    [super drawTextInRect:rect];
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
