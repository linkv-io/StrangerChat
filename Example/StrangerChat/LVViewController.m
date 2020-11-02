//
//  LVViewController.m
//  StrangerChat
//
//  Created by wangyansnow on 09/27/2020.
//  Copyright (c) 2020 wangyansnow. All rights reserved.
//

#import "LVViewController.h"
#import "MBProgressHUD+LM.h"
#import "LVReceiveCallView.h"
#import "StrangerChat.h"
#import "LVRoomVCTest.h"

// linkvim 线上
static NSString *your_app_id = @"slFNjAcjvxhfEdTjkcwuqcVgMHXTkElT";
static NSString *your_app_sign = @"2852FAC5408BBBCF15002059F883C52C13D69DCA21D8ECC26C396FF7391BF3A1C369FC2F231B2F9864CEDF66120AA8CB7214B0B349270CEDA7C8F309F4942CF71AEE1A3B0D3D318D83F121C4C25C53E7446F5ED3495527471EFF6EE129B35CE2571EB360011A426B28A989EE1F5263719CF24E2CABBE36F28D6B80F2683BF5BA210CC7728EAB87458F9E01DB178990A27042B787EC02B9A55E4172A030383B51C0D5E06A32E0BED3400C7A0E9208308E";

@interface LVViewController ()<LVIMModuleEventDelegate, LVIMReceiveMessageDelegate, StrangerChatDelegate, RoomCallbackProtocl>

@property (nonatomic, strong) StrangerChat *engine;
@property (nonatomic, copy) NSString *uid;
@property (weak, nonatomic) IBOutlet UILabel *IMStateLabel;
@property (weak, nonatomic) IBOutlet UITextField *uidField;
@property (weak, nonatomic) IBOutlet UIButton *hangupBtn;
@property (nonatomic, copy) NSString *tid;
@property (nonatomic, weak) LVReceiveCallView *callView;


@end

@implementation LVViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initSDK];
}

- (void)initSDK {
    self.engine = [StrangerChat createEngine:your_app_id appKey:your_app_sign isTestEnv:NO completion:^(NSInteger code) {
        NSLog(@"[Wing] code = %ld", code);
    } delegate:self];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *uid = [ud stringForKey:@"uid"];

    if (!uid) {
        uid = [NSString stringWithFormat:@"%d%d%d%d", arc4random_uniform(10), arc4random_uniform(10), arc4random_uniform(10), arc4random_uniform(10)];
        [ud setObject:uid forKey:@"uid"];
    }
    self.uid = uid;
    int result = [self.engine loginIM:self.uid delegate:self];
    if ( result == 0) {
        self.title = [NSString stringWithFormat:@"uid: %@", self.uid];
    } else {
        [MBProgressHUD showMsg:[NSString stringWithFormat:@"login failed %d", result]];
    }
    
    self.uidField.text = [ud stringForKey:@"tid"];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - ButtonAction
- (IBAction)callBtnClick:(UIButton *)sender {
    if (!self.uidField.hasText) return;
    
    NSString *tid = self.uidField.text;
    [self.engine call:tid isAudio:NO extra:nil callback:^(int ecode, int rcode, int64_t lvsgid, int64_t smsgid, int64_t stime, LVIMMessage *msg) {
        [MBProgressHUD showMsg:ecode == 0 ? @"呼叫成功" : @"呼叫失败"];
        
        if (ecode == 0) {
            self.tid = tid;
            self.hangupBtn.hidden = NO;
        }
    }];
    [[NSUserDefaults standardUserDefaults] setObject:self.uidField.text forKey:@"tid"];
}

- (IBAction)hangupBtnClick:(UIButton *)sender {
    if (!self.tid) return;
    
    [self.engine hangupCall:self.tid extra:nil callback:^(int ecode, int rcode, int64_t lvsgid, int64_t smsgid, int64_t stime, LVIMMessage *msg) {
        [MBProgressHUD showMsg:ecode == 0 ? @"挂断成功" : @"挂断失败"];
        
        self.hangupBtn.hidden = (ecode == 0);
    }];
}

- (IBAction)roomItemClick:(UIBarButtonItem *)sender {
    LVRoomVCTest *roomVC = [LVRoomVCTest new];
    roomVC.roomId = @"9527";
    [self.navigationController pushViewController:roomVC animated:YES];
}


#pragma mark - LVIMModuleEventDelegate
- (void)onIMLosted {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.IMStateLabel.text = @"Losted";
    });
}

- (void)onIMConnected:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.IMStateLabel.text = @"Connected";
    });
}

- (void)onQueryIMToken {
    NSLog(@"[Wing] onQueryIMToken");
    [[LVIMSDK sharedInstance] setIMToken:self.uid token:@"XXX"];
}

- (void)onIMTokenExpired:(NSString *)uid token:(NSString *)token owner:(NSString *)owner {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.IMStateLabel.text = @"Expired";
    });
}

- (void)onIMAuthSuccessed:(NSString *)uid token:(NSString *)token unReadMsgSize:(int)unReadMsgSize {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.IMStateLabel.text = @"AuthSucceed";
    });
}

- (void)onIMAuthFailed:(NSString *)uid token:(NSString *)token ecode:(int)ecode rcode:(int)rcode expired:(BOOL)expired {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.IMStateLabel.text = @"AuthFailed";
    });
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
- (int)onCallReceived:(NSString *)uid isAudio:(BOOL)isAudio extra:(NSString *)extra {
    NSLog(@"[Wing] onCallReceived uid  = %@, isAudio = %d, extra = %@", uid, isAudio, extra);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showMsg:@"收到呼叫"];
        
        self.callView = [LVReceiveCallView show:uid inView:self.navigationController.view complete:^(LVReceiveCallView *callView, NSString *uid, BOOL isAnwsered) {
            [callView dismiss];
            
            [self.engine anwserCall:uid accept:isAnwsered isAudio:isAudio extra:nil callback:^(int ecode, int rcode, int64_t lvsgid, int64_t smsgid, int64_t stime, LVIMMessage *msg) {
                [MBProgressHUD showMsg:ecode == 0 ? @"anwser succ" : @"anwser failed"];
            }];
        }];
    });
    
    return 0;
}

- (int)onAnwserCallReceived:(NSString *)uid accept:(BOOL)accept isAudio:(BOOL)isAudio extra:(NSString *)extra {
    NSLog(@"[Wing] onAnwserCallReceived uid  = %@, accept = %d, isAudio = %d, extra = %@", uid, accept, isAudio, extra);
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showMsg:@"收到anwser回调"];
    });
     return 0;
}

- (int)onHangupCallReceived:(NSString *)uid extra:(NSString *)extra {
    NSLog(@"[Wing] onHangupCallReceived uid = %@ extra = %@", uid, extra);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showMsg:@"收到hangup回调"];
        
        [self.callView dismiss];
        self.callView = nil;
    });
     return 0;
}

- (int)onRoomMessageReceive:(LVIMMessage *)msg {
    NSLog(@"[Wing] onRoomMessageReceive msg = %@", msg.mFromID);
    
    return 0;
}

@end
