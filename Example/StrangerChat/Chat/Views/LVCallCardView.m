//
//  LVCallCardView.m
//  StrangerChat_Example
//
//  Created by Wing on 2020/10/15.
//  Copyright © 2020 wangyansnow. All rights reserved.
//

#import "LVCallCardView.h"
#import <Masonry/Masonry.h>
#import "LVHelper.h"

#define RGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@interface LVCallCardView ()

@property (nonatomic, copy) void(^anwserBlock)(LVCallCardView *callView, LVUserModel *user, BOOL isAnwsered);
@property (nonatomic, strong) LVUserModel *user;
@property (nonatomic, assign) BOOL isBtnDismiss;

@end

@implementation LVCallCardView

+ (instancetype)show:(LVUserModel *)user inView:(UIView *)view btnBlock:(void(^)(LVCallCardView *callView, LVUserModel *user, BOOL isAnwsered))complete; {
    
    LVCallCardView *callView = [LVCallCardView new];
    callView.anwserBlock = complete;
    callView.user = user;
    callView.isBtnDismiss = YES;
    
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat h = 65;
    callView.frame = CGRectMake(20, -h, screenW - 40, h);
    [view addSubview:callView];
    
    
    [callView setupUI];
    callView.layer.shadowColor = UIColor.lightGrayColor.CGColor;
    callView.layer.shadowOffset = CGSizeMake(0,0);
    callView.layer.shadowRadius = 10.0f;
    callView.layer.shadowOpacity = 10.0f;
    
    [UIView animateWithDuration:0.25 animations:^{
        callView.frame = CGRectMake(20, 33, screenW - 40, h);
    }];
    [[LVHelper shared] callSound];
    
    return callView;
}


- (instancetype)initWithUser:(LVUserModel *)user btnBlock:(void(^)(LVCallCardView *callView, LVUserModel *user, BOOL isLeft))complete {
    
    if (self = [super init]) {
        self.user = user;
        self.anwserBlock = complete;
        
        self.layer.shadowColor = UIColor.lightGrayColor.CGColor;
        self.layer.shadowOffset = CGSizeMake(0,0);
        self.layer.shadowRadius = 10.0f;
        self.layer.shadowOpacity = 10.0f;
    }
    
    return self;
}

- (void)setupUI {
    UIView *containerView = [[UIView alloc] initWithFrame:self.bounds];
    containerView.backgroundColor = [UIColor whiteColor];
    containerView.layer.cornerRadius = 8;
    containerView.clipsToBounds = YES;
    
    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.user.avatar]];
    iconView.layer.cornerRadius = 27;
    iconView.clipsToBounds = YES;
    
    UILabel *nameLabel = [UILabel new];
    nameLabel.text = self.user.nickName;
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.font = [UIFont boldSystemFontOfSize:16];
    
    UILabel *descLabel = [UILabel new];
    descLabel.text = @"申请和你视频通话";
    descLabel.textColor = RGB(0x666666);
    descLabel.font = [UIFont systemFontOfSize:12];
    self.descLabel = descLabel;
    
    UIButton *anwserBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [anwserBtn setImage:[UIImage imageNamed:@"anwser"] forState:UIControlStateNormal];
    [anwserBtn addTarget:self action:@selector(anwserBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.leftBtn = anwserBtn;
    
    UIButton *rejectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rejectBtn setImage:[UIImage imageNamed:@"reject"] forState:UIControlStateNormal];
    [rejectBtn addTarget:self action:@selector(rejectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.rightBtn = rejectBtn;
    
    [self addSubview:containerView];
    [containerView addSubview:iconView];
    [containerView addSubview:nameLabel];
    [containerView addSubview:descLabel];
    [containerView addSubview:anwserBtn];
    [containerView addSubview:rejectBtn];
    
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(containerView).offset(11);
        make.centerY.equalTo(containerView);
        make.width.height.mas_equalTo(54);
    }];
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(iconView.mas_trailing).offset(9);
        make.top.equalTo(containerView).offset(15);
    }];
    
    [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(nameLabel);
        make.top.equalTo(nameLabel.mas_bottom).offset(6);
    }];
    
    [rejectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(containerView).offset(-16);
        make.centerY.equalTo(containerView);
        make.width.height.mas_equalTo(32);
    }];
    
    [anwserBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(rejectBtn.mas_leading).offset(-12);
        make.width.height.centerY.equalTo(rejectBtn);
    }];
}

- (void)dismiss {
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat h = 65;
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = CGRectMake(20, -h, screenW - 40, h);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
    [[LVHelper shared] stop];
}

#pragma mark - BtnAction
- (void)anwserBtnClick:(UIButton *)sender {
    if (self.anwserBlock) {
        self.anwserBlock(self, self.user, YES);
    }
    
    if (!self.isBtnDismiss) return;
    [self dismiss];
}

- (void)rejectBtnClick:(UIButton *)sender {
    if (self.anwserBlock) {
        self.anwserBlock(self, self.user, NO);
    }
    
    if (!self.isBtnDismiss) return;
    [self dismiss];
}

- (void)dealloc {
    NSLog(@"[Wing] %@ dealloc🍀🍀🍀🍀", self);
}


@end
