//
//  GFNetworkManager+Content.h
//  GetFun
//
//  Created by zhouxz on 15/11/14.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFNetworkManager.h"
#import "GFTagMTL.h"

@class GFContentMTL;

// 详情页的跳转来源
typedef NS_ENUM(NSUInteger, GFKeyFrom) {
    GFKeyFromUnkown,
    GFKeyFromHome,      // 首页
    GFKeyFromProfile,   // 个人页
    GFKeyFromGroup,     // get帮内容列表
    GFKeyFromTag        // 标签内容列表
};

@interface GFNetworkManager (Content)

/**
 *  获取指定标签的内容列表
 *
 *  @param tagId   标签ID
 *  @param count   返回内容的数量
 *  @param maxPublishTime   最大发布时间，毫秒时间戳	用于翻页，应填写上次请求到的最后一个内容的createTime，若不填返回最新的内容
 *  @param success
 *  @param failure
 *
 *  @return
 */
+ (NSUInteger)queryContentListWithTag:(NSUInteger)tagId
                                count:(NSUInteger)count
                       maxPublishTime:(NSNumber *)maxPublishTime
                              success:(void (^)(NSUInteger taskId, NSInteger code, NSArray<GFContentMTL *> * contentList))success
                              failure:(void (^)(NSUInteger taskId, NSError *error))failure;


/**
 *  获取首页内容列表
 *
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)queryHomeContentSuccess:(void (^)(NSUInteger taskId, NSInteger code, NSArray<GFContentMTL *> * contentList))success
                              failure:(void (^)(NSUInteger taskId, NSError *error))failure;

/**
 *  不喜欢
 *
 *  @param contentId 内容id
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)dislikeContentWithContentId:(NSNumber *)contentId
                                  success:(void (^)(NSUInteger taskId, NSInteger code))success
                                  failure:(void(^)(NSUInteger taskId, NSError *error))failure;

/**
 *  获取内容详情
 *
 *  @param contentId 内容id
 *  @param keyFrom 该API请求的来源
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)getContentWithContentId:(NSNumber *)contentId
                              keyFrom:(GFKeyFrom) keyFrom
                              success:(void(^)(NSUInteger taskId, NSInteger code, GFContentMTL * content, NSDictionary * data, NSString *errorMessage))success
                              failure:(void(^)(NSUInteger taskId, NSError *error))failure;


+ (NSUInteger)changeFunStatusWithContentId:(NSNumber *)contentId
                                     isFun:(BOOL)isFun
                                   success:(void(^)(NSUInteger taskId, NSInteger code, NSString *errorMessage))success
                                   failure:(void(^)(NSUInteger taskId, NSError *error))failure;

/**
 *  举报内容
 */
+ (NSUInteger)reportContentWithContentId:(NSNumber *)contentId
                              reportInfo:(NSString *)reportInfo
                                 success:(void(^)(NSUInteger taskId, NSInteger code, NSString *errorMessage))success
                                 failure:(void(^)(NSUInteger taskId, NSError *error))failure;

/**
 *  投票
 *
 *  @param contentId  文章Id，非空
 *  @param voteItemId 选项Id，非空
 *
 */
+ (NSUInteger)voteWithContentId:(NSNumber *)contentId
                     voteItemId:(NSNumber *)voteItemId
                        success:(void(^)(NSUInteger taskId, NSInteger code, NSString *errorMessage))success
                        failure:(void(^)(NSUInteger taskId, NSError *error))failure;

/**
 *  获取用户发布的内容
 *
 *  @param userId         用户id
 *  @param refPublishTime 上一次获取的最后一条数据的publishtime，若为空，则返回最新发布的内容
 *  @param count          获取的数量
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)queryPublishedContentWithUserId:(NSNumber *)userId
                               refPublishTime:(NSNumber *)refPublishTime
                                        count:(NSInteger)count
                                      success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, NSArray<GFContentMTL *> * contentList))success
                                      failure:(void(^)(NSUInteger taskId, NSError *error))failure;

/**
 *  获取用户参与的内容
 *
 *  @param userId         用户id
 *  @param refPublishTime 同上
 *  @param count          获取的数量
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)queryParticipateContentWithUserId:(NSNumber *)userId
                                 refPublishTime:(NSNumber *)refPublishTime
                                          count:(NSInteger)count
                                        success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, NSArray<GFContentMTL *> * contentList))success
                                        failure:(void(^)(NSUInteger taskId, NSError *error))failure;

/**
 *  删除内容
 */
+ (NSUInteger)deleteContentWithContentId:(NSNumber *)contentId
                                 success:(void(^)(NSUInteger taskId, NSInteger code, NSString *errorMessage))success
                                 failure:(void(^)(NSUInteger taskId, NSError *error))failure;

// 分享上报
+ (NSUInteger)didShareContentWithContentId:(NSNumber *)contentId
                                 shareType:(NSString *)shareType;
// 分享上报 带回调
+ (NSUInteger)didShareContentWithContentId:(NSNumber *)contentId shareType:(NSString *)shareType success:(void (^)())success fail: (void (^)())fail;
@end
