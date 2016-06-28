//
//  GFPublishManager.h
//  GetFun
//
//  Created by zhouxz on 15/12/3.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "GFPublishParameterMTL.h"

/**
 *  发布状态
 */
typedef NS_ENUM(NSInteger, GFPublishState) {
    /**
     *  默认等待发送
     */
    GFPublishStateWaiting   = 0,
    /**
     *  当前正在处理，发送
     */
    GFPublishStateSending   = 1,
    /**
     *  发送成功
     */
    GFPublishStateSuccess   = 2,
    /**
     *  发送失败
     */
    GFPublishStateFailed    = 3
};

@interface GFPublishManager : NSObject

+ (BOOL)publish:(GFPublishMTL *)publishMTL;

+ (NSArray *)allWaitingTask;
+ (NSArray *)waitingTaskWithGroupId:(NSNumber *)groupId;
+ (NSArray *)waitingTaskWithTagId:(NSNumber *)tagId;

+ (NSArray *)allFailedTask;
+ (NSArray *)failedTaskListWithGroupId:(NSNumber *)groupId;
+ (NSArray *)failedTaskListWithTagId:(NSNumber *)tagId;

+ (void)removeAllFailedTask;
+ (void)removeFailedTaskWithGroupId:(NSNumber *)groupId;
+ (void)removeFailedTaskWithTagId:(NSNumber *)tagId;

+ (void)retryAllFailedTask;
+ (void)retryFailedTaskWithGroupId:(NSNumber *)groupId;
+ (void)retryFailedTaskWithTagId:(NSNumber *)tagId;
@end
