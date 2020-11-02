//
//  LVRoomVC.m
//  StrangerChat_Example
//
//  Created by Wing on 2020/10/14.
//  Copyright © 2020 wangyansnow. All rights reserved.
//

#import "LVRoomVC.h"
#import <Masonry/Masonry.h>
#import "LVCallCardView.h"
#import "StrangerChat.h"
#import "LVHelper.h"
#import "LVGiftView.h"

#import "PresentView.h"
#import "GiftModel.h"
#import "AnimOperation.h"
#import "AnimOperationManager.h"
#import "GSPChatMessage.h"

#import "CALayer+FXAnimationEngine.h"


#define RGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define statusH ([[UIApplication sharedApplication] statusBarFrame].size.height)

static int smallW = 111;
static int smallH = 170;

@interface LVRoomVC ()<LVRoomDelegate>

@property (nonatomic, weak) UIView *topView;
@property (nonatomic, weak) UIView *bottomView;
@property (nonatomic, weak) LVCallCardView *cardView;
@property (nonatomic, strong) StrangerChat *engine;

@property (nonatomic, strong) NSTimer *overTimer; // 呼叫超时
@property (nonatomic, strong) NSTimer *durationTimer; // 通话时长回调
@property (nonatomic, strong) UIView *bigView;
@property (nonatomic, strong) UIView *smallView;
@property (nonatomic, assign) BOOL isHideDetail;

@property (nonatomic, weak) UIView *meView;
@property (nonatomic, weak) UIView *otherView;
@property (nonatomic, assign) BOOL isMeBig;

@property (nonatomic, strong) UIView *animationView;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, assign) NSInteger duration;

@property (nonatomic, weak) UIView *meDefaultView;
@property (nonatomic, weak) UIView *otherDefaultView;

@end

@implementation LVRoomVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
    self.engine = [StrangerChat shared];
    [self.engine setRoomDelegate:self];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    [self.engine setBeautyLevel:0.8];
    [self.engine setBrightLevel:0.8];
    [self.engine setToneLevel:0.5];
    
    if (!self.isCaller) {
        [self startVideo];
    }
}

- (void)setupUI {
    [self setupBgView];
    [self setupVideoView];
    [self setupTopView];
    [self setupBottomView];
    
    if (self.isCaller) {
        [self setupCardView];
    }
}

