//
//  ViewController.m
//  LiveControl
//
//  Created by fy on 2017/4/25.
//  Copyright © 2017年 LY. All rights reserved.
//

#import "ConnectViewController.h"
#import "AsyncSocketManager.h"

NSInteger const SocketPort = 9001;
NSString *const kLIVE_NEXT = @"APP_REQ_NEXT_SCENE";
NSString *const kLIVE_SIGNUP = @"APP_REQ_MACHINE_SIGNUP_PLAYER";
NSString *const kLIVE_SWITCH = @"APP_REQ_SWITCH_PLAYER_LIVE_VIDEO";
NSString *const hostIP = @"192.168.1.219";

CGFloat const timeOut = 1.0;

@interface ConnectViewController ()<SocketReceiveMessageDelegate>

@property (nonatomic, strong) UITextField *IPTextField;
@property (nonatomic, strong) UIButton *connectButton;

@property (nonatomic, strong) AsyncSocketManager *socketManager;


@end

@implementation ConnectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //初始化 socket 的配置信息
    [AsyncSocketManager sharedManager].socketIPHost = hostIP;
    [AsyncSocketManager sharedManager].receiveMessageDelegate = self;
    [AsyncSocketManager sharedManager].socketPort = SocketPort;
    [AsyncSocketManager sharedManager].timeout = timeOut;
    [[AsyncSocketManager sharedManager] createSocket];
    
    [self createUI];
    [self forTest];
}

- (void)createUI {
    
    UIImageView *topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20.f, ScreenWidth, 44.f)];
    [topImageView setImage:[UIImage imageNamed:@"biaoqianlan"]];
    [self.view addSubview:topImageView];
    
    CGFloat lineHeight = ScreenHeight*19.5/128.f;
    CGFloat addjustHeight = 45.f;
    
    for (int i = 0; i < 4; i++) {
        UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, ScreenHeight*7.2/128+i*lineHeight+addjustHeight, ScreenWidth*15/75, ScreenWidth*15/75)];
        NSString *imageName = [NSString stringWithFormat:@"headImage%d", i];
        UIImage *headImage = [UIImage imageNamed:imageName];
        headImageView.image = headImage;
        [self.view addSubview:headImageView];
        
        UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeSystem];
        refreshButton.frame = CGRectMake(ScreenWidth*37/75, ScreenHeight*12.6/128+i*lineHeight+addjustHeight, ScreenWidth*16/75, ScreenHeight*6/128);
        refreshButton.layer.borderWidth = 1.f;
        refreshButton.layer.cornerRadius = 5.f;
        refreshButton.clipsToBounds = YES;
        refreshButton.layer.borderColor = [UIColor redColor].CGColor;
        [refreshButton setTitle:@"刷新" forState:UIControlStateNormal];
        [refreshButton.titleLabel setFont:[UIFont systemFontOfSize:ScreenHeight*3/128.f]];
        [refreshButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.view addSubview:refreshButton];
        [refreshButton addTarget:self action:@selector(refreshButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        refreshButton.tag = 100+10*i+1;
        

        UIButton *switchButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [switchButton setFrame:CGRectMake(ScreenWidth*55/75, ScreenHeight*12.6/128+i*lineHeight+addjustHeight, ScreenWidth*16/75, ScreenHeight*6/128)];
        switchButton.layer.borderWidth = 1.f;
        switchButton.layer.cornerRadius = 5.f;
        switchButton.clipsToBounds = YES;
        switchButton.layer.borderColor = [UIColor redColor].CGColor;
        [switchButton setTitle:@"切换" forState:UIControlStateNormal];
        [switchButton.titleLabel setFont:[UIFont systemFontOfSize:ScreenHeight*3/128.f]];
        [switchButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];

        [self.view addSubview:switchButton];
        [switchButton addTarget:self action:@selector(switchButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        switchButton.tag = 100+10*i+2;
        
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth*11/75, ScreenHeight*24/128+i*lineHeight+addjustHeight, ScreenWidth*63/75, 1)];
        bottomLine.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:bottomLine];
        
    }
    
    for (int i = 0; i < 2; i++) {
        
        UIButton *nextStepButton = [UIButton buttonWithType:UIButtonTypeSystem];
        nextStepButton.frame = CGRectMake(30+ScreenWidth*i/2, ScreenHeight*92/128, ScreenWidth/2-60, 40);
        

        
        [nextStepButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        if (i == 0) {
//            [nextStepButton setTitle:@"复位" forState:UIControlStateNormal];
        }else {
//            [nextStepButton setTitle:@"下一步" forState:UIControlStateNormal];
        }
        [nextStepButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [nextStepButton.titleLabel setFont:[UIFont systemFontOfSize:20.f]];
        [nextStepButton addTarget:self action:@selector(nextStepButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        nextStepButton.tag = 200+i;
        [self.view addSubview:nextStepButton];
    }
}


- (void)refreshButtonClick:(UIButton *)button {
    
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
    
    [[AsyncSocketManager sharedManager] socketConnectHost];
    NSDictionary *dict = @{@"cmd":kLIVE_NEXT};
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    [[AsyncSocketManager sharedManager] sendMessage:data];
    if (button.tag == 200) {
        
    }else {
    
    }
    
}

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
    [AsyncSocketManager sharedManager].timeout = 0.5;
    [[AsyncSocketManager sharedManager] socketConnectHost];
    
}

- (void)onSocketReceiveMessage:(NSString *)message {
    self.IPTextField.text = message;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
