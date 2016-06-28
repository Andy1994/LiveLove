//
//  GFNetworkManager+Group.h
//  GetFun
//
//  Created by Liu Peng on 15/12/1.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFNetworkManager.h"
#import "GFGroupMTL.h"
#import "GFGroupMemberMTL.h"
#import "GFGroupContentMTL.h"

@interface GFNetworkManager (Group)

/**
 *  按地理位置获取推荐的get帮
 *
 *  @param longitude 经度
 *  @param latitude  纬度
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)getRecommendGroupWithLongitude:(NSNumber *)longitude
                                    latitude:(NSNumber *)latitude
                                     success:(void (^)(NSUInteger taskId, NSInteger code, NSArray<GFGroupMTL *> * interestGroupList, NSString *errorMessage))success
                                     failure:(void (^)(NSUInteger taskId, NSError *error))failure;

/**
 *  获取用户兴趣相关的get帮
 *
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)getUserInterestGroupSuccess:(void (^)(NSUInteger taskId, NSInteger code, NSArray<GFGroupMTL *> *interestGroupList,  BOOL hasMore, NSString *errorMessage))success
                                  failure:(void (^)(NSUInteger taskId, NSError *error))failure;

/**
 *  根据关键词搜索Get帮
 *
 *  @param keyword      get帮关键词，模糊匹配
 *  @param queryTime    查询时间
 *  @param count        结果数量
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)getGroupWithKeyword:(NSString *)keyword
                        queryTime:(NSNumber *)queryTime
                            count:(NSInteger)count
                          success:(void (^)(NSUInteger taskId, NSInteger code, NSArray<GFGroupMTL *> * groupList, NSNumber *queryTime, NSString *apiErrorMessage))success
                          failure:(void (^)(NSUInteger taskId, NSError *error))failure;


/**
 *  获取get帮成员，按加入时间排序
 *
 *  @param groupId   get帮ID
 *  @param queryTime 查询时间，获取该时间之前的数据，第一页可不传
 *  @param count     结果数量
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)getMemberListWithGroupId:(NSNumber *)groupId
                             queryTime:(NSNumber *)queryTime
                                 count:(NSInteger)count
                               success:(void (^)(NSUInteger taskId, NSInteger code, NSArray<GFGroupMemberMTL *> * memberList, NSNumber *queryTime, NSString *apiErrorMessage))success
                               failure:(void (^)(NSUInteger taskId, NSError *error))failure;


/**
 *  根据groupId获取单个Get帮信息
 *
 *  @param groupId
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)getGroupWithGroupId:(NSNumber *)groupId
                          success:(void (^)(NSUInteger taskId, NSInteger code,  GFGroupMTL *group, NSString *apiErrorMessage))success
                          failure:(void (^)(NSUInteger taskId, NSError *error))failure;

/**
 *  获取用户创建、加入的get帮
 *
 *  @param userId
 *  @param refQueryTime
 *  @param count
 *  @param success
 *
 *  @return taskId
 */
+ (NSUInteger)getGroupWithUserId:(NSNumber *)userId
                    refQueryTime:(NSNumber *)refQueryTime
                           count:(NSInteger)count
                         success:(void(^)(NSUInteger taskId, NSInteger code, NSNumber *refQueryTime, NSString *apiErrorMessage, NSArray<GFGroupMTL *> * groupList))success
                         failure:(void (^)(NSUInteger taskId, NSError *error))failure;

/**
 *  创建get帮
 *
 *  @param parameters 创建get帮参数
 *  @param success
 *  @param failure
 *
 *  @return taskId
 参数名	类型	是否可为空	含义	备注
 name	String	否	名称
 imgUrl	String	否	get帮头像
 tagId	long	否	兴趣ID
 address	String	否	地址
 longitude	double	否	经度
 latitude	double	否	纬度
 description	String	否	描述
 */
+ (NSUInteger)createGroupWithParameters:(NSDictionary *)parameters
                                success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage))success
                                failure:(void (^)(NSUInteger taskId, NSError *error))failure;


/**
 *  加入get帮
 *
 *  @param groupId get帮Id
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)joinGroupWithGroupId:(NSNumber *)groupId
                           success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage))success
                           failure:(void (^)(NSUInteger taskId, NSError *error))failure;

// 退出get帮
+ (NSUInteger)quitGroupWithGroupId:(NSNumber *)groupId
                           success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage))success
                           failure:(void (^)(NSUInteger taskId, NSError *error))failure;
/**
 *  在Get帮签到
 *
 *  @param groupId 群组Id
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)checkinGroupWithGroupId:(NSNumber *)groupId
                              success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage))success
                              failure:(void (^)(NSUInteger taskId, NSError *error))failure;


/**
 *  更新get帮信息
 *
 *  @param parameters 更新get帮参数
 *  @param success
 *  @param failure
 *
 *  @return taskId
 
 参数名	类型     是否可为空	含义	备注
 id     long	否	get帮ID
 name	String	否	名称
 imgUrl	String	否	get帮头像
 description	String	否	描述
 */
+ (NSUInteger)updateGroupWithParameters:(NSDictionary *)parameters
                                success:(void(^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage))success
                                failure:(void (^)(NSUInteger taskId, NSError *error))failure;

// get帮详情页内容列表
+ (NSUInteger)getGroupContentsWithGroupId:(NSNumber *)groupId
                             refQueryTime:(NSNumber *)refQueryTime
                                    count:(NSInteger)count
                                  success:(void (^)(NSUInteger taskId, NSInteger code, NSArray<GFGroupContentMTL *> * groupContentList, NSString *errorMessage))success
                                  failure:(void (^)(NSUInteger taskId, NSError *error))failure;

@end