- (void)setupVideoView {
    UIView *videoView = [[UIView alloc] initWithFrame:self.view.bounds];
    UIControl *bigView = [[UIControl alloc] initWithFrame:videoView.bounds];
    CGFloat screenW = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat screenH = CGRectGetHeight([UIScreen mainScreen].bounds);
    UIControl *smallView = [[UIControl alloc] initWithFrame:CGRectMake(screenW - smallW - 16, screenH - smallH -64, smallW, smallH)];
    self.bigView = bigView;
    self.smallView = smallView;
    
    self.animationView = [[UIView alloc] initWithFrame:videoView.bounds];
    self.animationView.contentMode = UIViewContentModeScaleAspectFill;
    self.animationView.userInteractionEnabled = NO;
    
    [bigView addTarget:self action:@selector(bigViewClick) forControlEvents:UIControlEventTouchUpInside];
    [smallView addTarget:self action:@selector(smallViewClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    [smallView addGestureRecognizer:panGesture];
        
    [self.view addSubview:videoView];
    [videoView addSubview:bigView];
    [videoView addSubview:smallView];
    [videoView addSubview:self.animationView];
}

- (void)setupCardView {
    __weak typeof(self) weakSelf = self;
    LVCallCardView *cardView = [[LVCallCardView alloc] initWithUser:self.user btnBlock:^(LVCallCardView * _Nonnull callView, LVUserModel * _Nonnull user, BOOL isLeft) {
        
        NSLog(@"[Wing] cardView = %d", isLeft);
        if (!isLeft) { // 点击关闭按钮
            [weakSelf endCall];
        }
    }];
    self.cardView = cardView;
    
    [self.view addSubview:cardView];
    [cardView setupUI];
    
    [cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(16);
        make.trailing.equalTo(self.view).offset(-16);
        make.height.mas_equalTo(64);
        make.bottom.equalTo(self.bottomView.mas_top).offset(-16);
    }];
    
    self.cardView.leftBtn.hidden = YES;
    self.cardView.descLabel.text = @"正在等待对方接听……";
    [self.cardView.rightBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    
    self.overTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(overTime:) userInfo:nil repeats:NO];
}

- (void)overTime:(NSTimer *)timer {
    NSLog(@"[Wing] overTime = %@", timer);
    [self endCall];
}

- (void)setupBottomView {
    UIView *bottomView = [UIView new];
    self.bottomView = bottomView;
    
    UIButton *giftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [giftBtn setImage:[UIImage imageNamed:@"gift"] forState:UIControlStateNormal];
    giftBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [giftBtn addTarget:self action:@selector(giftBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *audioBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [audioBtn setImage:[UIImage imageNamed:@"audio_on"] forState:UIControlStateNormal];
    [audioBtn setImage:[UIImage imageNamed:@"audio_off"] forState:UIControlStateSelected];
    audioBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [audioBtn addTarget:self action:@selector(audioBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *videoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [videoBtn setImage:[UIImage imageNamed:@"video_on"] forState:UIControlStateNormal];
    [videoBtn setImage:[UIImage imageNamed:@"video_off"] forState:UIControlStateSelected];
    videoBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [videoBtn addTarget:self action:@selector(videoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *spinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [spinBtn setImage:[UIImage imageNamed:@"spin"] forState:UIControlStateNormal];
    spinBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [spinBtn addTarget:self action:@selector(spinBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [bottomView addSubview:giftBtn];
    [bottomView addSubview:audioBtn];
    [bottomView addSubview:videoBtn];
    [bottomView addSubview:spinBtn];
    [self.view addSubview:bottomView];
    
    CGFloat btnW = [UIScreen mainScreen].bounds.size.width / 4;
    [giftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(bottomView);
        make.width.mas_equalTo(btnW);
        make.height.mas_equalTo(32);
        make.centerY.equalTo(bottomView);
    }];
    [audioBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(giftBtn.mas_trailing);
        make.width.mas_equalTo(btnW);
        make.height.equalTo(bottomView);
        make.centerY.equalTo(bottomView);
    }];
    [videoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(audioBtn.mas_trailing);
        make.width.mas_equalTo(btnW);
        make.height.equalTo(bottomView);
        make.centerY.equalTo(bottomView);
    }];
    [spinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(videoBtn.mas_trailing);
        make.width.mas_equalTo(btnW);
        make.height.equalTo(bottomView);
        make.centerY.equalTo(bottomView);
    }];
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-[self bottomOffset]);
        make.height.mas_equalTo(50);
    }];
}

- (void)setupTopView {
    
    UIView *topView = [UIView new];
    self.topView = topView;
    
    UIView *v = [UIView new];
    v.backgroundColor = RGB(0x222222);
    v.layer.cornerRadius = 16;
    v.clipsToBounds = YES;
    
    UIImageView *avatarView = [UIImageView new];
    
    avatarView.image = [UIImage imageNamed:self.user.avatar];
    avatarView.layer.cornerRadius = 16;
    avatarView.clipsToBounds = YES;
    
    UILabel *nameLabel = [UILabel new];
    nameLabel.text = self.user.nickName;
    nameLabel.font = [UIFont boldSystemFontOfSize:15];
    nameLabel.textColor = [UIColor whiteColor];
    
    UIImageView *likeIcon = [UIImageView new];
    likeIcon.image = [UIImage imageNamed:@"like"];
        
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.durationLabel = [UILabel new];
    self.durationLabel.font = [UIFont systemFontOfSize:14];
    self.durationLabel.textColor = [UIColor whiteColor];
    
    
    [self.view addSubview:topView];
    [self.view addSubview:self.durationLabel];
    [topView addSubview:closeBtn];
    [topView addSubview:v];
    [v addSubview:avatarView];
    [v addSubview:nameLabel];
    [v addSubview:likeIcon];
    
    [avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(v);
        make.width.height.mas_equalTo(v.mas_height);
        make.centerY.equalTo(v);
    }];
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(avatarView.mas_trailing).offset(6);
        make.centerY.equalTo(avatarView);
    }];
    
    [likeIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(20);
        make.leading.equalTo(nameLabel.mas_trailing).offset(6);
        make.trailing.equalTo(v).offset(-6);
        make.centerY.equalTo(v);
    }];
    
    [v mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(topView).offset(16);
        make.top.height.equalTo(topView);
    }];
    
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(v);
        make.trailing.equalTo(self.view).offset(-2);
        make.width.height.mas_equalTo(60);
    }];
    
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.height.mas_equalTo(32);
        make.top.equalTo(self.view).offset(statusH + 10);
    }];
    
    [self.durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(topView.mas_bottom).offset(20);
            make.centerX.equalTo(self.view);
    }];
}

