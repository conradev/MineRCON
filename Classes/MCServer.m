//
//  MCServer.m
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import "MCServer.h"

@implementation MCServer

- (id)init {
    if ((self = [super init])) {
        _port = 25575;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [self init])) {
        _name = [coder decodeObjectForKey:@"MCName"];
        _hostname = [coder decodeObjectForKey:@"MCHostname"];
        _password = [coder decodeObjectForKey:@"MCPassword"];
        _port = [coder decodeIntegerForKey:@"MCPort"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_name forKey:@"MCName"];
    [coder encodeObject:_hostname forKey:@"MCHostname"];
    [coder encodeObject:_password forKey:@"MCPassword"];
    [coder encodeInteger:_port forKey:@"MCPort"];
}

@end
