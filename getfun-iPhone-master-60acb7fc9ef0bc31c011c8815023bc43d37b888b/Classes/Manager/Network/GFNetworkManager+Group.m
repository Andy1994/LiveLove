//
//  GFNetworkManager+Group.m
//  GetFun
//
//  Created by Liu Peng on 15/12/1.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFNetworkManager+Group.h"
#import "GFAccountManager.h"

#define GF_API_QUERY_INTERESTGROUP_LIST_BY_LOCATION ApiAddress(@"/api/interestGroup/getRecommendGroups")
#define GF_API_QUERY_INTERESTGROUP_MEMBER_LIST ApiAddress(@"/api/interestGroup/membersByGroup")
#define GF_API_QUERY_INTERESTGROUP ApiAddress(@"/api/interestGroup/groupInfo")
#define GF_API_QUERY_INTERESTGROUP_LIST_BY_INTEREST ApiAddress(@"api/interestGroup/getInterestingGroups")
#define GF_API_QUERY_INTERESTGROUP_LIST_BY_NAME ApiAddress(@"api/interestGroup/searchGroups")
#define GF_API_QUERY_GROUP_BY_USER ApiAddress(@"/api/interestGroup/groupsByUser")
#define GF_API_UPDATE_INTERESTGROUP ApiAddress(@"/api/interestGroup/update")
#define GF_API_QUERY_GROUP_CONTENT_LIST ApiAddress(@"/api/interestGroup/operations")
#define GF_API_CREATE_INTERESTGROUP ApiAddress(@"/api/interestGroup/add")
#define GF_API_JOIN_INTERESTGROUP ApiAddress(@"/api/interestGroup/joinGroup")
#define GF_API_QUIT_GROUP ApiAddress(@"/api/interestGroup/leaveGroup")
#define GF_API_CHECKIN_INTERESTGROUP ApiAddress(@"/api/interestGroup/checkin")

@implementation GFNetworkManager (Group)

+ (NSUInteger)getRecommendGroupWithLongitude:(NSNumber *)longitude
                                    latitude:(NSNumber *)latitude
                                     success:(void (^)(NSUInteger taskId, NSInteger code, NSArray<GFGroupMTL *> * interestGroupList, NSString *errorMessage))success
                                     failure:(void (^)(NSUInteger taskId, NSError *error))failure {
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_QUERY_INTERESTGROUP_LIST_BY_LOCATION
                                                    parameters:@{@"longitude":longitude,
                                                                 @"latitude":latitude}
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           if (code == 1) {
                                                               NSArray *tmpInterestGroupList = [responseObject objectForKey:@"dataList"];
                                                               NSArray *interestGroupList = [MTLJSONAdapter modelsOfClass:[GFGroupMTL class] fromJSONArray:tmpInterestGroupList error:nil];
                                                               
                                                               success(taskId, code, interestGroupList, nil);
                                                               
                                                           } else {
                                                               success(taskId, code, nil, nil);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           failure(taskId, error);
                                                       }];
    return taskId;
    
}

+ (NSUInteger)getUserInterestGroupSuccess:(void (^)(NSUInteger taskId, NSInteger code, NSArray<GFGroupMTL *> *interestGroupList,  BOOL hasMore, NSString *errorMessage))success
                                  failure:(void (^)(NSUInteger taskId, NSError *error))failure{
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_QUERY_INTERESTGROUP_LIST_BY_INTEREST
                                                    parameters:@{}
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           BOOL hasMore = [[responseObject objectForKey:@"hasMore"] boolValue];
                                                           if (code == 1) {
                                                               NSArray *tmpInterestGroupList = [responseObject objectForKey:@"dataList"];
                                                               NSArray *interestGroupList = [MTLJSONAdapter modelsOfClass:[GFGroupMTL class] fromJSONArray:tmpInterestGroupList error:nil];
                                                               success(taskId, code, interestGroupList, hasMore, nil);
                                                               
                                                           } else {
                                                               success(taskId, code, nil, hasMore, [responseObject objectForKey:@"apiErrorMessage"]);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           failure(taskId, error);
                                                       }];
    return taskId;
}

