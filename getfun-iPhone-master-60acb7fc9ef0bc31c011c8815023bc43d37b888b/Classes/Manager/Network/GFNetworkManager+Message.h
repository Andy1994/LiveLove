//
//  GFNetworkManager+Message.h
//  GetFun
//
//  Created by zhouxz on 16/1/26.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFNetworkManager.h"
#import "GFUnreadCountMTL.h"
#import "GFMessageMTL.h"

@interface GFNetworkManager (Message)

// 上报个推的clientId
+ (NSUInteger)addGTClientId:(NSString *)clientId;

// 上报APNs device token
+ (NSUInteger)addAPNsDeviceToken:(NSString *)deviceToken;

// 通知后台清除APNs消息计数(app已经进入前台运行，清除之前所有的APNs消息计数)
+ (NSUInteger)clearAPNsMessageCount;

// 将消息标记已收到,仅针对活动和通知
+ (NSUInteger)markReceivedMessage:(NSNumber *)relatedId;

// 将消息标记已点击,仅针对活动和通知
+ (NSUInteger)markClickedMessage:(NSNumber *)relatedId;

// 将消息标记已读
+ (NSUInteger)markReadMessage:(NSNumber *)messageId;

// 将全部消息标记已读
+ (NSUInteger)markReadAllMessageCompletion:(void (^)())completion;

// 获取未读消息的总数
+ (NSUInteger)getUnreadMessageCountSuccess:(void(^)(NSUInteger taskId, NSInteger code, GFUnreadCountMTL *unreadCount))success
                                   failure:(void(^)(NSUInteger taskId, NSError *error))failure;

// 获取单条消息
+ (NSUInteger)getMessageWithRelatedId:(NSNumber *)relatedId
                                 type:(GFMessageType)type
                              success:(void(^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, GFMessageMTL *message))success
                              failure:(void(^)(NSUInteger taskId, NSError *error))failure;

/**
 *  获取消息列表
 *
 *  @param type             要获取的消息列表类型
 *  @param refQueryTime     查询时间值，第一次查询时传空值 nil
 *  @param size             消息数量
 *
 *  @return taskId
 */
+ (NSUInteger)getMessageListWithBasicType:(GFBasicMessageType)type
                        refQueryTime:(NSNumber *)refQueryTime
                                size:(NSInteger)size
                             success:(void(^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, NSNumber *refTime, NSArray *messages))success
                             failure:(void(^)(NSUInteger taskId, NSError *error))failure;

@end