- (void)setupBgView {
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:self.view.bounds];
    toolbar.barStyle = UIBarStyleBlack;
    
    UIImageView *imgView = [UIImageView new];
    imgView.frame = self.view.bounds;
    imgView.image = [UIImage imageNamed:self.user.avatar];
    
    [self.view addSubview:imgView];
    [self.view addSubview:toolbar];
}

#pragma mark - BtnAction
- (void)closeBtnClick {
    [self endCall];
}

- (void)giftBtnClick {
    __weak typeof(self) weakSelf = self;
    [LVGiftView showInView:self.view gifts:[[LVHelper shared] gifts] sendBlock:^(LVGiftModel * _Nonnull gift) {
        [weakSelf.engine sendGift:[NSString stringWithFormat:@"%ld", gift.giftId] count:1 uid:@[weakSelf.user.uid] roomId:weakSelf.roomId extra:nil callback:^(int ecode, int rcode, int64_t lvsgid, int64_t smsgid, int64_t stime, LVIMMessage *msg) {
            if (ecode != 0) return;
            
            [weakSelf showGift:gift];
        }];
    }];
}

- (void)audioBtnClick:(UIButton *)btn {
    btn.selected = !btn.selected;
    
    [self.engine enableMic:btn.isSelected];
}

- (void)videoBtnClick:(UIButton *)btn {
    btn.selected = !btn.selected;
    
    self.meDefaultView.hidden = !btn.isSelected;
    if (btn.isSelected) {
        [self.engine stopCapture];
    } else {
        [self.engine startCapture];
    }
}

// 点击切换前后摄像头
- (void)spinBtnClick:(UIButton *)btn {
    btn.selected = !btn.isSelected;
    [self.engine useFrontCamera:!btn.isSelected];
}

- (void)bigViewClick {
    self.isHideDetail = !self.isHideDetail;
    
    if (self.isHideDetail) {
        [self.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view.mas_top);
            make.leading.trailing.equalTo(self.view);
            make.height.mas_equalTo(32);
        }];
        [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.height.mas_equalTo(50);
            make.top.equalTo(self.view.mas_bottom);
        }];
    } else {
        [self.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.height.mas_equalTo(32);
            make.top.equalTo(self.view).offset(statusH + 10);
        }];
        [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-[self bottomOffset]);
            make.height.mas_equalTo(50);
        }];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
        self.durationLabel.hidden = self.isHideDetail;
    }];
}

- (void)smallViewClick {
    if (!self.otherView) return;
    self.isMeBig = !self.isMeBig;
    
    UIView *meView = self.meView;
    UIView *otherView = self.otherView;
    [meView removeFromSuperview];
    [otherView removeFromSuperview];
    
    if (self.isMeBig) {
        [self.bigView addSubview:meView];
        [self.smallView addSubview:otherView];
        meView.frame = self.bigView.bounds;
        otherView.frame = self.smallView.bounds;
    } else {
        [self.bigView addSubview:otherView];
        [self.smallView addSubview:meView];
        meView.frame = self.smallView.bounds;
        otherView.frame = self.bigView.bounds;
    }
}