+ (NSUInteger)getGroupWithKeyword:(NSString *)keyword
                        queryTime:(NSNumber *)queryTime
                            count:(NSInteger)count
                          success:(void (^)(NSUInteger taskId, NSInteger code, NSArray<GFGroupMTL *> * groupList, NSNumber *queryTime, NSString *apiErrorMessage))success
                          failure:(void (^)(NSUInteger taskId, NSError *error))failure {
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_QUERY_INTERESTGROUP_LIST_BY_NAME
                                                    parameters:@{@"groupName":keyword,
                                                                 @"queryTime" : queryTime? queryTime : @"",
                                                                 @"size": [NSNumber numberWithInteger:count]}
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           if (code == 1) {
                                                               NSArray *tmpGroupList = [responseObject objectForKey:@"dataList"];
                                                               NSArray<GFGroupMTL *> *groupList = [MTLJSONAdapter modelsOfClass:[GFGroupMTL class] fromJSONArray:tmpGroupList error:nil];
                                                               success(taskId, code, groupList,[responseObject objectForKey:@"queryTime"], nil);
                                                               
                                                           } else {
                                                               success(taskId, code, nil, [responseObject objectForKey:@"queryTime"], [responseObject objectForKey:@"apiErrorMessage"]);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           failure(taskId, error);
                                                       }];
    return taskId;
}

+ (NSUInteger)getMemberListWithGroupId:(NSNumber *)groupId
                             queryTime:(NSNumber *)queryTime
                                 count:(NSInteger)count
                               success:(void (^)(NSUInteger taskId, NSInteger code, NSArray<GFGroupMemberMTL *> * memberList, NSNumber *queryTime, NSString *apiErrorMessage))success
                               failure:(void (^)(NSUInteger taskId, NSError *error))failure {
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_QUERY_INTERESTGROUP_MEMBER_LIST
                                                    parameters:@{@"groupId" : groupId,
                                                                 @"queryTime" : queryTime? queryTime : @"",
                                                                 @"size": [NSNumber numberWithInteger:count]}
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];
                                                           NSNumber *queryTime = [responseObject objectForKey:@"queryTime"];
                                                           NSArray<GFGroupMemberMTL *> *memberList = nil;
                                                           if (code == 1) {
                                                               NSArray *tmpMemberList = [responseObject objectForKey:@"dataList"];
                                                               memberList = [MTLJSONAdapter modelsOfClass:[GFGroupMemberMTL class] fromJSONArray:tmpMemberList error:nil];
                                                           }
                                                           if (success) {
                                                               success(taskId, code, memberList, queryTime, apiErrorMessage);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
    
}

+ (NSUInteger)getGroupWithGroupId:(NSNumber *)groupId
                          success:(void (^)(NSUInteger taskId, NSInteger code,  GFGroupMTL *group, NSString *apiErrorMessage))success
                          failure:(void (^)(NSUInteger taskId, NSError *error))failure {
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_QUERY_INTERESTGROUP
                                                    parameters:@{@"groupId" : groupId}
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];
                                                           GFGroupMTL *group = nil;
                                                           if (code == 1) {
                                                               group = [MTLJSONAdapter modelOfClass:[GFGroupMTL class] fromJSONDictionary:[responseObject objectForKey:@"group"] error:nil];
                                                           }
                                                           if (success) {
                                                               success(taskId, code, group, apiErrorMessage);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                           
                                                       }];
    return taskId;
    
}

