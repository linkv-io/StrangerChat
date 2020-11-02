//
//  LVRoomVCTest.m
//  StrangerChat_Example
//
//  Created by Wing on 2020/9/28.
//  Copyright © 2020 wangyansnow. All rights reserved.
//

#import "LVRoomVCTest.h"
#import "StrangerChat.h"
#import "MBProgressHUD+LM.h"

@interface LVRoomVCTest ()<LVRoomDelegate>

@property (weak, nonatomic) IBOutlet UIButton *applyForBeamBtn;
@property (weak, nonatomic) IBOutlet UIButton *closeRoomBtn;

@property (weak, nonatomic) IBOutlet UIStackView *anwserStackView;
@property (nonatomic, strong) StrangerChat *engine;
@property (nonatomic, copy) NSString *applyForBeamUid;
@property (nonatomic, assign) NSInteger applyForBeamPosition;

@property (weak, nonatomic) IBOutlet UITextField *uidField;


@end

@implementation LVRoomVCTest

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.engine = [StrangerChat shared];
    [self.engine loginRoom:self.engine.uid roomId:self.roomId isHost:YES delegate:self];
    
    [self.engine setRoomDelegate:self];
}

#pragma mark - BtnAction
- (IBAction)applyForBeamBtnClick:(UIButton *)sender {

    
    [self.engine applyForBeam:self.roomId position:2 extra:nil callback:^(int ecode, int rcode, int64_t lvsgid, int64_t smsgid, int64_t stime, LVIMMessage *msg) {
        [MBProgressHUD showMsg:ecode == 0 ? @"请求连麦成功" : @"请求连麦失败"];
    }];
}

- (IBAction)closeRoomBtnClick:(UIButton *)sender {
    [self.engine endRoom:self.roomId extra:nil callback:^(int ecode, int rcode, int64_t lvsgid, int64_t smsgid, int64_t stime, LVIMMessage *msg) {
       [MBProgressHUD showMsg:ecode == 0 ? @"endRoom成功" : @"endRoom失败"];
    }];
}

- (IBAction)sendGiftBtnClick:(UIButton *)sender {
    [self.engine sendGift:@"giftId_998" count:10 uid:@[@"123", @"122"] roomId:self.roomId extra:nil callback:^(int ecode, int rcode, int64_t lvsgid, int64_t smsgid, int64_t stime, LVIMMessage *msg) {
        [MBProgressHUD showMsg:ecode == 0 ? @"送礼成功" : @"送礼失败"];
    }];
}

- (IBAction)anwserBeamBtnClick:(UIButton *)sender {
    BOOL accept = sender.tag;
    
    NSAssert(self.applyForBeamUid, @"applyForBeamUid不能为nil");
    [self.engine anwserApplyForBeam:self.applyForBeamUid accept:accept roomId:self.roomId position:self.applyForBeamPosition extra:nil callback:^(int ecode, int rcode, int64_t lvsgid, int64_t smsgid, int64_t stime, LVIMMessage *msg) {
       [MBProgressHUD showMsg:ecode == 0 ? @"anwser成功" : @"anwser失败"];
    }];
    self.anwserStackView.hidden = YES;
}

- (IBAction)kickBeamOffBtnClick:(UIButton *)sender {
    if (!self.uidField.hasText) return;
    [self.engine kickBeamOff:self.uidField.text roomId:self.roomId position:2 extra:nil callback:^(int ecode, int rcode, int64_t lvsgid, int64_t smsgid, int64_t stime, LVIMMessage *msg) {
       [MBProgressHUD showMsg:ecode == 0 ? @"下麦成功" : @"下麦失败"];
    }];
}

- (IBAction)stopBeamBtnClick:(UIButton *)sender {
    
}

- (IBAction)enterRoomBtnClick:(UIButton *)sender {

    [self.engine sendRoomMessage:self.roomId content:@"enter room" msgType:@"linkv_enter_room" complete:^(int ecode, int rcode, int64_t lvsgid, int64_t smsgid, int64_t stime, LVIMMessage *msg) {
        [MBProgressHUD showMsg:ecode == 0 ? @"enterRoom成功" : @"enterRoom失败"];
    }];
}

