//
//  LVMainVC.m
//  StrangerChat_Example
//
//  Created by Wing on 2020/10/14.
//  Copyright © 2020 wangyansnow. All rights reserved.
//

#import "LVMainVC.h"
#import "MBProgressHUD+LM.h"
#import "StrangerChat.h"
#import <Masonry/Masonry.h>
#import "LVRoomVC.h"
#import "LVHelper.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "LVCallCardView.h"

#import "LVGiftCell.h"
#import "LVGiftView.h"

#import "PresentView.h"
#import "GiftModel.h"
#import "AnimOperation.h"
#import "AnimOperationManager.h"
#import "GSPChatMessage.h"
#import "StrangerChat.h"
#import "MBProgressHUD.h"
#import "AppSign.h"

// 点击https://doc-zh.linkv.sg/platform/info/quick_start 获取你的appId和appSecret

#define RGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
static int linkv_call_overtime = 20;

@interface LVMainVC ()<LVIMModuleEventDelegate, LVIMReceiveMessageDelegate, StrangerChatDelegate, RoomCallbackProtocl>

@property (nonatomic, strong) StrangerChat *engine;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, weak) LVCallCardView *callView;
@property (nonatomic, weak) UIView *lineView;
@property (nonatomic, weak) UIButton *callBtn;
@property (nonatomic, weak) UITextField *uidField;

@property (nonatomic, strong) LVUserModel *user;
@property (nonatomic, strong) LVUserModel *other;
@property (nonatomic, weak) LVRoomVC *roomVC;
@property (nonatomic, assign) BOOL isSDKInit;

@property (nonatomic, strong) NSTimer *receiveCallTimeoutTimer;
@end

@implementation LVMainVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [IQKeyboardManager sharedManager].enable = YES;
    [self initSDK];
    [self setupUI];
    
}

#pragma mark - setupUI
- (void)setupUI {
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"linkv_bg"]];
    UIToolbar *toolbar = [UIToolbar new];
    toolbar.alpha = 0.8;
    
    UIImageView *iconBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_bg"]];
    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.user.avatar]];
    iconView.layer.borderWidth = 1;
    iconView.layer.borderColor = [UIColor whiteColor].CGColor;
    iconView.layer.cornerRadius = 50;
    iconView.clipsToBounds = YES;
    
    UILabel *nameLabel = [UILabel new];
    nameLabel.text = self.user.nickName;
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.font = [UIFont boldSystemFontOfSize:18];
    
    UILabel *idLabel = [UILabel new];
    idLabel.text = [NSString stringWithFormat:@"ID:%@", self.uid];
    idLabel.textColor = RGB(0x7A7A7A);
    idLabel.font = [UIFont systemFontOfSize:14];
    
    UITextField *uidField = [UITextField new];
    uidField.borderStyle = UITextBorderStyleNone;
    uidField.placeholder = @"输入呼叫用户ID";
    uidField.keyboardType = UIKeyboardTypeNumberPad;
    [uidField addTarget:self action:@selector(uidFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    self.uidField = uidField;
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = RGB(0xcdcdcd);
    self.lineView = lineView;
    
    UIButton *callBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [callBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_normal"] forState:UIControlStateNormal];
    [callBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_selected"] forState:UIControlStateSelected];
    [callBtn setImage:[UIImage imageNamed:@"call"] forState:UIControlStateNormal];
    [callBtn setTitle:@"呼叫" forState:UIControlStateNormal];
    [callBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    callBtn.layer.cornerRadius = 20;
    callBtn.clipsToBounds = YES;
    callBtn.adjustsImageWhenHighlighted = NO;
    [callBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 13, 0, 0)];
    [callBtn addTarget:self action:@selector(callBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.callBtn = callBtn;
    
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_ico"]];
    
    [self.view addSubview:iv];
    [self.view addSubview:toolbar];
    [self.view addSubview:iconBg];
    [self.view addSubview:iconView];
    [self.view addSubview:nameLabel];
    [self.view addSubview:idLabel];
    [self.view addSubview:uidField];
    [self.view addSubview:lineView];
    [self.view addSubview:callBtn];
    [self.view addSubview:logo];
    
    CGRect statusRect = [[UIApplication sharedApplication] statusBarFrame];
    CGFloat statusH = statusRect.size.height;
    [iv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view);
        make.top.equalTo(self.view).offset(statusH - 20);
    }];
    
    [toolbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [iconBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(64);
        make.width.height.mas_equalTo(186);
    }];
    
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(iconBg);
        make.width.height.mas_equalTo(100);
    }];
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(iconView.mas_bottom).offset(20);
    }];
    
    [idLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(nameLabel.mas_bottom).offset(2);
    }];
    
    [uidField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(idLabel.mas_bottom).offset(40);
        make.centerX.equalTo(self.view);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(210);
    }];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(uidField.mas_bottom);
        make.leading.trailing.equalTo(uidField);
        make.height.mas_equalTo(1);
    }];
    
    [callBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(uidField.mas_bottom).offset(18);
        make.leading.trailing.equalTo(uidField);
        make.height.mas_equalTo(40);
    }];
    
    [logo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-34);
        make.centerX.equalTo(self.view);
    }];
}

