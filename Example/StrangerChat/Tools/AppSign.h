//
//  AppSign.h
//  LinkVRTMEngine
//
//  Created by Wing on 2021/6/3.
// 请访问【https://doc-zh.linkv.sg/platform/info/quick_start】获取您的appId和appSecret

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppSign : NSObject

// 请访问【https://doc-zh.linkv.sg/platform/info/quick_start】获取您的appId和appSecret
+ (NSString *)your_app_id;
+ (NSString *)your_app_key;

@end

NS_ASSUME_NONNULL_END
