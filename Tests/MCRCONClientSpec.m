//
//  MCRCONClientSpec.m
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Conrad Kramer. All rights reserved.
//

#import "Kiwi.h"

#import "MCRCONClient.h"

@interface MCRCONClient (Private)
- (NSData *)packetFromDictionary:(NSDictionary *)dictionary error:(NSError **)error;
- (NSDictionary *)dictionaryFromPacket:(NSData *)data;
@end

extern NSString * const MCRCONPayloadKey;
extern NSString * const MCRCONTagKey;
extern NSString * const MCRCONPacketTypeKey;

SPEC_BEGIN(MCRCONClientSpec)

describe(@"MCRCONClient", ^{
    context(@"when newly created", ^{
        
        __block MCRCONClient *client;
        
        beforeAll(^{
            MCServer *server = [MCServer nullMock];
            client = [[MCRCONClient alloc] initWithServer:server];
        });
       
        it(@"should encode and decode packets correctly", ^{
            NSDictionary *packetDict = @{ MCRCONPacketTypeKey : @(2),
                                          MCRCONTagKey : @(1234),
                                          MCRCONPayloadKey : @"This is some payload, aint it?" };
            
            NSError *error = nil;
            NSData *packetData = [client packetFromDictionary:packetDict error:&error];
            
            [error shouldBeNil];
            [[[client dictionaryFromPacket:packetData] should] equal:packetDict];
        });
        
    });
});

SPEC_END