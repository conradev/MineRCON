//
//  NSAttributedString+Minecraft.m
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import "NSAttributedString+Minecraft.h"

#import "UIColor+Minecraft.h"

NSString * const MCFormatIndicator = @"§";

NSString * const MCFormatSpecifierReset = @"r";

NSString * const MCFormatSpecifierBold = @"l";
NSString * const MCFormatSpecifierStrike = @"m";
NSString * const MCFormatSpecifierUnderline = @"n";
NSString * const MCFormatSpecifierItalics = @"o";

@implementation NSAttributedString (Minecraft)

+ (CGFloat)_minecraftInterfaceFontSize {
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? 16.0f : 14.0f;
}

+ (CGFloat)_minecraftTextFontSize {
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? 16.0f : 12.0f;
}

+ (NSDictionary *)_minecraftAttributesWithForegroundColor:(UIColor *)foregroundColor backgroundColor:(UIColor *)backgroundColor fontSize:(CGFloat)fontSize {
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:@{ NSFontAttributeName : [UIFont fontWithName:@"Minecraft" size:fontSize] }];
    
    if (foregroundColor) {
        attributes[NSForegroundColorAttributeName] = foregroundColor;
    }
    
    if (backgroundColor) {
        // A lowercase "x" is five "blocks" high, the shadow should be one "block"
        // below and to the right
        CGFloat offset = [attributes[NSFontAttributeName] xHeight] * (1.0f/5.0f);
        
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowOffset = CGSizeMake(offset, offset);
        shadow.shadowColor = backgroundColor;
        attributes[NSShadowAttributeName] = shadow;
    }
    
    return [NSDictionary dictionaryWithDictionary:attributes];
}

+ (NSDictionary *)_minecraftAttributesForSpecifier:(NSString *)specifier {
    if (specifier.length != 1) {
        specifier = MCFormatSpecifierReset;
    }
    
    UIColor *foregroundColor = [UIColor foregroundColorForMinecraftSpecifier:specifier];
    UIColor *backgroundColor = [UIColor backgroundColorForMinecraftSpecifier:specifier];
    CGFloat fontSize = [self _minecraftTextFontSize];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self _minecraftAttributesWithForegroundColor:foregroundColor backgroundColor:backgroundColor fontSize:fontSize]];
    
    if ([specifier isEqualToString:MCFormatSpecifierBold]) {
        // We got nothing, folks!
        // This would require an additional font
    } else if ([specifier isEqualToString:MCFormatSpecifierItalics]) {
        // We got nothing, folks!
        // This would require an additional font
    } else if ([specifier isEqualToString:MCFormatSpecifierStrike]) {
        attributes[NSStrikethroughStyleAttributeName] = @(NSUnderlineStyleSingle);
    } else if ([specifier isEqualToString:MCFormatSpecifierUnderline]) {
        attributes[NSUnderlineStyleAttributeName] = @(NSUnderlineStyleSingle);
    }
    
    return [NSDictionary dictionaryWithDictionary:attributes];
}

+ (NSDictionary *)defaultMinecraftAttributes {
    return [self _minecraftAttributesForSpecifier:MCFormatSpecifierReset];
}

+ (NSDictionary *)minecraftInterfaceAttributes {
    return [self _minecraftAttributesWithForegroundColor:[UIColor minecraftInterfaceForegroundColor]
                                         backgroundColor:[UIColor minecraftInterfaceBackgroundColor]
                                                fontSize:[self _minecraftInterfaceFontSize]];
}

+ (NSDictionary *)minecraftSelectedInterfaceAttributes {
    return [self _minecraftAttributesWithForegroundColor:[UIColor minecraftSelectedInterfaceForegroundColor]
                                         backgroundColor:[UIColor minecraftSelectedInterfaceBackgroundColor]
                                                fontSize:[self _minecraftInterfaceFontSize]];
}

+ (NSDictionary *)minecraftSecondaryInterfaceAttributes {
    return [self _minecraftAttributesWithForegroundColor:[UIColor minecraftSecondaryInterfaceForegroundColor]
                                         backgroundColor:[UIColor minecraftSecondaryInterfaceBackgroundColor]
                                                fontSize:[self _minecraftInterfaceFontSize]];
}

+ (NSAttributedString *)attributedStringWithMinecraftString:(NSString *)string {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self defaultMinecraftAttributes]];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    
    NSArray *chunks = [string componentsSeparatedByString:MCFormatIndicator];
    [chunks enumerateObjectsUsingBlock:^(NSString *chunk, NSUInteger idx, BOOL *stop) {
        
        // Range of chunk
        NSRange range = [string rangeOfString:chunk];
        
        if (range.location == NSNotFound || !chunk.length)
            return;
        
        // Include separator, if one exists
        if (range.location > 0) {
            range.location -= 1;
            range.length += 1;
        }
        
        // Only proceed if separator exists
        if (range.length >= 2 && [[string substringWithRange:range] hasPrefix:MCFormatIndicator]) {
            
            // Exclude separator
            range.location += 1;
            range.length -= 1;
            
            // Get format specifier
            NSRange specifierRange = range;
            specifierRange.length = 1;
            NSString *formatSpecifier = [[string substringWithRange:specifierRange] lowercaseString];
            
            // Exclude format specifier from string
            range.location += 1;
            range.length -= 1;
            
            if ([formatSpecifier isEqualToString:MCFormatSpecifierReset]) {
                [attributes removeAllObjects];
            }
            
            [attributes addEntriesFromDictionary:[self _minecraftAttributesForSpecifier:formatSpecifier]];
        }
        
        // Append the attributed chunk to the total attributed response
        NSString *contentString = [string substringWithRange:range];
        NSAttributedString *attributedChunk = [[NSAttributedString alloc] initWithString:contentString attributes:attributes];
        [attributedString appendAttributedString:attributedChunk];
    }];
    
    return attributedString;
}

@end