- (void)panGestureAction:(UIPanGestureRecognizer *)gesture {
    
    CGPoint translate = [gesture translationInView:gesture.view];
    CGFloat screenW = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat screenH = CGRectGetHeight([UIScreen mainScreen].bounds);
    
    CGRect smallRect = self.smallView.frame;
    CGFloat x = smallRect.origin.x + translate.x;
    CGFloat y = smallRect.origin.y + translate.y;
    if (x < 0) {
        x = 0;
    } else if (x > screenW - smallW) {
        x = screenW - smallW;
    }
    
    if (y < 0) {
        y = 0;
    } else if (y > screenH - smallH) {
        y = screenH - smallH;
    }
    self.smallView.frame = CGRectMake(x, y, smallRect.size.width, smallRect.size.height);
    [gesture setTranslation:CGPointZero inView:gesture.view];
}

#pragma mark - LVRoomDelegate
- (int)onUserMicrophoneChanged:(NSString *)uid roomId:(NSString *)roomId open:(BOOL)isOpen {
    NSLog(@"[Wing] onUserMicrophoneChanged uid = %@ roomId = %@ open = %d", uid, roomId, isOpen);
    return 0;
}

- (int)onUserVideoCameraChanged:(NSString *)uid roomId:(NSString *)roomId open:(BOOL)isOpen {
    NSLog(@"[Wing] onUserVideoCameraChanged uid = %@ roomId = %@ open = %d", uid, roomId, isOpen);
    if (![uid isEqualToString:self.user.uid]) return 0;
    
    self.otherDefaultView.hidden = isOpen;
    return 0;
}

- (int)onGiftReceived:(NSString *)giftId count:(NSInteger)count sendUid:(NSString *)sendUid uid:(NSArray<NSString *> *)uids roomId:(NSString *)roomId extra:(NSString *)extra {
    NSLog(@"[Wing] onGiftReceived giftId = %@", giftId);
    
    int gid = [giftId intValue];
    LVGiftModel *gift = [LVHelper shared].gifts[gid];
    [self showGift: gift];
    
    [[LVHelper shared] changeBalance:-gift.giftPrice];
    
    return 0;
}

#pragma mark - RTCCallbackDelegate
- (void)onAddRemoterUser:(NSString *)uid {
    
    self.otherView = [self.engine startPlayingStream:uid inView:self.bigView];
    [self addNoCameraDefaultView:NO];
}

- (void)onRemoteLeave:(NSString *)uid {
    [self.engine stopPlayingStream:uid];
    
    // 关闭房间
    
}

/**
 * 被踢出房间或断开房间链接
 * @param errorCode 错误码，参见Zego或LinkV错误码
 * @param roomId 房间id
 */
- (void)onRoomDisconnect:(int)errorCode roomId:(NSString *)roomId {
    NSLog(@"[Wing] onRoomDisconnect roomId = %@ errorCode = %@", roomId, @(errorCode));

}

- (void)onRoomConnected:(NSString *)roomId {
    NSLog(@"[Wing] onLoginRoomSucceed thread %@", [NSThread currentThread]);
    
    self.meView = [self.engine startPreview:self.smallView];
    [self addNoCameraDefaultView:YES];
    [self.engine startPublishing];
    
    [self durationTimer];
}

#pragma mark - public
- (int)onAnwserCallReceived:(NSString *)uid accept:(BOOL)accept isAudio:(BOOL)isAudio {
    if (![self.user.uid isEqualToString:uid]) return 0;
    
    if (!accept) { // 对方拒绝接听
        [self close];
    } else { // 对方同意接听
        [[LVHelper shared] stop];
        [self.overTimer invalidate];
        self.overTimer = nil;
        [self.cardView removeFromSuperview];
        [self startVideo];
    }
    
    return 0;
}

- (int)onHangupCallReceived:(NSString *)uid {
    NSLog(@"[Wing] onHangupCallReceived uid = %@", uid);
    if (![self.user.uid isEqualToString:uid]) return 0;
    
    [self close];
    return 0;
}

#pragma mark - private
- (void)startVideo {
    [self.engine setVideoConfig:Video_Config_720P];
    [self.engine loginRoom:self.myUid roomId:self.roomId isHost:self.isCaller delegate:self];
}

- (void)endCall {
    [self.engine hangupCall:self.user.uid extra:nil callback:nil];
    [self close];
}

