//
//  UIColor+Minecraft.h
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Minecraft)

+ (UIColor *)foregroundColorForMinecraftSpecifier:(NSString *)specifier;
+ (UIColor *)backgroundColorForMinecraftSpecifier:(NSString *)specifier;

+ (UIColor *)minecraftInterfaceForegroundColor;
+ (UIColor *)minecraftInterfaceBackgroundColor;

+ (UIColor *)minecraftSelectedInterfaceForegroundColor;
+ (UIColor *)minecraftSelectedInterfaceBackgroundColor;

+ (UIColor *)minecraftSecondaryInterfaceForegroundColor;
+ (UIColor *)minecraftSecondaryInterfaceBackgroundColor;

@end
