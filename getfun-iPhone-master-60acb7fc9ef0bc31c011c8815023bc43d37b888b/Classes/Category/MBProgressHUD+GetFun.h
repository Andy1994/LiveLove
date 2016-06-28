//
//  MBProgressHUD+GetFun.h
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/5.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

@interface MBProgressHUD (GetFun)

// 显示文本提示，不自动隐藏
+ (instancetype)showHUDWithTitle:(NSString *)title;

+ (instancetype)showHUDWithTitle:(NSString *)title inView: (UIView *)view;

// 显示文本提示，自动隐藏
+ (instancetype)showHUDWithTitle:(NSString *)title duration:(NSTimeInterval)duration;

// 显示loading提示，不自动隐藏
+ (instancetype)showLoadingHUDWithTitle:(NSString *)title;

+ (instancetype)showLoadingHUDWithTitle:(NSString *)title inView:(UIView *)view;
+ (instancetype)showHUDWithTitle:(NSString *)title duration:(NSTimeInterval)duration inView: (UIView *)view;

@end