#pragma mark - initSDK

- (void)checkInitLinkvSdk {
    
    __weak typeof(self) weakSelf = self;
    self.engine = [StrangerChat createEngine:[AppSign your_app_id] appKey:[AppSign your_app_key] completion:^(NSInteger code) {
        if (code == 0) {
            weakSelf.isSDKInit = YES;
            NSLog(@"SDK init succeed");
        }
        [MBProgressHUD showMsg:code == 0 ? @"SDK初始化成功" : @"SDK初始化失败"];
    } delegate:self];
}

- (void)initSDK {
    
    [self checkInitLinkvSdk];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *uid = [ud stringForKey:@"uid"];

    if (!uid) {
        uid = [NSString stringWithFormat:@"%d%d%d%d", arc4random_uniform(10), arc4random_uniform(10), arc4random_uniform(10), arc4random_uniform(10)];
        [ud setObject:uid forKey:@"uid"];
    }
    self.uid = uid;
    
    int result = [self.engine loginIM:self.uid delegate:self];
    self.engine.uid = uid;
    
    if ( result == 0) {
        self.title = [NSString stringWithFormat:@"uid: %@", self.uid];
    } else {
        [MBProgressHUD showMsg:[NSString stringWithFormat:@"login failed %d", result]];
    }
    
    self.user = [[LVHelper shared] userFormUid:uid];
    [LVHelper shared].user = self.user;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    
}

#pragma mark - BtnAction
- (void)uidFieldChanged:(UITextField *)textField {
    
    self.lineView.backgroundColor = textField.hasText ? [UIColor blackColor] : RGB(0xcdcdcd);
    self.callBtn.selected = textField.hasText;
}

- (void)callBtnClick:(UIButton *)btn {
    if (!self.uidField.hasText) return;
    if ([self.uidField.text isEqualToString:self.uid]) return;
    
    if(!self.isSDKInit) {
        [MBProgressHUD showMsg:@"SDK初始化中...."];
        [self checkInitLinkvSdk];
        return;
    }
    
    LVRoomVC *roomVC = [LVRoomVC new];
    roomVC.engine = self.engine;
    roomVC.user = [[LVHelper shared] userFormUid:self.uidField.text];
    roomVC.isCaller = YES;
    roomVC.myUid = self.uid;
    roomVC.roomId = self.uidField.text;
    self.other = roomVC.user;
    self.roomVC = roomVC;
    
    [self.navigationController pushViewController:roomVC animated:YES];
    
    [self.engine call:self.uidField.text isAudio:NO extra:[self dictToStr:@{@"isZego":@(NO)}] callback:nil];
    [[LVHelper shared] callRing];
}

#pragma mark - LVIMModuleEventDelegate
- (void)onIMLosted {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.title = @"Losted";
    });
}

- (void)onIMConnected:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.title = @"Connected";
    });
}

- (void)onQueryIMToken {
    NSLog(@"[Wing] onQueryIMToken");
    [[LVIMSDK sharedInstance] setIMToken:self.uid token:@"XXX"];
}

- (void)onIMTokenExpired:(NSString *)uid token:(NSString *)token owner:(NSString *)owner {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.title = @"Expired";
    });
}

- (void)onIMAuthSuccessed:(NSString *)uid token:(NSString *)token unReadMsgSize:(int)unReadMsgSize {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.title = @"AuthSucceed";
    });
    
    NSLog(@"[Wing] onIMAuthSuccessed");
}

- (void)onIMAuthFailed:(NSString *)uid token:(NSString *)token ecode:(int)ecode rcode:(int)rcode expired:(BOOL)expired {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.title = @"AuthFailed";
    });
    
    NSLog(@"[Wing] onIMAuthFailed");
}

