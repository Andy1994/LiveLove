//
//  UIButton+Getfun.m
//  GetFun
//
//  Created by zhouxz on 16/1/18.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "UIButton+Getfun.h"
#import <UIImage+DTFoundation.h>

@implementation UIButton (Getfun)

+ (UIButton *)gf_purpleButtonWithTitle:(NSString *)title {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [button setTitle:title forState:UIControlStateNormal];
    
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5f] forState:UIControlStateDisabled];
    
    UIImage *bgImageNormal = [UIImage imageWithSolidColor:[UIColor themeColorValue7] size:CGSizeMake(10, 10)];
    UIImage *bgImageDisabled = [UIImage imageWithSolidColor:[[UIColor themeColorValue7] colorWithAlphaComponent:0.5f] size:CGSizeMake(10, 10)];
    [button setBackgroundImage:bgImageNormal forState:UIControlStateNormal];
    [button setBackgroundImage:bgImageDisabled forState:UIControlStateSelected];
    
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 4.0f;
    
    return button;
}

@end
