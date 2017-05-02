//
//  AsyncSocketManager.m
//  LiveControl
//
//  Created by fy on 2017/4/26.
//  Copyright © 2017年 LY. All rights reserved.
//

#import "AsyncSocketManager.h"

@interface AsyncSocketManager ()<AsyncSocketDelegate>

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
}


//连接
- (void)socketConnectHost {
    
     if ([self.socket isConnected]) {
        [self.socket disconnect];
    }
    
    [self.socket connectToHost:self.socketIPHost onPort:self.socketPort withTimeout:self.timeout error:nil];
}

//发送完消息后 断开连接
- (void)disconnect {
    if ([self.socket isConnected]) {
        [self.socket disconnect];
    }
}

#pragma mark - SocketDelegate

- (void)sendMessage:(NSData *)data {
    
    [self.socket writeData:data withTimeout:-1 tag:0];
}


- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket {
    NSLog(@"didAcceptNewSocket");
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    NSLog(@"didConnectToHost");
    [self.socket readDataWithTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err {
    NSLog(@"%@", err);
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock {
    NSLog(@"didDisconnect");
}


- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    
    if ([self.receiveMessageDelegate respondsToSelector:@selector(onSocketReceiveDictionary:)]) {
        [self.receiveMessageDelegate onSocketReceiveDictionary:dict];
    }
    [self.socket readDataWithTimeout:-1 tag:0];

    
    //收到消息后 断开连接 下一次重新连接
    [self disconnect];
}


@end
