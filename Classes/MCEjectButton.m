//
//  MCEjectButton.m
//  MineRCON
//
//  Created by Conrad Kramer on 10/24/12.
//  Copyright (c) 2012 Conrad Kramer. All rights reserved.
//

#import "MCEjectButton.h"

@implementation MCEjectButton

- (void)drawRect:(CGRect)rect {    
    // Set color
    UIColor *ejectColor = (self.state == UIControlStateHighlighted) ? [UIColor whiteColor] : [UIColor blackColor];
    [ejectColor setFill];
    [ejectColor setStroke];
    
    // Draw triangle
    UIBezierPath *trianglePath = [UIBezierPath bezierPath];
    [trianglePath moveToPoint:CGPointMake(7.5, 1)];
    [trianglePath addLineToPoint:CGPointMake(1, 7)];
    [trianglePath addLineToPoint:CGPointMake(14, 7)];
    [trianglePath closePath];
    trianglePath.lineWidth = 1;
    [trianglePath fill];
    [trianglePath stroke];
    
    // Draw rectangle
    UIBezierPath *rectanglePath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 10, 15, 2)];
    rectanglePath.lineWidth = 1;
    [rectanglePath fill];
    [rectanglePath stroke];
    
    if (self.touchInside) {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        NSArray *gradientColors = @[ (id)[UIColor colorWithWhite:1.0f alpha:1.0f].CGColor, (id)[UIColor colorWithWhite:1.0f alpha:0.0f].CGColor ];
        CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)(gradientColors), NULL);
        
        CGContextSaveGState(context);
        CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
        CGContextDrawRadialGradient(context, gradient, center, 1, center, 6, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
        CGContextRestoreGState(context);
            
        CGGradientRelease(gradient);
        CGColorSpaceRelease(colorSpace);
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    
    UITableViewCell * (^__block getTableCell)(UIView *) = ^(UIView *view) {
        UIView *superview = view.superview;
        
        if ([superview isKindOfClass:[UITableViewCell class]]) {
            return (UITableViewCell *)superview;
        } else if (superview) {
            return getTableCell(superview);
        } else {
            return (UITableViewCell *)nil;
        }
    };
    
    UITableViewCell *cell = getTableCell(self);
    highlighted = cell ? cell.selected : highlighted;
    
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

- (CGSize)intrinsicContentSize {    
    return CGSizeMake(15, 12);
}

@end
