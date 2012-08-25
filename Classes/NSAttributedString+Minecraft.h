//
//  NSAttributedString+Minecraft.h
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const MCFormatIndicator;

extern NSString * const MCFormatSpecifierReset;

extern NSString * const MCFormatSpecifierBold;
extern NSString * const MCFormatSpecifierStrike;
extern NSString * const MCFormatSpecifierUnderline;
extern NSString * const MCFormatSpecifierItalics;

@interface NSAttributedString (Minecraft)

+ (NSDictionary *)defaultMinecraftAttributes;

+ (NSAttributedString *)attributedStringWithMinecraftString:(NSString *)string;

@end