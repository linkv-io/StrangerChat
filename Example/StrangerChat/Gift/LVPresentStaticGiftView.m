//
//  LVPresentStaticGiftView.m
//  StrangerChat_Example
//
//  Created by Wing on 2020/10/28.
//  Copyright © 2020 wangyansnow. All rights reserved.
//

#import "LVPresentStaticGiftView.h"

@interface LVPresentStaticGiftView ()

@property (nonatomic, strong) UIImageView *headIconView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *giftNameLabel;
@property (nonatomic, strong) UIImageView *giftImageView;
@property (nonatomic, strong) UILabel *countLabel;

@end

@implementation LVPresentStaticGiftView

+ (instancetype)showInView:(UIView *)view {
    LVPresentStaticGiftView *giftView = [self new];
    
    [giftView setupUI];
    
    return giftView;
}

- (void)setupUI {
    
    
}

@end
