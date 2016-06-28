//
//  MBProgressHUD+GetFun.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/5.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "MBProgressHUD+GetFun.h"

@implementation MBProgressHUD (GetFun)

// 显示文本提示，不自动隐藏
+ (instancetype)showHUDWithTitle:(NSString *)title {
    
    UIView *view = [UIApplication sharedApplication].keyWindow;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = title;
    hud.removeFromSuperViewOnHide = YES;
    return hud;
}

+ (instancetype)showHUDWithTitle:(NSString *)title inView: (UIView *)view {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = title;
    hud.removeFromSuperViewOnHide = YES;
    return hud;
}
// 显示文本提示，自动隐藏
+ (instancetype)showHUDWithTitle:(NSString *)title duration:(NSTimeInterval)duration {
    UIView *view = [UIApplication sharedApplication].keyWindow;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = title;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:duration];
    return hud;
}

+ (instancetype)showHUDWithTitle:(NSString *)title duration:(NSTimeInterval)duration inView: (UIView *)view {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = title;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:duration];
    return hud;
}
// 显示loading提示，不自动隐藏
+ (instancetype)showLoadingHUDWithTitle:(NSString *)title {
    
    UIView *view = [UIApplication sharedApplication].keyWindow;
    return [self showLoadingHUDWithTitle:title inView:view];
}

+ (instancetype)showLoadingHUDWithTitle:(NSString *)title inView:(UIView *)view {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = title;
    hud.removeFromSuperViewOnHide = YES;
    return hud;
}

@end
