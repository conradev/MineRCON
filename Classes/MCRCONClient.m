//
//  MCRCONClient.m
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import "MCRCONClient.h"

#import "GCDAsyncSocket.h"
#import "NSAttributedString+Minecraft.h"

#define AUTH_TAG 1

typedef enum RCONPacketType {
    RCONUnknown = 0,
    RCONAuthentication = 3,
    RCONCommand = 2
} RCONPacketType;

NSString * const MCRCONErrorDomain = @"MCRCONErrorDomain";

// KVO
NSString * const MCRCONClientStateKey = @"state";

// Packet construction
NSString * const MCRCONPayloadKey = @"MCRCONPayloadKey";
NSString * const MCRCONTagKey = @"MCRCONTagKey";
NSString * const MCRCONPacketTypeKey = @"MCRCONPacketTypeKey";

@interface MCRCONClient () {
    GCDAsyncSocket *_socket;
    NSInteger _currentTag;
    
    void (^_connectCallback)(BOOL success, NSError *error);
    void (^_commandCallback)(NSAttributedString *response, NSError *error);
}

@property (readwrite) MCRCONClientState state;

@end

@implementation MCRCONClient

- (id)init {
    self = nil;
    return self;
}

- (id)initWithServer:(MCServer *)server {
    if (!server) {
        self = nil;
        return self;
    }
    
    if ((self = [super init])) {
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        self.state = MCRCONClientDisconnectedState;
        _currentTag = AUTH_TAG + 1;
        _server = server;
        
        [_server addObserver:self forKeyPath:@"hostname" options:NSKeyValueObservingOptionNew context:nil];
        [_server addObserver:self forKeyPath:@"port" options:NSKeyValueObservingOptionNew context:nil];
        [_server addObserver:self forKeyPath:@"password" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc {
    [_server removeObserver:self forKeyPath:@"hostname"];
    [_server removeObserver:self forKeyPath:@"port"];
    [_server removeObserver:self forKeyPath:@"password"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isEqual:_server]) {
        [self disconnect];
    }
}

#pragma mark - Public methods

- (void)connect:(void(^)(BOOL success, NSError *error))callback {
    @synchronized (self) {
        if (self.state == MCRCONClientExecutingState || self.state == MCRCONClientReadyState) {
            if (callback) {
                callback(YES, nil);
            }
            return;
        }
        
        if (self.state == MCRCONClientDisconnectedState) {
            NSError *error = nil;
            if (![_socket connectToHost:_server.hostname onPort:_server.port withTimeout:30 error:&error]) {
                if (callback)
                    callback(NO, error);
                return;
            }
            
            self.state = MCRCONClientConnectingState;
        }
        
        if (self.state == MCRCONClientConnectingState || self.state == MCRCONClientAuthenticatingState) {
            if (callback) {
                _connectCallback = callback;
            }
        }
    }
}

- (void)sendCommand:(NSString *)command callback:(void(^)(NSAttributedString *response, NSError *error))callback {
    @synchronized (self) {
        if (self.state == MCRCONClientReadyState) {
            NSDictionary *dictionary = @{ MCRCONTagKey : @(_currentTag), MCRCONPacketTypeKey : @(RCONCommand), MCRCONPayloadKey : command };
            NSError *error = nil;
            NSData *data = [self packetFromDictionary:dictionary error:&error];
            if (error) {
                if (callback) {
                    callback(nil, error);
                }
                return;
            }
            
            [_socket writeData:data withTimeout:30 tag:_currentTag];
            [_socket readDataWithTimeout:30 tag:_currentTag];
            _currentTag++;
            
            _commandCallback = callback;
            
            self.state = MCRCONClientExecutingState;
        }
    }
}

- (void)disconnect {
    [_socket disconnect];
    self.state = MCRCONClientDisconnectedState;
}

#pragma mark - Socket delegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    NSError *error = nil;
    NSDictionary *dictionary = @{ MCRCONTagKey : @(AUTH_TAG), MCRCONPacketTypeKey : @(RCONAuthentication), MCRCONPayloadKey : _server.password };
    NSData *data = [self packetFromDictionary:dictionary error:&error];
    
    if (data) {
        self.state = MCRCONClientAuthenticatingState;

        [_socket writeData:data withTimeout:30 tag:AUTH_TAG];
        [_socket readDataWithTimeout:30 tag:AUTH_TAG];        
    } else {
        [self disconnect];

        if (_connectCallback) {
            _connectCallback(NO, error);
            _connectCallback = nil;
        }
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)error {
    if (error) {
        if (_connectCallback) {
            _connectCallback(NO, error);
        } else if (_commandCallback) {
            _commandCallback(nil, error);
        }
    }
    
    _connectCallback = nil;
    _commandCallback = nil;
    
    self.state = MCRCONClientDisconnectedState;
}

- (void)socket:(GCDAsyncSocket *)socket didReadData:(NSData *)data withTag:(long)readTag {
    NSAssert(self.state == MCRCONClientExecutingState || self.state == MCRCONClientAuthenticatingState, @"Received unexpected data! (Tag %ld)", readTag);
    
    NSDictionary *packetDict = [self dictionaryFromPacket:data];
    NSString *payload = packetDict[MCRCONPayloadKey];
    int type = [packetDict[MCRCONPacketTypeKey] intValue];
    int tag = [packetDict[MCRCONTagKey] intValue];
    
    if (tag == -1) {
        NSError *error = [NSError errorWithDomain:MCRCONErrorDomain code:MCRCONErrorUnauthorized userInfo:@{ NSLocalizedDescriptionKey : @"The request was unauthorized." }];
        if (_connectCallback) {
            [self disconnect];
            _connectCallback(NO, error);
        } else if (_commandCallback) {
            _commandCallback(nil, error);
        }
    }
    
    if (type == RCONCommand || type == RCONUnknown) {
        if (tag == AUTH_TAG) {
            self.state = MCRCONClientReadyState;
            if (_connectCallback) {
                _connectCallback(YES, nil);
            }
            _connectCallback = nil;
            return;
        } else if (tag == (int)readTag) {
            NSAttributedString *string = [NSAttributedString attributedStringWithMinecraftString:payload];
            self.state = MCRCONClientReadyState;
            if (_commandCallback) {
                _commandCallback(string, nil);
            }
            _commandCallback = nil;
            return;
        }
    }
    
    _connectCallback = nil;
    _commandCallback = nil;
}

#pragma mark - Packet construction/deconstruction

- (NSData *)packetFromDictionary:(NSDictionary *)dictionary error:(NSError **)error {
    
    // Lossily convert to UTF-8
    NSString *payloadString = dictionary[MCRCONPayloadKey];
    payloadString = [[NSString alloc] initWithData:[payloadString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES] encoding:NSUTF8StringEncoding];
    NSAssert([payloadString canBeConvertedToEncoding:NSUTF8StringEncoding], @"String was not properly converted to UTF-8 encoding");
    
    // Ensure the payload is not too long
    const char* payload = [payloadString cStringUsingEncoding:NSUTF8StringEncoding];
    if (strlen(payload) > 1446) {
        if (error) {
            *error = [NSError errorWithDomain:MCRCONErrorDomain code:MCRCONErrorPayloadTooLarge userInfo:@{ NSLocalizedDescriptionKey : @"The payload that you attempted to send was too large." }];
        }
        return nil;
    }
    
    int tag = [dictionary[MCRCONTagKey] intValue];
    int type = [dictionary[MCRCONPacketTypeKey] intValue];
    
    char pad[2];
    pad[0] = 0x00;
    pad[1] = 0x00;
    
    int length = strlen(payload) + 10;
    int totalLength = length + 4;
    
    void *packet = malloc(totalLength);
    memcpy(packet + (0 * sizeof(int)), &length, sizeof(int));
    memcpy(packet + (1 * sizeof(int)), &tag, sizeof(int));
    memcpy(packet + (2 * sizeof(int)), &type, sizeof(int));
    memcpy(packet + (3 * sizeof(int)), payload, strlen(payload));
    memcpy(packet + (3 * sizeof(int)) + strlen(payload), &pad, sizeof(pad));
    
    return [NSData dataWithBytesNoCopy:packet length:totalLength];
}

- (NSDictionary *)dictionaryFromPacket:(NSData *)data {
    int length;
    [data getBytes:&length range:NSMakeRange(0, sizeof(int))];
    
    NSAssert(length == (int)(data.length - sizeof(int)), @"Received payload length (%i) does not match expected payload length (%i)", (int)(data.length - sizeof(int)), length);
    
    int type = 0;
    int tag = 0;
    
    int payloadLength = length - 10;
    const char *payload = malloc(payloadLength);
    
    [data getBytes:&tag range:NSMakeRange((1 * sizeof(int)), sizeof(int))];
    [data getBytes:&type range:NSMakeRange((2 * sizeof(int)), sizeof(int))];
    [data getBytes:(void *)payload range:NSMakeRange((3 * sizeof(int)), payloadLength)];
    
    NSString *payloadString = nil;
    if (payload) {
        // TODO: Look into weird encoding issue - color character is 0xFFFFFFA7 (how is that possible?), when it should be 0xA7
        payloadString = [[NSString alloc] initWithBytesNoCopy:(void *)payload length:payloadLength encoding:NSISOLatin1StringEncoding freeWhenDone:YES];
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:@(type), MCRCONPacketTypeKey, @(tag), MCRCONTagKey, payloadString, MCRCONPayloadKey, nil];
}

@end