+ (NSUInteger)getGroupWithUserId:(NSNumber *)userId
                    refQueryTime:(NSNumber *)refQueryTime
                           count:(NSInteger)count
                         success:(void (^)(NSUInteger, NSInteger, NSNumber *, NSString *, NSArray<GFGroupMTL *> * ))success
                         failure:(void (^)(NSUInteger, NSError *))failure {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                        @"userId" : userId,
                                                                                        @"size" : [NSNumber numberWithInteger:count]
                                                                                        }];
    if (refQueryTime) {
        [parameters setObject:refQueryTime forKey:@"queryTime"];
    }
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_QUERY_GROUP_BY_USER
                                                    parameters:parameters
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];
                                                           NSNumber *queryTime = [responseObject objectForKey:@"queryTime"];
                                                           NSArray *groupData = [responseObject objectForKey:@"dataList"];
                                                           NSArray *groupList = [MTLJSONAdapter modelsOfClass:[GFGroupMTL class] fromJSONArray:groupData error:nil];
                                                           if (success) {
                                                               success(taskId, code, queryTime, apiErrorMessage, groupList);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

+ (NSUInteger)createGroupWithParameters:(NSDictionary *)parameters
                                success:(void (^)(NSUInteger, NSInteger, NSString *))success
                                failure:(void (^)(NSUInteger, NSError *))failure {
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_CREATE_INTERESTGROUP
                                                    parameters:parameters
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

+ (NSUInteger)joinGroupWithGroupId:(NSNumber *)groupId
                           success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage))success
                           failure:(void (^)(NSUInteger taskId, NSError *error))failure {
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_JOIN_INTERESTGROUP
                                                    parameters:@{@"groupId":groupId}
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

+ (NSUInteger)quitGroupWithGroupId:(NSNumber *)groupId
                           success:(void (^)(NSUInteger, NSInteger, NSString *))success
                           failure:(void (^)(NSUInteger, NSError *))failure {
    if (!groupId) {
        return 0;
    }
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_QUIT_GROUP
                                                    parameters:@{
                                                                 @"groupId" : groupId
                                                                 }
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *apiErrorMsg = [responseObject objectForKey:@"apiErrorMessage"];
                                                           if (success) {
                                                               success(taskId, code, apiErrorMsg);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

+ (NSUInteger)checkinGroupWithGroupId:(NSNumber *)groupId
                              success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage))success
                              failure:(void (^)(NSUInteger taskId, NSError *error))failure {
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_CHECKIN_INTERESTGROUP
                                                    parameters:@{@"groupId":groupId}
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


+ (NSUInteger)updateGroupWithParameters:(NSDictionary *)parameters
                                success:(void (^)(NSUInteger, NSInteger, NSString *))success
                                failure:(void (^)(NSUInteger, NSError *))failure {
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_UPDATE_INTERESTGROUP
                                                    parameters:parameters
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

+ (NSUInteger)getGroupContentsWithGroupId:(NSNumber *)groupId
                             refQueryTime:(NSNumber *)refQueryTime
                                    count:(NSInteger)count
                                  success:(void (^)(NSUInteger taskId, NSInteger code, NSArray<GFGroupContentMTL *> * groupContentList, NSString *errorMessage))success
                                  failure:(void (^)(NSUInteger taskId, NSError *error))failure {
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_QUERY_GROUP_CONTENT_LIST
                                                    parameters:@{@"groupId":groupId, @"maxOperationTime":refQueryTime, @"count":[NSNumber numberWithInteger:count]}
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSMutableArray *groupContents = [[NSMutableArray alloc] initWithCapacity:0];
                                                           NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];
                                                           if (code == 1) {
                                                               NSArray *tmpGroupContents = [responseObject objectForKey:@"data"];
                                                               for (NSDictionary *dict in tmpGroupContents) {
                                                                   GFGroupContentMTL *groupContent = [MTLJSONAdapter modelOfClass:[GFGroupContentMTL class] fromJSONDictionary:dict error:nil];
                                                                   if (groupContent && groupContent.content) {
                                                                       [groupContents addObject:groupContent];
                                                                   }
                                                               }
                                                           }
                                                           
                                                           if (success) {
                                                              success(taskId, code, groupContents, apiErrorMessage);
                                                           }
                                                           
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           failure(taskId, error);
                                                       }];
    return taskId;
    
}

@end
