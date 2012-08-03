//
//  MCRCONClient.m
//  MineRCON
//
//  Created by Conrad Kramer on 8/1/12.
//  Copyright (c) 2012 Kramer Software Productions, LLC. All rights reserved.
//

#import "MCRCONClient.h"

#import "GCDAsyncSocket.h"

#define AUTH_TAG 1

typedef enum RCONPacketType {
    RCONUnknown = 0,
    RCONAuthentication = 3,
    RCONCommand = 2
} RCONPacketType;

NSString * const MCRCONErrorDomain = @"MCRCONErrorDomain";

NSString * const kMCRCONPayloadKey = @"MCRCONPayloadKey";
NSString * const kMCRCONTagKey = @"MCRCONTagKey";
NSString * const kMCRCONPacketTypeKey = @"MCRCONPacketTypeKey";

@interface MCRCONClient () {
    GCDAsyncSocket *_socket;
    NSInteger _currentTag;
    
    void (^_connectCallback)(BOOL success, NSError *error);
    void (^_commandCallback)(NSAttributedString *response, NSError *error);
}

@property (readwrite) MCRCONClientState state;

@end

static NSDictionary *colorsDict;

__attribute__((constructor))
static void initializeColors() {
    colorsDict = @{ @"0" : [UIColor colorWithRed:(0.0f/255.0f) green:(0.0f/255.0f) blue:(0.0f/255.0f) alpha:1.0f],
                    @"1" : [UIColor colorWithRed:(0.0f/255.0f) green:(0.0f/255.0f) blue:(170.0f/255.0f) alpha:1.0f],
                    @"2" : [UIColor colorWithRed:(0.0f/255.0f) green:(170.0f/255.0f) blue:(0.0f/255.0f) alpha:1.0f],
                    @"3" : [UIColor colorWithRed:(0.0f/255.0f) green:(170.0f/255.0f) blue:(170.0f/255.0f) alpha:1.0f],
                    @"4" : [UIColor colorWithRed:(170.0f/255.0f) green:(0.0f/255.0f) blue:(0.0f/255.0f) alpha:1.0f],
                    @"5" : [UIColor colorWithRed:(170.0f/255.0f) green:(0.0f/255.0f) blue:(170.0f/255.0f) alpha:1.0f],
                    @"6" : [UIColor colorWithRed:(255.0f/255.0f) green:(170.0f/255.0f) blue:(0.0f/255.0f) alpha:1.0f],
                    @"7" : [UIColor colorWithRed:(170.0f/255.0f) green:(170.0f/255.0f) blue:(170.0f/255.0f) alpha:1.0f],
                    @"8" : [UIColor colorWithRed:(85.0f/255.0f) green:(85.0f/255.0f) blue:(85.0f/255.0f) alpha:1.0f],
                    @"9" : [UIColor colorWithRed:(85.0f/255.0f) green:(85.0f/255.0f) blue:(255.0f/255.0f) alpha:1.0f],
                    @"a" : [UIColor colorWithRed:(85.0f/255.0f) green:(255.0f/255.0f) blue:(85.0f/255.0f) alpha:1.0f],
                    @"b" : [UIColor colorWithRed:(85.0f/255.0f) green:(255.0f/255.0f) blue:(255.0f/255.0f) alpha:1.0f],
                    @"c" : [UIColor colorWithRed:(255.0f/255.0f) green:(85.0f/255.0f) blue:(85.0f/255.0f) alpha:1.0f],
                    @"d" : [UIColor colorWithRed:(255.0f/255.0f) green:(85.0f/255.0f) blue:(255.0f/255.0f) alpha:1.0f],
                    @"e" : [UIColor colorWithRed:(255.0f/255.0f) green:(255.0f/255.0f) blue:(85.0f/255.0f) alpha:1.0f],
                    @"f" : [UIColor colorWithRed:(255.0f/255.0f) green:(255.0f/255.0f) blue:(255.0f/255.0f) alpha:1.0f]
                   };
}

@implementation MCRCONClient

