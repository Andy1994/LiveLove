//
//  GFNetworkManager+Follow.m
//  GetFun
//
//  Created by Liu Peng on 16/3/14.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFNetworkManager+Follow.h"
#import "GFNetworkManager.h"

#define GF_API_FOLLOW   ApiAddress(@"/api/userfollower/follow")
#define GF_API_CANCEL_FOLLOW    ApiAddress(@"/api/userfollower/cancelFollow")
#define GF_API_FOLLOWER_LIST    ApiAddress(@"/api/userfollower/getFollowerList")
#define GF_API_FOLLOWEE_LIST    ApiAddress(@"/api/userfollower/getFolloweeList")

@implementation GFNetworkManager (Follow)

+ (NSUInteger)followWithUserId:(NSNumber *)userId
                       success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage))success
                       failure:(void (^)(NSUInteger taskId, NSError *error))failure {
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_FOLLOW
                                                    parameters:@{@"userId":userId}
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];
                                                           if (success) {
                                                               success(taskId, code, apiErrorMessage);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

+ (NSUInteger)cancelFollowWithUserId:(NSNumber *)userId
                             success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage))success
                             failure:(void (^)(NSUInteger taskId, NSError *error))failure {
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_CANCEL_FOLLOW
                                                    parameters:@{@"userId":userId}
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];
                                                           if (success) {
                                                               success(taskId, code, apiErrorMessage);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}


+ (NSUInteger)queryFollowerListWithUserId:(NSNumber *)userId
                                  refTime:(NSNumber *)refTime
                                  success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, NSArray<GFFollowerMTL *> *followerList, NSNumber *refTime))success
                                  failure:(void (^)(NSUInteger taskId, NSError *error))failure {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:0];
    if (userId) {
        [params setObject:userId forKey:@"userId"];
    }
    if (refTime) {
        [params setObject:refTime forKey:@"queryTime"];
    }
    [params setObject:@(kQueryDataCount) forKey:@"size"];
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_FOLLOWER_LIST
                                                    parameters:params
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSNumber *refTime = [responseObject objectForKey:@"queryTime"];
                                                           NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];
                                                           NSArray<GFFollowerMTL *> *followers = nil;
                                                           if (code == 1) {
                                                               NSArray *tmpFollowers = [responseObject objectForKey:@"dataList"];
                                                               followers = [MTLJSONAdapter modelsOfClass:[GFFollowerMTL class] fromJSONArray:tmpFollowers error:nil];
                                                           }
                                                           success(taskId, code, apiErrorMessage, followers, refTime);
                                                           
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}


+ (NSUInteger)queryFolloweeListWithUserId:(NSNumber *)userId
                                  refTime:(NSNumber *)refTime
                                  success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, NSArray<GFFollowerMTL *> *followeeList, NSNumber *refTime))success
                                  failure:(void (^)(NSUInteger taskId, NSError *error))failure {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:0];
    if (userId) {
        [params setObject:userId forKey:@"userId"];
    }
    if (refTime) {
        [params setObject:refTime forKey:@"queryTime"];
    }
    [params setObject:@(kQueryDataCount) forKey:@"size"];
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_FOLLOWEE_LIST
                                                    parameters:params
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSNumber *refTime = [responseObject objectForKey:@"queryTime"];
                                                           NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];
                                                           NSArray<GFFollowerMTL *> *followers = nil;
                                                           if (code == 1) {
                                                               NSArray *tmpFollowers = [responseObject objectForKey:@"dataList"];
                                                               followers = [MTLJSONAdapter modelsOfClass:[GFFollowerMTL class] fromJSONArray:tmpFollowers error:nil];
                                                           }
                                                           success(taskId, code, apiErrorMessage, followers, refTime);
                                                           
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
    
}

@end
