//
//  ViewController.m
//  LiveControl
//
//  Created by fy on 2017/4/25.
//  Copyright © 2017年 LY. All rights reserved.
//

#import "ConnectViewController.h"
#import "AsyncSocketManager.h"

NSInteger const SocketPort =   9001;
NSString *const kLIVE_NEXT =   @"APP_REQ_NEXT_SCENE";
NSString *const kLIVE_SIGNUP = @"APP_REQ_MACHINE_SIGNUP_PLAYER";
NSString *const kLIVE_SWITCH = @"APP_REQ_SWITCH_PLAYER_LIVE_VIDEO";
NSString *const hostIP =       @"192.168.1.219";
CGFloat   const timeOut =      0.6;

@interface ConnectViewController ()<SocketReceiveMessageDelegate>{
    UIView *_bottomView;
}

@property (nonatomic, strong) UITextField *IPTextField;
@property (nonatomic, strong) UIButton *connectButton;

@end

@implementation ConnectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.navigationController.navigationBar.translucent = NO;
    
    UIImage *barIamge = [[UIImage imageNamed:@"biaoqianlan"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImageView *barIamgeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
    barIamgeView.image = barIamge;
    [self.navigationController.navigationBar addSubview:barIamgeView];
    
    //初始化 socket 的配置信息
    [AsyncSocketManager sharedManager].socketIPHost = hostIP;
    [AsyncSocketManager sharedManager].receiveMessageDelegate = self;
    [AsyncSocketManager sharedManager].socketPort = SocketPort;
    [AsyncSocketManager sharedManager].timeout = timeOut;
    [[AsyncSocketManager sharedManager] createSocket];
    
    [self createUI];
}

- (void)createUI {
    
    CGFloat lineHeight = ScreenHeight*19.5/128.f;
    CGFloat addjustHeight = -10.f;
    
    for (int i = 0; i < 4; i++) {
        UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, ScreenHeight*7.2/128+i*lineHeight+addjustHeight, ScreenWidth*15/75, ScreenWidth*15/75)];
        NSString *imageName = [NSString stringWithFormat:@"headImage%d", i];
        UIImage *headImage = [UIImage imageNamed:imageName];
        headImageView.image = headImage;
        [self.view addSubview:headImageView];
        
        UIButton *refreshButton = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth*37/75, ScreenHeight*11/128+i*lineHeight+addjustHeight, ScreenWidth*16/75, ScreenHeight*6/128)];
        [refreshButton setBackgroundImage:[UIImage imageNamed:@"shuaxinN"] forState:UIControlStateNormal];
        [refreshButton setBackgroundImage:[UIImage imageNamed:@"shuaxinS"] forState:UIControlStateHighlighted];
        refreshButton.adjustsImageWhenHighlighted = NO;

        [self.view addSubview:refreshButton];
        [refreshButton addTarget:self action:@selector(refreshButtonClick:) forControlEvents:UIControlEventTouchDown];
        refreshButton.tag = 100+10*i+1;
        

        UIButton *switchButton = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth*55/75, ScreenHeight*11/128+i*lineHeight+addjustHeight, ScreenWidth*16/75, ScreenHeight*6/128)];
        [switchButton setBackgroundImage:[UIImage imageNamed:@"qiehuanN"] forState:UIControlStateNormal];
        [switchButton setBackgroundImage:[UIImage imageNamed:@"qiehuanS"] forState:UIControlStateHighlighted];
        switchButton.adjustsImageWhenHighlighted = NO;

        [self.view addSubview:switchButton];
        [switchButton addTarget:self action:@selector(switchButtonClick:) forControlEvents:UIControlEventTouchDown];
        switchButton.tag = 100+10*i+2;
        
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth*11/75, ScreenHeight*24/128+i*lineHeight+addjustHeight, ScreenWidth*63/75, 1)];
        bottomLine.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:bottomLine];
    }
    
    for (int i = 0; i < 2; i++) {

        UIButton *nextStepButton = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth*12/75, ScreenHeight*(85.f/128+i*135.f/1280), ScreenWidth*51/75, ScreenHeight*86/1200)];
        nextStepButton.adjustsImageWhenHighlighted = NO;
        if (i == 0) {
            [nextStepButton setBackgroundImage:[UIImage imageNamed:@"fuweiN"] forState:UIControlStateNormal];
            [nextStepButton setBackgroundImage:[UIImage imageNamed:@"fuweiS"] forState:UIControlStateHighlighted];
            [nextStepButton setBackgroundColor:[UIColor lightGrayColor]];
            nextStepButton.userInteractionEnabled = NO;
        }else {
            [nextStepButton setBackgroundImage:[UIImage imageNamed:@"xiayibuN"] forState:UIControlStateNormal];
            [nextStepButton setBackgroundImage:[UIImage imageNamed:@"xiayibuS"] forState:UIControlStateHighlighted];
        }
        
        [nextStepButton addTarget:self action:@selector(nextStepButtonClick:) forControlEvents:UIControlEventTouchDown];
        nextStepButton.tag = 200+i;
        [self.view addSubview:nextStepButton];
    }
    
    _bottomView = [[UIView alloc] initWithFrame:self.view.bounds];
    _bottomView.backgroundColor = [UIColor clearColor];
    _bottomView.userInteractionEnabled = NO;
    [self.view addSubview:_bottomView];
}