#pragma mark - LVIMReceiveMessageDelegate
- (BOOL)onIMReceiveMessageFilter:(int32_t)diytype fromid:(const char *)fromid toid:(const char *)toid msgtype:(const char *)msgtype content:(const char *)content waitings:(int)waitings packetSize:(int)packetSize waitLength:(int)waitLength bufferSize:(int)bufferSize {
    return NO;
}

- (int)onIMReceiveMessageHandler:(NSString *)owner immsg:(LVIMMessage *)immsg waitings:(int)waitings packetSize:(int)packetSize waitLength:(int)waitLength bufferSize:(int)bufferSize {
    
    if (!immsg.mContent || !immsg.mExtend1) return 0;
    
    return 0;
}

#pragma mark - StrangerChatDelegate
- (int)onCallReceived:(NSString *)uid isAudio:(BOOL)isAudio timestamp:(int64_t)timestamp extra:(NSString *)extra {
    NSLog(@"[Wing] onCallReceived uid  = %@, isAudio = %d, extra = %@ timestamp = %lld", uid, isAudio, extra, timestamp);
    int interval = [[NSDate date] timeIntervalSince1970] - timestamp / 1000;
    if (interval > linkv_call_overtime) {
        NSLog(@"onCallReceived overtime %d", interval);
        return 0;
    }
    
    __weak typeof(self) weakSelf = self;
    self.callView = [LVCallCardView show:[[LVHelper shared] userFormUid:uid] inView:self.view btnBlock:^(LVCallCardView * _Nonnull callView, LVUserModel * _Nonnull user, BOOL isAnwsered) {
        
        [callView dismiss];
        [weakSelf.engine anwserCall:uid accept:isAnwsered isAudio:isAudio extra:nil callback:nil];
        if (!isAnwsered) return;
        NSDictionary* extraDic = [self strToDict:extra];
        NSNumber* isZego = extraDic[@"isZego"];
        [weakSelf receiveCall:uid isAudio:isAudio isZego:[isZego boolValue]];
    }];
    
    self.receiveCallTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:30 repeats:NO block:^(NSTimer * _Nonnull timer) {
        [timer invalidate];
        weakSelf.receiveCallTimeoutTimer = nil;
        [weakSelf.callView dismiss];
        [weakSelf.engine anwserCall:uid accept:NO isAudio:isAudio extra:@"time ount" callback:nil];
    }];
    
    return 0;
}

- (int)onAnwserCallReceived:(NSString *)uid accept:(BOOL)accept isAudio:(BOOL)isAudio  timestamp:(int64_t)timestamp extra:(NSString *)extra {
    NSLog(@"[Wing] onAnwserCallReceived uid  = %@, accept = %d, isAudio = %d, extra = %@ timestamp = %lld", uid, accept, isAudio, extra, timestamp);
    
    int interval = [[NSDate date] timeIntervalSince1970] - timestamp / 1000;
    if (interval > linkv_call_overtime) {
        NSLog(@"onAnwserCallReceived overtime %d", interval);
        return 0;
    }
    
    if (!accept) {
        [self removeCallView];
    }
    [self.roomVC onAnwserCallReceived:uid accept:accept isAudio:isAudio];
    
    return 0;
}

- (int)onHangupCallReceived:(NSString *)uid extra:(NSString *)extra {
    NSLog(@"[Wing] onHangupCallReceived uid = %@ extra = %@", uid, extra);
    
    [self removeCallView];
    [self.roomVC onHangupCallReceived:uid];
    return 0;
}

#pragma mark - private
- (void)removeCallView {
    if (!self.callView) return;
    
    [[LVHelper shared] stop];
    [self.callView dismiss];
    self.callView = nil;
}

- (void)receiveCall:(NSString *)uid isAudio:(BOOL)isAudio isZego:(BOOL)isZego {
    
    [[LVHelper shared] stop];
    [self.receiveCallTimeoutTimer invalidate];
    self.receiveCallTimeoutTimer = nil;
    
    LVRoomVC *roomVC = [LVRoomVC new];
    roomVC.engine = self.engine;
    roomVC.user = [[LVHelper shared] userFormUid:uid];
    roomVC.isCaller = NO;
    roomVC.myUid = self.uid;
    roomVC.roomId = self.uid;
    self.roomVC = roomVC;
    
    [self.navigationController pushViewController:roomVC animated:YES];
}

#pragma mark - private
- (NSString *)dictToStr:(NSDictionary *)dict {
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) return nil;
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    if (error || !data) return nil;
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}


- (NSDictionary *)strToDict:(NSString *)str {
    if (!str) return nil;
    
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    if (error || !dict || ![dict isKindOfClass:[NSDictionary class]]) return nil;
    
    return dict;
}

@end

