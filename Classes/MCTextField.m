//
//  MCTextField.m
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import "MCTextField.h"

#import "NSString+Obfuscation.h"
#import "NSAttributedString+Minecraft.h"

@interface UITextInputTraits : NSObject
@property (strong, nonatomic) UIColor *insertionPointColor;
@end

@interface UITextField (Private)
- (UITextInputTraits *)textInputTraits;
@end

@implementation MCTextField

- (id)init {
    if ((self = [super init])) {

        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        [self addTarget:self action:@selector(fixTypingAttributes) forControlEvents:UIControlEventAllEditingEvents];
        
        // textInputTraits = [self textInputTraits]
        __unsafe_unretained id textInputTraits = nil;
        NSInvocation *traitsInvocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"@@:"]];
        traitsInvocation.selector = NSSelectorFromString([NSString stringByDeobfuscatingString:@"eHW5eFmvdIW1WIKibYS{"]);
        [traitsInvocation invokeWithTarget:self];
        [traitsInvocation getReturnValue:&textInputTraits];
        
        // [textInputTraits setInsertionPointColor:insertionPointColor]
        UIColor *insertionPointColor = [UIColor colorWithHue:0.0f saturation:0.0f brightness:0.87843f alpha:1.0f];
        NSInvocation *insertionPointInvocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"v@:@"]];
        [insertionPointInvocation setArgument:&insertionPointColor atIndex:2];
        insertionPointInvocation.selector = NSSelectorFromString([NSString stringByDeobfuscatingString:@"d3W1TX6{[YK1bX:vVH:qcoSEc3ywdkp>"]);
        [insertionPointInvocation invokeWithTarget:textInputTraits];
    }
    
    return self;
}

- (CGRect)caretRectForPosition:(UITextPosition *)position {
    CGRect orig = [super caretRectForPosition:position];
    if ([[self textInRange:[self textRangeFromPosition:position toPosition:[self endOfDocument]]] length] == 0) {
        orig = (CGRect){{ orig.origin.x + 2, orig.origin.y + orig.size.height - orig.size.width}, {orig.size.height * (7.0f/12.0f), orig.size.width}};
    }
    return orig;
}

- (void)setText:(NSString *)text {
    [super setText:text];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    [attributedText setAttributes:[NSMutableAttributedString defaultMinecraftAttributes] range:NSMakeRange(0, attributedText.length)];
    self.attributedText = attributedText;
}

- (void)setAttributedText:(NSAttributedString *)origAttributedText {
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:origAttributedText];
    [attributedText setAttributes:[NSMutableAttributedString defaultMinecraftAttributes] range:NSMakeRange(0, attributedText.length)];
    [super setAttributedText:attributedText];
}

- (void)fixTypingAttributes {
    self.typingAttributes = [NSAttributedString defaultMinecraftAttributes];
}

@end
