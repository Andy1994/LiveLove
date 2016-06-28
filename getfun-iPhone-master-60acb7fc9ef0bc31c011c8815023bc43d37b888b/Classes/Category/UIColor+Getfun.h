//
//  UIColor+Getfun.h
//  GetFun
//
//  Created by zhouxz on 15/11/20.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Getfun)

/**
 *  根据十六进制字符串转换成颜色
 *
 *  @param hex
 *
 *  @return 
 */
+ (UIColor *)gf_colorWithHex:(NSString *)hex;
+ (UIColor *)gf_colorWithHex:(NSString *)hexColor alpha:(CGFloat)alpha;

/**
 *  判断是否浅色
 *
 *  @return
 */
- (BOOL)gf_isLightColor;
#pragma mark - 文字颜色
/**
 *  深黑，正文信息,例如标题,正文等
 *
 *  @return
 */
+(UIColor *)textColorValue1;

/**
 *  深灰1，副标题,例如列表中的副标题等
 *
 *  @return
 */
+(UIColor *)textColorValue2;

/**
 *  深灰2，辅助信息1,例如标签页人名等
 *
 *  @return
 */
+(UIColor *)textColorValue3;

/**
 *  浅灰1，辅助信息2 首页评论数量,fun数量等
 *
 *  @return
 */
+(UIColor *)textColorValue4;

/**
 *  浅灰2，辅助信息3 提示输入文字、发布字数限制
 *
 *  @return
 */
+(UIColor *)textColorValue5;

/**
 *  白，辅助信息3 深色背景反白字体
 *
 *  @return
 */
+(UIColor *)textColorValue6;

/**
 *  紫，特殊提示信息,可点击文字 例如,下一步
 *
 *  @return
 */
+(UIColor *)textColorValue7;

/**
 *  紫灰，特殊信息,可点击文字
 *
 *  @return
 */
+(UIColor *)textColorValue8;

/**
 *  绿，特殊提示信息,可点击文字 例如发送验证码
 *
 *  @return
 */
+(UIColor *)textColorValue9;

/**
 *  深灰1，正文,详情页正文
 *
 *  @return
 */
+(UIColor *)textColorValue0;


#pragma mark - 界面色彩规范

/**
 *  紫，品牌色 登录按钮
 *
 *  @return
 */
+ (UIColor *)themeColorValue7;

/**
 *  绿，按钮色 例如登录选择性别,发布复制链接
 *
 *  @return
 */
+ (UIColor *)themeColorValue9;

/**
 *  淡紫，投票色1
 *
 *  @return
 */
+ (UIColor *)themeColorValue10;

/**
 *  蓝绿，投票色2
 *
 *  @return
 */
+ (UIColor *)themeColorValue11;

/**
 *  浅灰，背景色1 整体背景色
 *
 *  @return
 */
+ (UIColor *)themeColorValue12;

/**
 *  浅灰2，背景色2 例如分享链接背景,评论背景
 *
 *  @return
 */
+ (UIColor *)themeColorValue13;

/**
 *  灰，背景色3 例如输入框背景,分享链接背景,评论背景
 *
 *  @return
 */
+ (UIColor *)themeColorValue14;

/**
 *  浅灰2，分割线2 例如列表分隔线
 *
 *  @return 
 */
+ (UIColor *)themeColorValue15;

@end
