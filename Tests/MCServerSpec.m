//
//  MCServerSpec.m
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import "Kiwi.h"

#import "MCServer.h"

SPEC_BEGIN(MCServerSpec)

describe(@"MCServer", ^{
    context(@"when newly created", ^{
        
        __block MCServer *server;
        
        NSString *name = @"Name";
        NSString *hostname = @"Hostname";
        NSString *password = @"Password";
        NSInteger port = 1234;
        
        beforeAll(^{
            server = [[MCServer alloc] init];
        });
        
        it(@"should change its name correctly", ^{
            [[name shouldNot] equal:server.name];
            server.name = name;
            [[server.name should] equal:name];
        });
        
        it(@"should change its hostname correctly", ^{
            [[hostname shouldNot] equal:server.hostname];
            server.hostname = hostname;
            [[server.hostname should] equal:hostname];
        });
        
        it(@"should change its password correctly", ^{
            [[password shouldNot] equal:server.password];
            server.password = password;
            [[server.password should] equal:password];
        });
        
        it(@"should change its port correctly", ^{
            [[theValue(port) shouldNot] equal:theValue(server.port)];
            server.port = port;
            [[theValue(server.port) should] equal:theValue(port)];
        });
        
        it(@"should properly encode and decode", ^{

            server = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:server]];
            
            [[server.name should] equal:name];
            [[server.hostname should] equal:hostname];
            [[server.password should] equal:password];
            [[theValue(server.port) should] equal:theValue(port)];
        });
        
    });
});

SPEC_END