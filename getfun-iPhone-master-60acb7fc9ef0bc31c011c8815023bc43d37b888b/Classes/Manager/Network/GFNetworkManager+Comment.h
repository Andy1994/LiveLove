//
//  GFNetworkManager+Comment.h
//  GetFun
//
//  Created by muhuaxin on 15/11/19.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFNetworkManager.h"
#import "GFCommentMTL.h"
#import "GFFunRecordMTL.h"

@interface GFNetworkManager (Comment)

// 发布评论
+ (NSUInteger)addCommentWithRelateId:(NSNumber *)relatedId
                             content:(NSString *)content
                            parentId:(NSNumber *)parentId
                             success:(void (^)(NSUInteger taskId, NSInteger code, GFCommentMTL *comment, NSString *errorMessage))success
                             failure:(void (^)(NSUInteger taskId, NSError *error))failure;

// fun评论
+ (NSUInteger)addFunWithCommentId:(NSNumber *)commentId
                          success:(void (^)(NSUInteger taskId, NSInteger code, NSString *errorMessage))success
                          failure:(void (^)(NSUInteger taskId, NSError *error))failure;

// 获取文章的热门评论
+ (NSUInteger)getHotCommentsByRelatedId:(NSNumber *)relatedId
                                success:(void (^)(NSUInteger taskId, NSInteger code, NSArray<GFCommentMTL *> *comments, NSString *errorMessage))success
                                failure:(void (^)(NSUInteger taskId, NSError *error))failure;

// 获取文章的评论列表
+ (NSUInteger)getCommentsWithContentId:(NSNumber *)contentId
                           queryTime:(NSNumber *)queryTime
                             success:(void (^)(NSUInteger taskId, NSInteger code, NSArray<GFCommentMTL *> *comments, NSNumber *nextQueryTime, NSString *errorMessage))success
                             failure:(void (^)(NSUInteger taskId, NSError *error))failure;
// 获取评论的回复评论
+ (NSUInteger)getCommentsReplyToCommentId:(NSNumber *)commentId
                                queryTime:(NSNumber *)queryTime
                                  success:(void (^)(NSUInteger taskId, NSInteger code, NSArray<GFCommentMTL *> *comments, NSNumber *nextQueryTime, NSString *errorMessage, BOOL hasMore))success
                                  failure:(void (^)(NSUInteger taskId, NSError *error))failure;


// 获取用户发布的评论
+ (NSUInteger)getCommentsByUserId:(NSNumber *)userId
                        queryTime:(NSNumber *)queryTime
                          success:(void (^)(NSUInteger taskId, NSInteger code, NSArray<GFCommentMTL *> *comments, NSNumber *nextQueryTime, NSString *errorMessage))success
                          failure:(void (^)(NSUInteger taskId, NSError *error))failure;

// 获取某个帖子的新增评论数
+ (NSUInteger)getNewCommentsCountWithContentId:(NSNumber *)contentId
                                     queryTime:(NSNumber *)queryTime
                                       success:(void (^)(NSUInteger taskId, NSInteger code, NSInteger updateCount))success
                                       failure:(void (^)(NSUInteger taskId, NSError *error))failure;

// 获取用户针对某帖子的评论
+ (NSUInteger)getCommentsWithContentId:(NSNumber *)contentId
                                userId:(NSNumber *)userId
                             queryTime:(NSNumber *)queryTime
                               success:(void (^)(NSUInteger taskId, NSInteger code, NSArray<GFCommentMTL *> *comments, NSNumber *nextQueryTime, NSNumber *countQueryTime, NSString *errorMessage))success
                               failure:(void (^)(NSUInteger taskId, NSError *error))failure;


// 获取单条评论
+ (NSUInteger)getCommentWithCommentId:(NSNumber *)commentId
                              success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, GFCommentMTL *comment))success
                              failure:(void (^)(NSUInteger taskId, NSError *error))failure;

/**
 *  获取用户的FUN记录
 *
 *  @param userId       用户id
 *  @param refQueryTime 上一次查询时服务器返回的queryTime，用于作为本次请求的ref
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)getFunRecordWithUserId:(NSNumber *)userId
                        refQueryTime:(NSNumber *)refQueryTime
                             success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, NSNumber *refQueryTime, GFUserMTL *user, NSArray<GFFunRecordMTL *> *funRecords))success
                             failure:(void(^)(NSUInteger taskId, NSError *error))failure;

@end
