//
//  UIColor+Minecraft..m
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import "UIColor+Minecraft.h"

#import "NSAttributedString+Minecraft.h"

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

static NSDictionary *foregroundColors;
static NSDictionary *backgroundColors;

static UIColor *interfaceForegroundColor;
static UIColor *interfaceBackgroundColor;

static UIColor *selectedInterfaceForegroundColor;
static UIColor *selectedInterfaceBackgroundColor;

static UIColor *secondaryInterfaceForegroundColor;
static UIColor *secondaryInterfaceBackgroundColor;

__attribute__((constructor))
static void initialize_minecraft_colors() {
    foregroundColors = @{ @"0" : UIColorFromRGB(0x000000),
                          @"1" : UIColorFromRGB(0x0000AA),
                          @"2" : UIColorFromRGB(0x00AA00),
                          @"3" : UIColorFromRGB(0x00AAAA),
                          @"4" : UIColorFromRGB(0xAA0000),
                          @"5" : UIColorFromRGB(0xAA00AA),
                          @"6" : UIColorFromRGB(0xFFAA00),
                          @"7" : UIColorFromRGB(0xAAAAAA),
                          @"8" : UIColorFromRGB(0x555555),
                          @"9" : UIColorFromRGB(0x5555FF),
                          @"a" : UIColorFromRGB(0x55FF55),
                          @"b" : UIColorFromRGB(0x55FFFF),
                          @"c" : UIColorFromRGB(0xFF5555),
                          @"d" : UIColorFromRGB(0xFF55FF),
                          @"e" : UIColorFromRGB(0xFFFF55),
                          @"f" : UIColorFromRGB(0xFFFFFF) };
    
    backgroundColors = @{ @"0" : UIColorFromRGB(0x000000),
                          @"1" : UIColorFromRGB(0x00002A),
                          @"2" : UIColorFromRGB(0x002A00),
                          @"3" : UIColorFromRGB(0x002A2A),
                          @"4" : UIColorFromRGB(0x2A0000),
                          @"5" : UIColorFromRGB(0x2A002A),
                          @"6" : UIColorFromRGB(0x2A2A00),
                          @"7" : UIColorFromRGB(0x2A2A2A),
                          @"8" : UIColorFromRGB(0x151515),
                          @"9" : UIColorFromRGB(0x15153F),
                          @"a" : UIColorFromRGB(0x153F15),
                          @"b" : UIColorFromRGB(0x153F3F),
                          @"c" : UIColorFromRGB(0x3F1515),
                          @"d" : UIColorFromRGB(0x3F153F),
                          @"e" : UIColorFromRGB(0x3F3F15),
                          @"f" : UIColorFromRGB(0x3F3F3F) };
}

@implementation UIColor (Minecraft)

+ (UIColor *)foregroundColorForMinecraftSpecifier:(NSString *)specifier {
    // Make white the default color
    if ([specifier isEqualToString:MCFormatSpecifierReset]) {
        specifier = @"f";
    }
    
    return foregroundColors[specifier];
}

+ (UIColor *)backgroundColorForMinecraftSpecifier:(NSString *)specifier {
    // Make white the default color
    if ([specifier isEqualToString:MCFormatSpecifierReset]) {
        specifier = @"f";
    }
    
    return backgroundColors[specifier];
}

+ (UIColor *)minecraftInterfaceForegroundColor {
    if (!interfaceForegroundColor) {
        interfaceForegroundColor = UIColorFromRGB(0xE0E0E0);
    }
    
    return interfaceForegroundColor;
}

+ (UIColor *)minecraftInterfaceBackgroundColor {
    if (!interfaceBackgroundColor) {
        interfaceBackgroundColor = UIColorFromRGB(0x383838);
    }
    
    return interfaceBackgroundColor;
}

+ (UIColor *)minecraftSelectedInterfaceForegroundColor {
    if (!selectedInterfaceForegroundColor) {
        selectedInterfaceForegroundColor = UIColorFromRGB(0xFFFFA0);
    }
    
    return selectedInterfaceForegroundColor;
}

+ (UIColor *)minecraftSelectedInterfaceBackgroundColor {
    if (!selectedInterfaceBackgroundColor) {
        selectedInterfaceBackgroundColor = UIColorFromRGB(0x3F3F28);
    }
    
    return selectedInterfaceBackgroundColor;
}

+ (UIColor *)minecraftSecondaryInterfaceForegroundColor {
    if (!secondaryInterfaceForegroundColor) {
        secondaryInterfaceForegroundColor = UIColorFromRGB(0xA0A0A0);
    }
    
    return secondaryInterfaceForegroundColor;
}

+ (UIColor *)minecraftSecondaryInterfaceBackgroundColor {
    if (!secondaryInterfaceBackgroundColor) {
        secondaryInterfaceBackgroundColor = UIColorFromRGB(0x282828);
    }
    
    return secondaryInterfaceBackgroundColor;
}

@end
