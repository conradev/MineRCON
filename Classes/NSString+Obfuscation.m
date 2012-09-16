//
//  NSString+Obfuscation.m
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import "NSString+Obfuscation.h"
#import "NSData+Base64.h"

static char offset = 1;

static NSString * offsetString(NSString *string, char increment) {
    NSString *output = nil;
    
    NSUInteger bufferSize = [string length] + 1;
    char *buffer = (char *)calloc(bufferSize, sizeof(char));
    
    if ([string getCString:buffer maxLength:bufferSize encoding:NSASCIIStringEncoding]) {
        for (int i = 0; i < strlen(buffer); i++) {
            int character = (int)buffer[i];
            character += increment;
            
            if (character < CHAR_MIN)
                character += (CHAR_MAX - CHAR_MIN);
            if (character > CHAR_MAX)
                character -= (CHAR_MAX - CHAR_MIN);
            
            buffer[i] = (char)character;
        }
        
        output = [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
    }
    free(buffer);
    
    return output;
}

@implementation NSString (Obfuscation)

+ (NSString *)stringByDeobfuscatingString:(NSString *)string {
    // Decrement the ASCII string by a fixed offset, and then convert ASCII into UTF-8 using Base64
    string = offsetString(string, -1 * offset);
    return [[NSString alloc] initWithData:[NSData dataFromBase64String:string] encoding:NSUTF8StringEncoding];
}

+ (NSString *)stringByObfuscatingString:(NSString *)string {
    // Convert UTF-8 into ASCII using Base64, and then increment the ASCII string by a fixed offset
    string = [[string dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString];
    return offsetString(string, offset);
}

@end
