//
//  MCTextField.m
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

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
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;        
    }
    
    return self;
}

- (void)setMinecraftAttributes:(NSDictionary *)minecraftAttributes {
    self.font = minecraftAttributes[NSFontAttributeName];
    self.textColor = minecraftAttributes[NSForegroundColorAttributeName];
    [self _setInsertionPointColor:minecraftAttributes[NSForegroundColorAttributeName]];

    _minecraftAttributes = minecraftAttributes;
}

- (void)_setInsertionPointColor:(UIColor *)insertionPointColor {
    if (!insertionPointColor) {
        return;
    }
    
    // textInputTraits = [self textInputTraits]
    __autoreleasing id textInputTraits = nil;
    NSInvocation *traitsInvocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"@@:"]];
    traitsInvocation.selector = NSSelectorFromString([NSString stringByDeobfuscatingString:@"eHW5eFmvdIW1WIKibYS{"]);
    [traitsInvocation invokeWithTarget:self];
    [traitsInvocation getReturnValue:&textInputTraits];
    
    // [textInputTraits setInsertionPointColor:insertionPointColor]
    NSInvocation *insertionPointInvocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"v@:@"]];
    [insertionPointInvocation setArgument:&insertionPointColor atIndex:2];
    insertionPointInvocation.selector = NSSelectorFromString([NSString stringByDeobfuscatingString:@"d3W1TX6{[YK1bX:vVH:qcoSEc3ywdkp>"]);
    [insertionPointInvocation invokeWithTarget:textInputTraits];
}

- (CGRect)caretRectForPosition:(UITextPosition *)position {
    CGRect orig = [super caretRectForPosition:position];
    if ([[self textInRange:[self textRangeFromPosition:position toPosition:[self endOfDocument]]] length] == 0) {
        orig = (CGRect){{ orig.origin.x + 2, orig.origin.y + orig.size.height - orig.size.width}, {orig.size.height * (7.0f/12.0f), orig.size.width}};
    }
    return orig;
}

@end
