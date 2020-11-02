//
//  LVGiftView.h
//  GiftDemo
//
//  Created by Wing on 2020/10/26.
//

#import <UIKit/UIKit.h>
#import "LVGiftCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface LVGiftView : UIView

+ (instancetype)showInView:(UIView *)view gifts:(NSArray<LVGiftModel *>*)gifts sendBlock:(void(^)(LVGiftModel *gift))complete;

@end

NS_ASSUME_NONNULL_END