+ (NSAttributedString *)attributedStringForResponse:(NSString *)response {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    
    NSMutableAttributedString *attributedResponse = [[NSMutableAttributedString alloc] init];
    
    NSArray *chunks = [response componentsSeparatedByString:@"§"];
    [chunks enumerateObjectsUsingBlock:^(NSString *chunk, NSUInteger idx, BOOL *stop) {
        
        // Range of chunk
        NSRange range = [response rangeOfString:chunk];
        
        if (range.location == NSNotFound || !chunk.length)
            return;
        
        // Include separator, if one exists
        if (range.location > 0) {
            range.location -= 1;
            range.length += 1;
        }
        
        // Only proceed if separator exists
        if (range.length >= 2 && [[response substringWithRange:range] hasPrefix:@"§"]) {
            
            // Exclude separator
            range.location += 1;
            range.length -= 1;
            
            // Get format specifier
            NSRange specifierRange = range;
            specifierRange.length = 1;
            NSString *formatSpecifier = [[response substringWithRange:specifierRange] lowercaseString];
            
            // Exclude format specifier from string
            range.location += 1;
            range.length -= 1;
            
            // Modify attributes based on format specifier
            UIColor *color = colorsDict[formatSpecifier];
            if (color) {
                [attributes setObject:color forKey:NSForegroundColorAttributeName];
            }
        }
        
        // Append the attributed chunk to the total attributed response
        NSString *contentString = [response substringWithRange:range];
        NSAttributedString *attributedChunk = [[NSAttributedString alloc] initWithString:contentString attributes:attributes];
        [attributedResponse appendAttributedString:attributedChunk];
    }];
    
    return attributedResponse;
}

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
        _state = MCRCONClientDisconnectedState;
        _currentTag = AUTH_TAG + 1;
        _server = server;
        
        [_server addObserver:self forKeyPath:@"hostname" options:NSKeyValueObservingOptionNew context:nil];
        [_server addObserver:self forKeyPath:@"password" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc {
    [_server removeObserver:self forKeyPath:@"hostname"];
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
        if (_state == MCRCONClientExecutingState || _state == MCRCONClientReadyState) {
            if (callback) {
                callback(YES, nil);
            }
            return;
        }
        
        if (_state == MCRCONClientDisconnectedState) {
            NSError *error = nil;
            if (![_socket connectToHost:_server.hostname onPort:_server.port withTimeout:30 error:&error]) {
                if (callback)
                    callback(NO, error);
                return;
            }
            
            self.state = MCRCONClientConnectingState;
        }
        
        if (_state == MCRCONClientConnectingState || _state == MCRCONClientAuthenticatingState) {
            if (callback) {
                _connectCallback = callback;
            }
        }
    }
}

- (void)sendCommand:(NSString *)command callback:(void(^)(NSAttributedString *response, NSError *error))callback {
    @synchronized (self) {
        if (_state == MCRCONClientReadyState) {
            NSDictionary *dictionary = @{ kMCRCONTagKey : @(_currentTag), kMCRCONPacketTypeKey : @(RCONCommand), kMCRCONPayloadKey : command };
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
    NSDictionary *dictionary = @{ kMCRCONTagKey : @(AUTH_TAG), kMCRCONPacketTypeKey : @(RCONAuthentication), kMCRCONPayloadKey : _server.password };
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
    NSAssert(_state == MCRCONClientExecutingState || _state == MCRCONClientAuthenticatingState, @"Received unexpected data! (Tag %ld)", readTag);
    
    NSDictionary *packetDict = [self dictionaryFromPacket:data];
    NSString *payload = packetDict[kMCRCONPayloadKey];
    int type = [packetDict[kMCRCONPacketTypeKey] intValue];
    int tag = [packetDict[kMCRCONTagKey] intValue];
    
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
            NSAttributedString *string = [MCRCONClient attributedStringForResponse:payload];
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

#pragma mark - Packet construction

- (NSData *)packetFromDictionary:(NSDictionary *)dictionary error:(NSError **)error {
    
    // Ensure the payload can be encoded into UTF-8
    NSString *payloadString = dictionary[kMCRCONPayloadKey];
    if (![payloadString canBeConvertedToEncoding:NSUTF8StringEncoding]) {
        *error = [NSError errorWithDomain:MCRCONErrorDomain code:MCRCONErrorCannotEncodePayload userInfo:@{ NSLocalizedDescriptionKey : @"The payload that you attempted to send was not able to be converted to UTF-8 encoding." }];
        return nil;
    }
    
    // Ensure the payload is not too long
    const char* payload = [payloadString cStringUsingEncoding:NSUTF8StringEncoding];
    if (strlen(payload) > 1446) {
        *error = [NSError errorWithDomain:MCRCONErrorDomain code:MCRCONErrorPayloadTooLarge userInfo:@{ NSLocalizedDescriptionKey : @"The payload that you attempted to send was too large." }];
        return nil;
    }
    
    int tag = [dictionary[kMCRCONTagKey] intValue];
    int type = [dictionary[kMCRCONPacketTypeKey] intValue];
    
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
        if (strlen(payload) > 0) {
            // Weird encoding issue - color character is 0xFFFFFFA7 (how is that possible?), when it should be 0xA7
            payloadString = [[NSString alloc] initWithBytesNoCopy:(void *)payload length:payloadLength encoding:NSISOLatin1StringEncoding freeWhenDone:YES];
        }
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:@(type), kMCRCONPacketTypeKey, @(tag), kMCRCONTagKey, payloadString, kMCRCONPayloadKey, nil];
}

@end