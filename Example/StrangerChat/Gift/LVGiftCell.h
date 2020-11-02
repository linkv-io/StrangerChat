//
//  LVGiftCell.h
//  GiftDemo
//
//  Created by Wing on 2020/10/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LVGiftModel : NSObject

@property (nonatomic, assign) NSInteger giftId;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *giftName;
@property (nonatomic, assign) int giftPrice;
@property (nonatomic, copy) NSString *folderName;
@property (nonatomic, assign) int listCount;
@property (nonatomic, assign) int animCount;
@property (nonatomic, assign) CGFloat animDuration;
@property (nonatomic, assign) BOOL isStaticGift;

@end

@interface LVGiftCell : UICollectionViewCell

@property (nonatomic, strong) LVGiftModel *model;

@property (nonatomic, assign) BOOL selected;

@end

NS_ASSUME_NONNULL_END
