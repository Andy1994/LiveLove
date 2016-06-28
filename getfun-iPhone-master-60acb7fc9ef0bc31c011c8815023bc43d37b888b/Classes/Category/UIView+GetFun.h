//
//  UIView+GetFun.h
//  GetFun
//
//  Created by Liu Peng on 15/12/7.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (GetFun)

- (void)gf_AddBottomBorderWithColor: (UIColor *) color andWidth:(CGFloat) borderWidth;

- (void)gf_AddLeftBorderWithColor: (UIColor *) color andWidth:(CGFloat) borderWidth;

- (void)gf_AddRightBorderWithColor: (UIColor *) color andWidth:(CGFloat) borderWidth;

- (void)gf_AddTopBorderWithColor: (UIColor *) color andWidth:(CGFloat) borderWidth;

@end
