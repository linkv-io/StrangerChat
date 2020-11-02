//
//  LVHelper.h
//  StrangerChat_Example
//
//  Created by Wing on 2020/10/14.
//  Copyright © 2020 wangyansnow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LVGiftCell.h"
#import "LVUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LVHelper : NSObject

+ (instancetype)shared;

// 来电响铃 —— 28s后自动停止
- (void)callSound;
// 呼叫响铃 —— 28s后自动停止
- (void)callRing;
// 停止响铃
- (void)stop;
// 震动📳
- (void)shake;
// 挂断后提示音
- (void)hangupSound;

@property (nonatomic, strong) NSArray<LVGiftModel *> *gifts;
@property (nonatomic, strong) LVUserModel *user;

- (LVUserModel *)userFormUid:(NSString *)uid;
- (NSString *)strFromDurtion:(NSInteger)duration;

- (NSInteger)changeBalance:(NSInteger)cost;

@end

NS_ASSUME_NONNULL_END
