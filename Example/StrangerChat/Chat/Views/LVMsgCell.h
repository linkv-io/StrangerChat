//
//  LVMsgCell.h
//  StrangerChat_Example
//
//  Created by Wing on 2021/6/2.
//  Copyright © 2021 wangyansnow. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LVIMMessage;
@interface LVMsgCell : UITableViewCell

@property (nonatomic, strong) LVIMMessage *msg;

@end

NS_ASSUME_NONNULL_END
