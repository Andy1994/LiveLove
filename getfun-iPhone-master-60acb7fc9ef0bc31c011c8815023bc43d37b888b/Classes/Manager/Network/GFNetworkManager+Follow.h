//
//  GFNetworkManager+Follow.h
//  GetFun
//
//  Created by Liu Peng on 16/3/14.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFNetworkManager.h"
#import "GFFollowerMTL.h"

@interface GFNetworkManager (Follow)
/**
 *  关注操作
 *
 *  @param userId  欲关注用户id
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)followWithUserId:(NSNumber *)userId
                            success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage))success
                            failure:(void (^)(NSUInteger taskId, NSError *error))failure;
/**
 *  取消关注
 *
 *  @param userId  被关注用户id
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)cancelFollowWithUserId:(NSNumber *)userId
                       success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage))success
                       failure:(void (^)(NSUInteger taskId, NSError *error))failure;

/**
 *  获取关注当前用户的人列表，即获取该用户的粉丝列表
 *
 *  @param userId  获取该用户的粉丝列表，不传时则取当前登录用户的粉丝列表
 *  @param refTime 查询时间，第一页时可为空，每次返回数据中包含该参数，直接返回即可。	-1表示无更多数据，不用请求下一页
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)queryFollowerListWithUserId:(NSNumber *)userId
                                refTime:(NSNumber *)refTime
                       success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, NSArray<GFFollowerMTL *> *followerList, NSNumber *refTime))success
                       failure:(void (^)(NSUInteger taskId, NSError *error))failure;

/**
 *  获取当前用户关注的人列表
 *
 *  @param userId  获取该用户的关注对象列表，不传时则取当前登录用户的关注对象列表
 *  @param refTime 查询时间，第一页时可为空，每次返回数据中包含该参数，直接返回即可。	-1表示无更多数据，不用请求下一页
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)queryFolloweeListWithUserId:(NSNumber *)userId
                                  refTime:(NSNumber *)refTime
                                  success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, NSArray<GFFollowerMTL *> *followeeList, NSNumber *refTime))success
                                  failure:(void (^)(NSUInteger taskId, NSError *error))failure;
@end
