//
//  AsyncSocketManager.m
//  LiveControl
//
//  Created by fy on 2017/4/26.
//  Copyright © 2017年 LY. All rights reserved.
//

#import "AsyncSocketManager.h"

@interface AsyncSocketManager ()<AsyncSocketDelegate>

@property (nonatomic, assign) NSInteger connectTimes;
@property (nonatomic, assign) BOOL isTimerRunning;

@end

@implementation AsyncSocketManager

+ (AsyncSocketManager *)sharedManager {
    static AsyncSocketManager *instanceType = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instanceType = [[self alloc] init];
    });
    return instanceType;
}

- (void)createSocket {
    
    self.socket = [[AsyncSocket alloc] initWithDelegate:self];
    
    _connectHostTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(socketConnectHost) userInfo:nil repeats:YES];
    _isTimerRunning = YES;
    _connectTimes = 0;
}


//连接
- (void)socketConnectHost {
    
     if ([self.socket isConnected]) {
        [self.socket disconnect];
    }
    
    [self.socket connectToHost:self.socketIPHost onPort:self.socketPort withTimeout:0.9 error:nil];
    
    _connectTimes++;
    NSString* connectTimesString = [NSString stringWithFormat:@"重连_______%ld次", _connectTimes];
    
    if ([self.receiveMessageDelegate respondsToSelector:@selector(onSocketReceiveMessage:)]) {
        [self.receiveMessageDelegate onSocketReceiveMessage:connectTimesString];
    }
    
}

#pragma mark - SocketDelegate

- (void)sendMessage:(NSString *)message {
    
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket writeData:data withTimeout:-1 tag:0];
}


- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket {
    NSLog(@"didAcceptNewSocket");
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    NSLog(@"didConnectToHost");
    [_connectHostTimer setFireDate:[NSDate distantFuture]];
    _isTimerRunning = NO;
    
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err {
    NSLog(@"%@", err);
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock {
    NSLog(@"didDisconnect");
    if (_isTimerRunning == NO) {
        [_connectHostTimer setFireDate:[NSDate distantPast]];
        _isTimerRunning = YES;
    }
}


- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    [self.socket readDataWithTimeout:-1 tag:0];
}



@end
