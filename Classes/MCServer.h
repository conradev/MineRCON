//
//  MCServer.h
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

// KVO
extern NSString * const MCServerNameKey;
extern NSString * const MCServerHostnameKey;
extern NSString * const MCServerPasswordKey;
extern NSString * const MCServerPortKey;

@interface MCServer : NSObject <NSCoding>

@property (strong, nonatomic) NSString *name;

@property (strong, nonatomic) NSString *hostname;
@property (strong, nonatomic) NSString *password;
@property (nonatomic) NSInteger port;

- (NSString *)displayName;

@end
