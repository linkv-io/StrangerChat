//
//  LVCallCardView.h
//  StrangerChat_Example
//
//  Created by Wing on 2020/10/15.
//  Copyright © 2020 wangyansnow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LVUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LVCallCardView : UIView

@property (nonatomic, weak) UIButton *leftBtn;
@property (nonatomic, weak) UIButton *rightBtn;
@property (nonatomic, weak) UILabel *descLabel;

+ (instancetype)show:(LVUserModel *)user inView:(UIView *)view btnBlock:(void(^)(LVCallCardView *callView, LVUserModel *user, BOOL isAnwsered))complete;
- (void)dismiss;

- (instancetype)initWithUser:(LVUserModel *)user btnBlock:(void(^)(LVCallCardView *callView, LVUserModel *user, BOOL isLeft))complete;
- (void)setupUI;

@end

NS_ASSUME_NONNULL_END
