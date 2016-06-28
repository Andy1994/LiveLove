//
//  GFNetworkManager+Tag.h
//  GetFun
//
//  Created by zhouxz on 15/12/18.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFNetworkManager.h"
#import "GFTagMTL.h"
#import "GFContentMTL.h"
#import "GFGroupMTL.h"

@interface GFNetworkManager (Tag)

// 获取热门标签
+ (NSUInteger)getHotTagSuccess:(void (^)(NSUInteger taskId, NSInteger code, NSString *errorMessage, NSArray<GFTagMTL *> *tags))success
                       failure:(void (^)(NSUInteger taskId, NSError *error))failure;

// 获取标签详情
+ (NSUInteger)getTagDetail:(NSNumber *)tagId
                   success:(void (^)(NSUInteger taskId, NSInteger code, NSString *errorMessage, NSArray<GFContentMTL *> *contents, NSArray<GFGroupMTL *> *groups, GFTagMTL *tag))success
                   failure:(void (^)(NSUInteger taskId, NSError *error))failure;

// 获取用户关注的标签
+ (NSUInteger)getCollectedTagWithRefTime:(NSNumber *)refTime
                                 success:(void (^)(NSUInteger taskId, NSInteger code, NSString *errorMessage, NSArray<GFTagMTL *> *tags, NSInteger totalCount))success
                                 failure:(void (^)(NSUInteger taskId, NSError *error))failure;
// 关注、取消关注标签
+ (NSUInteger)collectTag:(NSNumber *)tagId
                 collect:(BOOL)collect
                 success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage))success
                 failure:(void (^)(NSUInteger taskId, NSError *error))failure;

// 获取推荐的兴趣标签
+ (NSUInteger)getRecommendInterestTagsSuccess:(void (^)(NSUInteger taskId, NSInteger code, NSArray<GFTagMTL *>  * tags, NSString *errorMessage))success
                                      failure:(void (^)(NSUInteger taskId, NSError *error))failure;

// 获取所有的兴趣标签
+ (NSUInteger)getAllInterestTagsSuccess:(void (^)(NSUInteger taskId, NSInteger code, NSArray<GFTagInfoMTL *> * tags, NSString *errorMessage))success
                                failure:(void (^)(NSUInteger taskId, NSError *error))failure;


@end
