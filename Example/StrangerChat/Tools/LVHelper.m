//
//  LVHelper.m
//  StrangerChat_Example
//
//  Created by Wing on 2020/10/14.
//  Copyright © 2020 wangyansnow. All rights reserved.
//

#import "LVHelper.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface LVHelper ()<AVAudioPlayerDelegate>

@property (nonatomic, assign) SystemSoundID callSoundID;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end

@implementation LVHelper

+ (instancetype)shared {
    static id obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [self new];
    });
    
    return obj;
}

- (void)callSound {
//    [self play:@"voip_call"];
    [self playMusic:@"voip_call"];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(shake) userInfo:nil repeats:YES];
    [self shake];
}

- (void)callRing {
//    [self play:@"voip_calling_ring"];
    [self playMusic:@"voip_calling_ring"];
}

- (void)stop {
    
    AudioServicesDisposeSystemSoundID(self.callSoundID);
    self.callSoundID = -1;
    [self.timer invalidate];
    self.audioPlayer = nil;
}

- (void)shake {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void)hangupSound {
    [self stop];
//    [self play:@"hungup"];
    [self playMusic:@"hungup"];
}

#pragma mark - private
- (void)play:(NSString *)soundName {
    SystemSoundID soundID;
    //NSBundle来返回音频文件路径
    NSString *soundFile = [[NSBundle mainBundle] pathForResource:soundName ofType:@"mp3"];
    //建立SystemSoundID对象，但是这里要传地址(加&符号)。 第一个参数需要一个CFURLRef类型的url参数，要新建一个NSString来做桥接转换(bridge)，而这个NSString的值，就是上面的音频文件路径
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:soundFile], &soundID);
    //播放提示音 带震动
    AudioServicesPlayAlertSoundWithCompletion(soundID, ^{
        [self stop];
    });
    
    self.callSoundID = soundID;
}

- (void)playMusic:(NSString *)fileName {
    if (self.audioPlayer) {
        [self.audioPlayer stop];
    }
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:fileName withExtension:@"mp3"];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.audioPlayer.delegate = self;
    
    [self.audioPlayer play];
}

- (NSArray<LVGiftModel *> *)gifts {
    if (_gifts) return _gifts;
    
    NSMutableArray *arrM = [NSMutableArray arrayWithCapacity:8];
    
    LVGiftModel *model1 = [LVGiftModel new];
    model1.giftName = @"飞机";
    model1.giftPrice = 200;
    model1.folderName = @"10086";
    model1.listCount = 11;
    model1.animCount = 106;
    model1.animDuration = 5.3;
    
    LVGiftModel *model2 = [LVGiftModel new];
    model2.giftName = @"城堡";
    model2.giftPrice = 1200;
    model2.folderName = @"10087";
    model2.listCount = 7;
    model2.animCount = 129;
    model2.animDuration = 10.6;
    
    LVGiftModel *model3 = [LVGiftModel new];
    model3.giftName = @"天使";
    model3.giftPrice = 2000;
    model3.folderName = @"10088";
    model3.listCount = 6;
    model3.animCount = 134;
    model3.animDuration = 12;
    
    LVGiftModel *model4 = [LVGiftModel new];
    model4.giftName = @"豪轮";
    model4.giftPrice = 5000;
    model4.folderName = @"10089";
    model4.listCount = 11;
    model4.animCount = 129;
    model4.animDuration = 12;
    
    LVGiftModel *model5 = [LVGiftModel new];
    model5.giftName = @"咖啡";
    model5.giftPrice = 20;
    model5.imageName = @"coffee";
    model5.isStaticGift = YES;
    
    LVGiftModel *model6 = [LVGiftModel new];
    model6.giftName = @"四叶草";
    model6.giftPrice = 50;
    model6.imageName = @"siyecao";
    model6.isStaticGift = YES;
    
    LVGiftModel *model7 = [LVGiftModel new];
    model7.giftName = @"小熊";
    model7.giftPrice = 100;
    model7.imageName = @"beer";
    model7.isStaticGift = YES;
    
    LVGiftModel *model8 = [LVGiftModel new];
    model8.giftName = @"棒棒糖";
    model8.giftPrice = 150;
    model8.imageName = @"tang";
    model8.isStaticGift = YES;
    
    [arrM addObject:model1];
    [arrM addObject:model2];
    [arrM addObject:model3];
    [arrM addObject:model4];
    [arrM addObject:model5];
    [arrM addObject:model6];
    [arrM addObject:model7];
    [arrM addObject:model8];
    
    for (int i = 0; i < arrM.count; i++) {
        [arrM[i] setGiftId:i];
    }
    
    _gifts = arrM;
    return arrM;
}

- (LVUserModel *)userFormUid:(NSString *)uid {
    if (uid.length < 2) return nil;
    
    LVUserModel *user = [LVUserModel new];
    user.uid = uid;
    
    NSArray *names = @[@"Mike", @"Snow Wing", @"Snow", @"Json", @"Steven", @"江城子", @"故人初", @"泪倾城", @"清风叹", @"月下客"];
    
    int i = [[uid substringFromIndex:uid.length - 1] intValue];
    user.nickName = names[i];
    user.avatar = [NSString stringWithFormat:@"%d", (i + 1)];
    
    return user;
}

- (NSString *)strFromDurtion:(NSInteger)duration {
    if (duration <= 0) return @"00:00";
    
    NSInteger min = duration / 60;
    NSInteger sec = duration - min * 60;
    
    NSMutableString *strM = [NSMutableString string];
    if (min < 10) {
        [strM appendFormat:@"0%ld:", min];
    } else {
        [strM appendFormat:@"%ld:", min];
    }
    
    if (sec < 10) {
        [strM appendFormat:@"0%ld", sec];
    } else {
        [strM appendFormat:@"%ld", sec];
    }
    
    return strM;
}

- (NSInteger)changeBalance:(NSInteger)cost {
    NSString *uid = [LVHelper shared].user.uid;
    if (!uid || uid.length == 0) return 0;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSInteger balance = [ud integerForKey:uid] - cost;
    [ud setInteger:balance forKey:uid];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"lv_balance_changed" object:@(balance)];
        
    return balance;
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (flag) {
        [self stop];
    }
}

@end
