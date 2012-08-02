//
//  MCServer.h
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCServer : NSObject <NSCoding>

@property (strong, nonatomic) NSString *name;

@property (readonly, strong, nonatomic) NSString *uuid;

@property (strong, nonatomic) NSString *hostname;
@property (strong, nonatomic) NSString *password;
@property (nonatomic) NSInteger port;

@end
