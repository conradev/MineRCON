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

+ (NSDictionary *)_minecraftAttributesForSpecifier:(NSString *)specifier {
    if (specifier.length != 1) {
        specifier = MCFormatSpecifierReset;
    }
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:@{ NSFontAttributeName : [UIFont fontWithName:@"Minecraft" size:16.0f] }];
    
    if ([specifier isEqualToString:MCFormatSpecifierBold]) {
        // We got nothing, folks!
    } else if ([specifier isEqualToString:MCFormatSpecifierItalics]) {
        // We got nothing, folks!
    } else if ([specifier isEqualToString:MCFormatSpecifierStrike]) {
        attributes[NSStrikethroughStyleAttributeName] = @(NSUnderlineStyleSingle);
    } else if ([specifier isEqualToString:MCFormatSpecifierUnderline]) {
        attributes[NSUnderlineStyleAttributeName] = @(NSUnderlineStyleSingle);
    } else {
        UIColor *foregroundColor = [UIColor foregroundColorForMinecraftSpecifier:specifier];
        if (foregroundColor) {
            attributes[NSForegroundColorAttributeName] = foregroundColor;
        }
        
        UIColor *backgroundColor = [UIColor backgroundColorForMinecraftSpecifier:specifier];
        if (backgroundColor) {
            NSShadow *shadow = [[NSShadow alloc] init];
            shadow.shadowOffset = CGSizeMake(2, 2);
            shadow.shadowColor = backgroundColor;
            attributes[NSShadowAttributeName] = shadow;
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:attributes];
}

+ (NSDictionary *)defaultMinecraftAttributes {
    return [self _minecraftAttributesForSpecifier:nil];
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
