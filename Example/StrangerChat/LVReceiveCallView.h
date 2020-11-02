//
//  LVReceiveCallView.h
//  StrangerChat_Example
//
//  Created by Wing on 2020/9/28.
//  Copyright © 2020 wangyansnow. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LVReceiveCallView : UIView

+ (instancetype)show:(NSString *)uid inView:(UIView *)view complete:(void(^)(LVReceiveCallView *callView, NSString *uid, BOOL isAnwsered))complete;
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
