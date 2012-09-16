//
//  MCTextField.m
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "MCTextField.h"

#import "NSString+Obfuscation.h"

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
        
        
        // textInputTraits = [self textInputTraits]
        __unsafe_unretained id textInputTraits = nil;
        NSInvocation *traitsInvocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"@@:"]];
        traitsInvocation.selector = NSSelectorFromString([NSString stringByDeobfuscatingString:@"eHW5eFmvdIW1WIKibYS{"]);
        [traitsInvocation invokeWithTarget:self];
        [traitsInvocation getReturnValue:&textInputTraits];
        
        // [textInputTraits setInsertionPointColor:insertionPointColor]
        __unsafe_unretained UIColor *insertionPointColor = [UIColor colorWithHue:0.0f saturation:0.0f brightness:0.87843f alpha:1.0f];
        NSInvocation *insertionPointInvocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"v@:@"]];
        [insertionPointInvocation setArgument:&insertionPointColor atIndex:2];
        insertionPointInvocation.selector = NSSelectorFromString([NSString stringByDeobfuscatingString:@"d3W1TX6{[YK1bX:vVH:qcoSEc3ywdkp>"]);
        [insertionPointInvocation invokeWithTarget:textInputTraits];        
    }
    
    return self;
}

- (CGSize)intrinsicContentSize {
    BOOL isPad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    return (CGSize){ isPad ? 400 : 280 , isPad ? 44 : 33 };
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
