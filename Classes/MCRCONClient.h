//
//  MCRCONClient.h
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import "MCServer.h"

enum {
    MCRCONErrorUnknown = -1,
    
    MCRCONErrorPayloadTooLarge = -1000,
    MCRCONErrorCannotEncodePayload = -1001,
    
    MCRCONErrorUnauthorized = -2000
};

extern NSString * const MCRCONErrorDomain;

typedef enum MCRCONClientState {
    MCRCONClientDisconnectedState,
	MCRCONClientConnectingState,
    MCRCONClientAuthenticatingState,
    MCRCONClientExecutingState,
    MCRCONClientReadyState
} MCRCONClientState;

@interface MCRCONClient : NSObject

@property (readonly) MCRCONClientState state;

@property (readonly, strong, nonatomic) MCServer *server;

- (id)initWithServer:(MCServer *)server;

- (void)connect:(void(^)(BOOL success, NSError *error))callback;
- (void)sendCommand:(NSString *)command callback:(void(^)(NSAttributedString *response, NSError *error))callback;
- (void)disconnect;

@end