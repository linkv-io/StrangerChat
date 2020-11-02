//
//  LVRoomVC.h
//  StrangerChat_Example
//
//  Created by Wing on 2020/10/14.
//  Copyright © 2020 wangyansnow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LVUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LVRoomVC : UIViewController

@property (nonatomic, strong) LVUserModel *user;
@property (nonatomic, assign) BOOL isCaller; // YES:呼叫者 NO:接听者
@property (nonatomic, copy) NSString *myUid; // 自己的uid
@property (nonatomic, copy) NSString *roomId; 

- (int)onAnwserCallReceived:(NSString *)uid accept:(BOOL)accept isAudio:(BOOL)isAudio;
- (int)onHangupCallReceived:(NSString *)uid;

@end

NS_ASSUME_NONNULL_END
