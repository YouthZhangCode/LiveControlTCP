//
//  AsyncSocketManager.h
//  LiveControl
//
//  Created by fy on 2017/4/26.
//  Copyright © 2017年 LY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"

typedef enum : NSUInteger {
    SocketOfflineByUser,
    SocketOffLineByServer,
} SocketOfflineType;

@protocol SocketReceiveMessageDelegate <NSObject>

- (void)onSocketReceiveMessage:(NSString *)message;

@end

@interface AsyncSocketManager : NSObject

@property (nonatomic, strong) AsyncSocket *socket;
@property (nonatomic, copy) NSString *socketIPHost;
@property (nonatomic, assign) UInt16 socketPort;
@property (nonatomic, assign) CGFloat timeout;
@property (nonatomic, assign) SocketOfflineType offlineType;
@property (nonatomic, assign) NSTimer *connectHostTimer;

@property (nonatomic, weak) id<SocketReceiveMessageDelegate>receiveMessageDelegate;

+ (AsyncSocketManager *)sharedManager;

- (void)createSocket;

//连接
- (void)socketConnectHost;


- (void)sendMessage:(NSString *)message;



@end
