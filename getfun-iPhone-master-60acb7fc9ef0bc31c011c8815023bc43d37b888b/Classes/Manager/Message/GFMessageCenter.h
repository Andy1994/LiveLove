//
//  GFMessageCenter.h
//  GetFun
//
//  Created by zhouxz on 16/1/28.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GFMessageMTL.h"
#import "GFUnreadCountMTL.h"

@interface GFMessageCenter : NSObject

// 初始化
+ (void)setup;

// 普通消息
+ (void)markReadMessage:(GFMessageMTL *)message;
+ (void)markAllMessageRead;

// 活动消息
+ (NSArray *)activityMessages;
+ (NSUInteger)unreadActivityMessageCount;
+ (BOOL)deleteActivityMessage:(GFMessageMTL *)message;

// 消息处理
+ (void)handleMessage:(GFMessageMTL *)message shouldRedirect:(BOOL)shouldRedirect;

@end
