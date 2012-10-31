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
    
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    
    // Draw triangle
    UIBezierPath *trianglePath = [UIBezierPath bezierPath];
    [trianglePath moveToPoint:CGPointMake(center.x, center.y - 5)];
    [trianglePath addLineToPoint:CGPointMake(center.x - 6.5, center.y + 1)];
    [trianglePath addLineToPoint:CGPointMake(center.x + 6.5, center.y + 1)];
    [trianglePath closePath];
    trianglePath.lineWidth = 1.0;
    [trianglePath fill];
    [trianglePath stroke];
    
    // Draw rectangle
    UIBezierPath *rectanglePath = [UIBezierPath bezierPathWithRect:CGRectMake(center.x - 7.5, center.y + 4, 15, 3)];
    [rectanglePath fill];
    
    // Draw touch gradient
    if (self.touchInside) {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        NSArray *gradientColors = @[ (id)[UIColor colorWithWhite:1.0f alpha:1.0f].CGColor, (id)[UIColor colorWithWhite:1.0f alpha:0.0f].CGColor ];
        CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)(gradientColors), NULL);
        
        CGPoint gradientCenter = CGPointMake(center.x, center.y + 2);
        
        CGFloat outerRadius = CGRectGetHeight(rect) - gradientCenter.y;
        if (center.x < outerRadius) {
            outerRadius = center.x;
        }
        
        CGContextDrawRadialGradient(context, gradient, gradientCenter, 1, gradientCenter, outerRadius, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
            
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
    highlighted = cell ? (cell.selected || cell.highlighted) : highlighted;
    
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

- (CGSize)intrinsicContentSize {    
    return CGSizeMake(30, 30);
}

@end
