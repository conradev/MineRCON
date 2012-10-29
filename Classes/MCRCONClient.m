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

#import "DDLog.h"

#define AUTH_TAG 1

typedef enum RCONPacketType {
    RCONUnknown = 0,
    RCONAuthentication = 3,
    RCONCommand = 2
} RCONPacketType;

extern int ddLogLevel;

NSString * const MCRCONErrorDomain = @"MCRCONErrorDomain";

// KVO
NSString * const MCRCONClientStateKey = @"state";

// NSNotificationCenter
NSString * const MCRCONClientStateWillChangeNotification = @"MCRCONClientStateWillChangeNotification";
NSString * const MCRCONClientStateDidChangeNotification = @"MCRCONClientStateDidChangeNotification";

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
        
        [_server addObserver:self forKeyPath:MCServerHostnameKey options:NSKeyValueObservingOptionNew context:nil];
        [_server addObserver:self forKeyPath:MCServerPortKey options:NSKeyValueObservingOptionNew context:nil];
        [_server addObserver:self forKeyPath:MCServerPasswordKey options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc {
    [_server removeObserver:self forKeyPath:MCServerHostnameKey];
    [_server removeObserver:self forKeyPath:MCServerPortKey];
    [_server removeObserver:self forKeyPath:MCServerPasswordKey];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isEqual:_server]) {
        DDLogWarn(@"(%@): Disconnecting due to key value change (%@) in server object: %@", self, change, _server);
        [self disconnect];
    }
}

- (void)willChangeValueForKey:(NSString *)key {
    if ([key isEqualToString:MCRCONClientStateKey]) {
        DDLogInfo(@"(%@): Posting state will change notification", self);
        [[NSNotificationCenter defaultCenter] postNotificationName:MCRCONClientStateWillChangeNotification object:self];
    }
    
    [super willChangeValueForKey:key];
}

- (void)didChangeValueForKey:(NSString *)key {
    [super didChangeValueForKey:key];
    
    if ([key isEqualToString:MCRCONClientStateKey]) {
        DDLogInfo(@"(%@): Posting state did change notification", self);
        [[NSNotificationCenter defaultCenter] postNotificationName:MCRCONClientStateDidChangeNotification object:self];
    }
}

#pragma mark - Public methods

- (void)connect:(void(^)(BOOL success, NSError *error))origCallback {
    @synchronized (self) {
        DDLogInfo(@"(%@): Connecting to server: %@:%i", self, _server.hostname, _server.port);
        
        // Wrap block for error logging
        __weak MCRCONClient *weakSelf = self;
        void (^callback)(BOOL, NSError *) = ^(BOOL success, NSError *error) {
            if (error) {
                DDLogError(@"(%@): Connection to server \"%@:%i\" failed with error: %@", weakSelf, weakSelf.server.hostname, weakSelf.server.port, error);
            } else if (success) {
                DDLogInfo(@"(%@) Connection and authentication with server \"%@:%i\" was successful", weakSelf, weakSelf.server.hostname, weakSelf.server.port);
            }
            origCallback(success, error);
        };
        
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

- (void)sendCommand:(NSString *)command callback:(void(^)(NSAttributedString *response, NSError *error))origCallback {
    @synchronized (self) {
        DDLogInfo(@"(%@): Sending command: %@", self, command);

        // Wrap block for error logging
        __weak MCRCONClient *weakSelf = self;
        void (^callback)(NSAttributedString *, NSError *) = ^(NSAttributedString *response, NSError *error) {
            if (error) {
                DDLogError(@"(%@): Sending commpand \"%@\" failed with error: %@", weakSelf, command, error);
            } else if (response) {
                DDLogInfo(@"(%@): Sending commpand \"%@\" was successful", weakSelf, command);
            }
            origCallback(response, error);
        };
        
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
    DDLogInfo(@"(%@): Ordering socket to disconnect", self);
    [_socket disconnect];
    self.state = MCRCONClientDisconnectedState;
}

#pragma mark - Socket delegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    NSError *error = nil;
    NSDictionary *dictionary = @{ MCRCONTagKey : @(AUTH_TAG), MCRCONPacketTypeKey : @(RCONAuthentication), MCRCONPayloadKey : _server.password };
    NSData *data = [self packetFromDictionary:dictionary error:&error];
    
    DDLogInfo(@"(%@): Socket connected to host: %@:%i", self, host, port);
    
    if (data) {
        DDLogInfo(@"(%@): Sending authentication packet", self);

        self.state = MCRCONClientAuthenticatingState;

        [_socket writeData:data withTimeout:30 tag:AUTH_TAG];
        [_socket readDataWithTimeout:30 tag:AUTH_TAG];        
    } else {
        DDLogError(@"(%@): Socket authentication failed with error: %@", self, error);

        [self disconnect];

        if (_connectCallback) {
            _connectCallback(NO, error);
            _connectCallback = nil;
        }
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)error {
    if (error) {
        DDLogError(@"(%@): Socket disconnected with error: %@", self, error);
        if (_connectCallback) {
            _connectCallback(NO, error);
        } else if (_commandCallback) {
            _commandCallback(nil, error);
        }
    } else {
        DDLogInfo(@"(%@): Socket disconnected without error", self);
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
        NSError *errorObj = [NSError errorWithDomain:MCRCONErrorDomain code:MCRCONErrorPayloadTooLarge userInfo:@{ NSLocalizedDescriptionKey : @"The payload that you attempted to send was too large." }];
        DDLogError(@"(%@): Error constructing packet: %@", self, errorObj);

        if (error) {
            *error = errorObj;
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
    
    NSData *data = [NSData dataWithBytesNoCopy:packet length:totalLength];
    
    if (type != RCONAuthentication) {
        DDLogInfo(@"(%@): Successfully constructed dictionary %@ into packet data %@", self, dictionary, data);
    }
    
    return data;
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
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@(type), MCRCONPacketTypeKey, @(tag), MCRCONTagKey, payloadString, MCRCONPayloadKey, nil];
    DDLogInfo(@"(%@): Successfully deconstructed packet data %@ into dictionary %@", self, data, dictionary);

    return dictionary;
}

@end