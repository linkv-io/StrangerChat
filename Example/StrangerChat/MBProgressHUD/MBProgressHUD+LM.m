//
//  MBProgressHUD+LM.m
//  CMIMExcemple
//
//  Created by xuefeng on 2020/5/21.
//  Copyright © 2020 cmcm. All rights reserved.
//

#import "MBProgressHUD+LM.h"

@implementation MBProgressHUD (LM)
+ (void)showErrorWithMsg:(NSString *)msg {
    MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hub.mode = MBProgressHUDModeText;
    hub.label.text = msg;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [hub hideAnimated:YES];
    });
}

+ (void)showMsg:(NSString *)msg {
    [self showErrorWithMsg:msg];
}
@end
