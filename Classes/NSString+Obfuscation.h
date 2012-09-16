//
//  NSString+Obfuscation.h
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

// This category is not designed to defeat reverse engineers (LOL), only Apple's static analyzer.

@interface NSString (Obfuscation)

+ (NSString *)stringByDeobfuscatingString:(NSString *)string;
+ (NSString *)stringByObfuscatingString:(NSString *)string;

@end