- (void)close {
    [[LVHelper shared] hangupSound];
    [self.navigationController popViewControllerAnimated:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    [self.overTimer invalidate];
    self.overTimer = nil;
    [_durationTimer invalidate];
    _durationTimer = nil;
}

- (void)dealloc {
    NSLog(@"[Wing] %@ dealloc🍀🍀🍀🍀", self);
    
    [self.engine logoutRoom];
}

- (CGFloat)bottomOffset {
    CGFloat bottomPadding = 0;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
//        CGFloat topPadding = window.safeAreaInsets.top;
        bottomPadding = window.safeAreaInsets.bottom - 20;
    }
    
    return bottomPadding;
}

- (void)showGift:(LVGiftModel *)gift {
    if (gift.isStaticGift) {
        [self showStaticGift:gift];
    } else {
        [self playGift:gift];
    }
}

- (void)showStaticGift:(LVGiftModel *)gift {
    
    LVUserModel *me = [[LVHelper shared] userFormUid:self.myUid];
    
    // 礼物模型
    GiftModel *giftModel = [[GiftModel alloc] init];
    giftModel.headImage = [UIImage imageNamed:me.avatar];
    giftModel.name = me.nickName;
    NSString *imageName = gift.isStaticGift ? [NSString stringWithFormat:@"Gifts/%@", gift.imageName] : [NSString stringWithFormat:@"Gifts/%@/list/0", gift.folderName];
    giftModel.giftImage = [UIImage imageNamed:imageName];
    giftModel.giftName = gift.giftName;
    giftModel.giftCount = 1;
    
    AnimOperationManager *manager = [AnimOperationManager sharedManager];
    manager.parentView = self.view;
    // 用用户唯一标识 msg.senderChatID 存礼物信息,model 传入礼物模型
    [manager animWithUserID:me.uid model:giftModel finishedBlock:^(BOOL result) {
        
    }];
}

- (void)playGift:(LVGiftModel *)gift {
    NSMutableArray *arrM = [NSMutableArray arrayWithCapacity:129];
    for (int i = 0; i < gift.animCount; i++) {
        NSString *imgName = [NSString stringWithFormat:@"Gifts/%@/anim/%d",gift.folderName, i];
        NSString *path = [[NSBundle mainBundle] pathForResource:imgName ofType:@"png"];
        UIImage *img = [UIImage imageWithContentsOfFile:path];
        if (img) {
            [arrM addObject:img];
        } else {
            NSLog(@"[Wing] i = %d", i);
        }
    }
    
    FXKeyframeAnimation *animation = [FXKeyframeAnimation animationWithIdentifier:@"xxx"];
    animation.delegate = self;
    animation.frames = arrM;
    animation.duration = 12;
    animation.repeats = 1;
    // decode image asynchronously
    [self.animationView.layer fx_playAnimationAsyncDecodeImage:animation];
}

- (NSTimer *)durationTimer {
    if (!_durationTimer) {
        _durationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(durationChanged:) userInfo:nil repeats:YES];
    }
    return _durationTimer;
}

- (void)durationChanged:(NSTimer *)timer {
    self.duration++;
    
    self.durationLabel.text = [[LVHelper shared] strFromDurtion:self.duration];
}

- (void)addNoCameraDefaultView:(BOOL)isMe {
    
    UIView *defaultView = [UIView new];
    defaultView.hidden = YES;
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:self.view.bounds];
    toolbar.barStyle = UIBarStyleBlack;
    
    UIImageView *imgView = [UIImageView new];
    imgView.frame = self.view.bounds;
    
    [defaultView addSubview:imgView];
    [defaultView addSubview:toolbar];
    
    [toolbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(defaultView);
    }];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(defaultView);
    }];
    
    if (isMe) {
        [self.meView addSubview:defaultView];
        [defaultView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.meView);
        }];
        self.meDefaultView = defaultView;
        LVUserModel *model = [[LVHelper shared] userFormUid:self.myUid];
        imgView.image = [UIImage imageNamed: model.avatar];
    } else {
        [self.otherView addSubview:defaultView];
        [defaultView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.otherView);
        }];
        self.otherDefaultView = defaultView;
        imgView.image = [UIImage imageNamed:self.user.avatar];
    }
}

@end
