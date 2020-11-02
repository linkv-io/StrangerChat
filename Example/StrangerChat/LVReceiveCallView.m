//
//  LVReceiveCallView.m
//  StrangerChat_Example
//
//  Created by Wing on 2020/9/28.
//  Copyright © 2020 wangyansnow. All rights reserved.
//

#import "LVReceiveCallView.h"
#import <AudioToolbox/AudioToolbox.h>

@interface LVReceiveCallView ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic, copy) void(^anwserBlock)(LVReceiveCallView *callView, NSString *uid, BOOL isAnwsered);
@property (nonatomic, copy) NSString *uid;

@end

@implementation LVReceiveCallView

+ (instancetype)show:(NSString *)uid inView:(UIView *)view complete:(void(^)(LVReceiveCallView *callView, NSString *uid, BOOL isAnwsered))complete {
    LVReceiveCallView *callView = [[NSBundle bundleForClass:self] loadNibNamed:@"LVReceiveCallView" owner:nil options:nil].firstObject;
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat h = 65;
    callView.frame = CGRectMake(20, -h, screenW - 40, h);
    [view addSubview:callView];
    callView.nameLabel.text = uid;
    callView.layer.cornerRadius = 8;
    callView.clipsToBounds = YES;
    
    [UIView animateWithDuration:0.25 animations:^{
        callView.frame = CGRectMake(20, 33, screenW - 40, h);
    }];
    
    callView.anwserBlock = complete;
    callView.uid = uid;
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    return callView;
}

- (void)dismiss {
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat h = 65;
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = CGRectMake(20, -h, screenW - 40, h);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - BtnAction
- (IBAction)anwserBtnClick:(UIButton *)sender {
    if (self.anwserBlock) {
        self.anwserBlock(self, self.uid, YES);
    }
}

- (IBAction)rejectBtnClick:(UIButton *)sender {
    if (self.anwserBlock) {
        self.anwserBlock(self, self.uid, NO);
    }
}

- (void)dealloc {
    NSLog(@"[Wing] %@ dealloc🍀🍀🍀🍀", self);
}

@end