- (void)refreshButtonClick:(UIButton *)button {
    
    _bottomView.userInteractionEnabled = YES;
    
    [NSTimer scheduledTimerWithTimeInterval:0.7 target:self selector:@selector(makeBottomViewUenable) userInfo:nil repeats:NO];
    //点击按钮 连接host
    [[AsyncSocketManager sharedManager] socketConnectHost];
    
    NSNumber *index = [[NSNumber alloc] init];
    
    NSInteger tag = button.tag;
    switch (tag) {
        case 101:
            index = @1;
            break;
        case 111:
            index = @2;
            break;
        case 121:
            index = @3;
            break;
        case 131:
            index = @4;
            break;
        default:
            break;
    }
    
    NSDictionary *dict = @{@"cmd":kLIVE_SIGNUP, @"index":index};
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    
    [[AsyncSocketManager sharedManager] sendMessage:data];
    

}

- (void)switchButtonClick:(UIButton *)button {
    
    _bottomView.userInteractionEnabled = YES;
    
    [NSTimer scheduledTimerWithTimeInterval:0.7 target:self selector:@selector(makeBottomViewUenable) userInfo:nil repeats:NO];
    
    NSNumber *number = [[NSNumber alloc] init];
    
    [[AsyncSocketManager sharedManager] socketConnectHost];
    
   
    switch (button.tag) {
        case 102:
            number = @1;
            break;
        case 112:
            number = @2;
            break;
        case 122:
            number = @3;
            break;
        case 132:
            number = @4;
            break;
            
        default:
            break;
    }
    
    NSDictionary *dict = @{@"index":number, @"cmd":kLIVE_SWITCH};
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
     [[AsyncSocketManager sharedManager] sendMessage:data];
    
}

- (void)nextStepButtonClick:(UIButton *)button {
    
    
    _bottomView.userInteractionEnabled = YES;
    
    [NSTimer scheduledTimerWithTimeInterval:0.7 target:self selector:@selector(makeBottomViewUenable) userInfo:nil repeats:NO];
    
    [[AsyncSocketManager sharedManager] socketConnectHost];
    NSDictionary *dict = @{@"cmd":kLIVE_NEXT};
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    
//    if (button.tag == 200) {
//        
//    }else {
//    
//    }
    [[AsyncSocketManager sharedManager] sendMessage:data];
}

- (void)makeBottomViewUenable {
    _bottomView.userInteractionEnabled = NO;
}

#pragma mark - 填写IP地址
- (void)forTest {
    _IPTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, ScreenHeight - 40, ScreenWidth - 100, 30)];
    _IPTextField.borderStyle = UITextBorderStyleLine;
    [self.view addSubview:_IPTextField];
    
    _connectButton = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 80, ScreenHeight - 40, 60, 30)];
    [_connectButton setBackgroundColor:[UIColor purpleColor]];
    [_connectButton setTitle:@"连接" forState:UIControlStateNormal];
    [self.view addSubview:_connectButton];
    [_connectButton addTarget:self action:@selector(connectButtonClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)connectButtonClick:(UIButton *)button {
    [AsyncSocketManager sharedManager].socketIPHost = self.IPTextField.text;
    [AsyncSocketManager sharedManager].socketPort = SocketPort;
    [AsyncSocketManager sharedManager].timeout = timeOut;
    [[AsyncSocketManager sharedManager] socketConnectHost];
}

#pragma mark - 从SocketManager 回调到
- (void)onSocketReceiveDictionary:(NSDictionary *)dict {
    NSLog(@"收到服务器返回数据\n%@", dict);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