- (IBAction)leaveRoomBtnClick:(UIButton *)sender {
    [self.engine sendRoomMessage:self.roomId content:@"leave room" msgType:@"linkv_leave_room" complete:^(int ecode, int rcode, int64_t lvsgid, int64_t smsgid, int64_t stime, LVIMMessage *msg) {
       [MBProgressHUD showMsg:ecode == 0 ? @"leaveRoom成功" : @"leaveRoom失败"];
    }];
}


#pragma mark - LVRoomDelegate
- (int)onGiftReceived:(NSString *)giftId count:(NSInteger)count sendUid:(NSString *)sendUid uid:(NSArray<NSString *> *)uids roomId:(NSString *)roomId extra:(NSString *)extra {
    
    NSLog(@"[Wing] onGiftReceived giftId = %@, count = %ld, sendUid = %@, uids = %@, roomId = %@", giftId, count, sendUid, uids, roomId);
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showMsg:[NSString stringWithFormat:@"收到礼物：%@", giftId]];
    });
    
    return 0;
}

- (int)onApplyForBeamRecevied:(NSString *)uid roomId:(NSString *)roomId position:(NSInteger)position extra:(NSString *)extra {
    
    NSLog(@"[Wing] onApplyForBeamRecevied uid = %@, roomId = %@, position = %ld", uid, roomId, position);
    self.applyForBeamUid = uid;
    self.applyForBeamPosition = position;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.anwserStackView.hidden = NO;
    });
    
    return 0;
}

- (int)onAnwserApplyForBeam:(NSString *)uid accept:(BOOL)accept roomId:(NSString *)roomId position:(NSInteger)position extra:(NSString *)extra {
    
    NSLog(@"[Wing] onAnwserApplyForBeam uid = %@, roomId = %@, position = %ld", uid, roomId, position);
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showMsg:accept ? [NSString stringWithFormat:@"%@可以上麦", uid] : [NSString stringWithFormat:@"%@不能上麦", uid]];
    });
    
    return 0;
}

- (int)onKickBeamOffReceived:(NSString *)uid roomId:(NSString *)roomId position:(NSInteger)position extra:(NSString *)extra {
    NSLog(@"[Wing] onKickBeamOffReceived uid = %@, roomId = %@, position = %ld", uid, roomId, position);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showMsg: [NSString stringWithFormat:@"%@被下麦", uid]];
    });
    
    return 0;
}

- (int)onEndRoomReceived:(NSString *)roomId extra:(NSString *)extra {
    NSLog(@"[Wing] onEndRoomReceived roomId = %@", roomId);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showMsg: @"end room"];
    });
    
    return 0;
}

- (int)onRoomMessageReceive:(LVIMMessage *)msg {
    NSString *content = [[NSString alloc] initWithData:msg.mContent encoding:NSUTF8StringEncoding];
    NSLog(@"[Wing] content = %@", content);
    
    return 0;
}

- (int)onUserEntered:(NSString *)uid roomId:(NSString *)roomId {
    NSLog(@"[Wing] onUserEntered uid = %@, roomId = %@", uid, roomId);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showMsg:@"有用户进入"];
    });
    
    return 0;
}

- (int)onUserLeaft:(NSString *)uid roomId:(NSString *)roomId {
    NSLog(@"[Wing] onUserEntered uid = %@, roomId = %@", uid, roomId);
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showMsg:@"有用户离开"];
    });
    
    return 0;
}

- (void)onRoomConnected:(NSString *)roomId {
    self.title = @"connected";
    NSLog(@"[Wing] onRoomConnected roomId = %@", roomId);
}

#pragma mark - 重载
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)dealloc {
    NSLog(@"[Wing] %@ dealloc🍀🍀🍀🍀", self);
    
    [self.engine logoutRoom];
}

@end
