//
//  GFNetworkManager+Comment.m
//  GetFun
//
//  Created by muhuaxin on 15/11/19.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFNetworkManager+Comment.h"
#import "GFAccountManager.h"

#define ApiAddComment ApiAddress(@"/api/comment/add")
#define ApiAddFun ApiAddress(@"/api/comment/fun")
#define ApiGetHotsComment ApiAddress(@"/api/comment/getHotComments")
#define ApiGetCommentsWithContentId ApiAddress(@"/api/comment/getCommentsByRelatedId")
#define ApiGetCommentsReplytoComment ApiAddress(@"/api/comment/getCommentsByRootId")
#define ApiGetCommentsByUserId ApiAddress(@"/api/comment/getCommentsByUser")
#define ApiGetCommentsByRelatedAndUserId ApiAddress(@"/api/comment/getCommentsByRelatedIdAndUserId")
#define ApiGetNewCommentsCount ApiAddress(@"/api/comment/newCommentCountByRelatedId")
#define GF_API_GET_COMMENT_WITH_COMMENT_ID ApiAddress(@"/api/comment/get")
#define ApiGetFunRecordsWithUserId ApiAddress(@"/api/fun/getFunRecord")

@implementation GFNetworkManager (Comment)

//发布评论
+ (NSUInteger)addCommentWithRelateId:(NSNumber *)relatedId
                             content:(NSString *)content
                            parentId:(NSNumber *)parentId
                             success:(void (^)(NSUInteger taskId, NSInteger code, GFCommentMTL *comment, NSString *errorMessage))success
                             failure:(void (^)(NSUInteger taskId, NSError *error))failure
{
    if (content.length == 0 || !relatedId) {
        if (failure) {
            failure(0, nil);
        }
        return 0;
    }
    NSMutableDictionary *paramters = [@{
                                        @"relatedId" : relatedId,
                                        @"content" : content,
                                        } mutableCopy];
     if (parentId != nil) {
        [paramters setObject:parentId forKey:@"parentId"];
    }
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:ApiAddComment parameters:paramters
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [responseObject[@"code"] integerValue];
                                                           GFCommentMTL *comment = nil;
                                                           NSString *apiErrorMessage = responseObject[@"apiErrorMessage"];
                                                           if (code == 1) {
                                                               NSDictionary *data = responseObject[@"extendComment"];
                                                               if (data && ![data isKindOfClass:[NSNull class]]) {
                                                                   comment = [MTLJSONAdapter modelOfClass:[GFCommentMTL class] fromJSONDictionary:data error:nil];
                                                               }
                                                           }
                                                           if (success) {
                                                               success(taskId, code, comment, apiErrorMessage);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

//fun评论
+ (NSUInteger)addFunWithCommentId:(NSNumber *)commentId
                          success:(void (^)(NSUInteger taskId, NSInteger code, NSString *errorMessage))success
                          failure:(void (^)(NSUInteger taskId, NSError *error))failure;
{
    if (!commentId) {
        if (failure) {
            failure(0, nil);
        }
        return 0;
    }

    NSDictionary *paramters = @{
                                @"commentId" : commentId,
                                };
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:ApiAddFun parameters:paramters
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [responseObject[@"code"] integerValue];
                                                           if (success) {
                                                               success(taskId, code, responseObject[@"apiErrorMessage"]);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}
//获取文章的热门评论
+ (NSUInteger)getHotCommentsByRelatedId:(NSNumber *)relatedId
                                success:(void (^)(NSUInteger taskId, NSInteger code, NSArray<GFCommentMTL *> *comments, NSString *errorMessage))success
                                failure:(void (^)(NSUInteger taskId, NSError *error))failure
{
    if (!relatedId) {
        if (failure) {
            failure(0, nil);
        }
        return 0;
    }
    NSDictionary *paramters = @{
                                @"relatedId" : relatedId,
                                };
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:ApiGetHotsComment parameters:paramters
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [responseObject[@"code"] integerValue];
                                                           NSArray *comments = nil;
                                                           NSString *apiErrorMessage = responseObject[@"apiErrorMessage"];
                                                           if (code == 1) {
                                                               NSArray *dataList = responseObject[@"dataList"];
                                                               if (dataList && ![dataList isKindOfClass:[NSNull class]]) {
                                                                   comments = [MTLJSONAdapter modelsOfClass:[GFCommentMTL class] fromJSONArray:dataList error:nil];
                                                               }
                                                           }
                                                           if (success) {
                                                               success(taskId, code, comments, apiErrorMessage);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

+ (NSUInteger)getCommentsWithContentId:(NSNumber *)contentId
                             queryTime:(NSNumber *)queryTime
                               success:(void (^)(NSUInteger, NSInteger, NSArray<GFCommentMTL *> *, NSNumber *, NSString *))success
                               failure:(void (^)(NSUInteger, NSError *))failure {
    if(!contentId){
        if (failure) {
            failure(0,nil);
        }
        return 0;
    }
    NSMutableDictionary *paramters = [@{
                                @"relatedId" : contentId,
                                } mutableCopy];
    if (queryTime != nil) {
        [paramters setObject:queryTime forKey:@"queryTime"];
    }
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:ApiGetCommentsWithContentId parameters:paramters
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [responseObject[@"code"] integerValue];
                                                           if (code == 1) {
                                                               NSArray *dataList = responseObject[@"dataList"];
                                                               NSArray *comments = nil;
                                                               if (dataList && ![dataList isKindOfClass:[NSNull class]]) {
                                                                  comments = [MTLJSONAdapter modelsOfClass:[GFCommentMTL class] fromJSONArray:dataList error:nil];
                                                               }
                                                               if (success) {
                                                                   success(taskId, code, comments, responseObject[@"queryTime"], nil);
                                                               }
                                                           } else {
                                                               if (success) {
                                                                   success(taskId, code, nil, nil, responseObject[@"apiErrorMessage"]);
                                                               }
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

//获取评论的回复评论
+ (NSUInteger)getCommentsReplyToCommentId:(NSNumber *)commentId
                        queryTime:(NSNumber *)queryTime
                          success:(void (^)(NSUInteger taskId, NSInteger code, NSArray<GFCommentMTL *> *comments, NSNumber *nextQueryTime, NSString *errorMessage, BOOL hasMore))success
                          failure:(void (^)(NSUInteger taskId, NSError *error))failure
{
    if (!commentId) {
        if (failure) {
            failure(0,nil);
        }
        return 0;
    }
    NSMutableDictionary *paramters = [@{
                                        @"rootId" : commentId,
                                        } mutableCopy];
    if (queryTime != nil) {
        [paramters setObject:queryTime forKey:@"queryTime"];
    }
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:ApiGetCommentsReplytoComment parameters:paramters success:^(NSUInteger taskId, id responseObject) {
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 1) {
            BOOL hasMore = [[responseObject objectForKey:@"hasMoreChildren"] boolValue];
            NSArray *dataList = responseObject[@"dataList"];
            NSArray *comments = nil;
            if (dataList && ![dataList isKindOfClass:[NSNull class]]) {
               comments = [MTLJSONAdapter modelsOfClass:[GFCommentMTL class] fromJSONArray:dataList error:nil];
            }
            if (success) {
                success(taskId, code, comments, responseObject[@"queryTime"], nil, hasMore);
            }
        } else {
            if (success) {
                success(taskId, code, nil, nil, responseObject[@"apiErrorMessage"], NO);
            }
        }
    } failure:^(NSUInteger taskId, NSError *error) {
        if (failure) {
            failure(taskId, error);
        }
    }];
    return taskId;
}

//获取用户发布的评论
+ (NSUInteger)getCommentsByUserId:(NSNumber *)userId
                        queryTime:(NSNumber *)queryTime
                          success:(void (^)(NSUInteger taskId, NSInteger code, NSArray<GFCommentMTL *> *comments, NSNumber *nextQueryTime, NSString *errorMessage))success
                          failure:(void (^)(NSUInteger taskId, NSError *error))failure
{
    if (!userId) {
        if (failure) {
            failure(0,nil);
        }
        return 0;
    }
    NSMutableDictionary *paramters = [@{
                                        @"userId" : userId,
                                        } mutableCopy];
    if (queryTime != nil) {
        [paramters setObject:queryTime forKey:@"queryTime"];
    }
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:ApiGetCommentsByUserId parameters:paramters success:^(NSUInteger taskId, id responseObject) {
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 1) {
            NSArray *dataList = responseObject[@"dataList"];
            NSArray *comments = nil;
            if (dataList && ![dataList isKindOfClass:[NSNull class]]) {
                comments = [MTLJSONAdapter modelsOfClass:[GFCommentMTL class] fromJSONArray:dataList error:nil];
            }
            if (success) {
                success(taskId, code, comments, responseObject[@"queryTime"], nil);
            }
        } else {
            if (success) {
                success(taskId, code, nil, nil, responseObject[@"apiErrorMessage"]);
            }
        }
    } failure:^(NSUInteger taskId, NSError *error) {
        if (failure) {
            failure(taskId, error);
        }
    }];
    return taskId;
}

+ (NSUInteger)getNewCommentsCountWithContentId:(NSNumber *)contentId
                                     queryTime:(NSNumber *)queryTime
                                       success:(void (^)(NSUInteger, NSInteger, NSInteger))success
                                       failure:(void (^)(NSUInteger, NSError *))failure {
    if(!contentId){
        if (failure) {
            failure(0,nil);
        }
        return 0;
    }
    NSMutableDictionary *paramters = [@{
                                        @"relatedId" : contentId,
                                        } mutableCopy];
    if (queryTime != nil) {
        [paramters setObject:queryTime forKey:@"queryTime"];
    }

    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:ApiGetNewCommentsCount
                                                     parameters:paramters
                                                        success:^(NSUInteger taskId, id responseObject) {
                                                            NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                            NSInteger count = [[responseObject objectForKey:@"newCommentCount"] integerValue];
                                                           
                                                            if (success) {
                                                                success(taskId, code, count);
                                                            }
                                                        } failure:^(NSUInteger taskId, NSError *error) {
                                                            if (failure) {
                                                                failure(taskId, error);
                                                            }
                                                        }];
    return taskId;
}

+ (NSUInteger)getCommentsWithContentId:(NSNumber *)contentId
                                userId:(NSNumber *)userId
                             queryTime:(NSNumber *)queryTime
                               success:(void (^)(NSUInteger, NSInteger, NSArray<GFCommentMTL *> *, NSNumber *, NSNumber *, NSString *))success
                               failure:(void (^)(NSUInteger, NSError *))failure {
    if (!contentId) {
        if (failure) {
            failure(0,nil);
        }
        return 0;
    }
    NSMutableDictionary *paramters = [@{
                                        @"relatedId" : contentId,
                                        } mutableCopy];
    if (userId) {
        [paramters setObject:userId forKey:@"userId"];
    }
    if (queryTime) {
        [paramters setObject:queryTime forKey:@"queryTime"];
    }
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:ApiGetCommentsByRelatedAndUserId parameters:paramters
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSNumber *queryTime = [responseObject objectForKey:@"queryTime"];
                                                           NSNumber *countQueryTime = [responseObject objectForKey:@"newCountQueryTime"];
                                                           NSString *errorMsg = [responseObject objectForKey:@"apiErrorMessage"];
                                                           NSArray *comments = nil;
                                                           if (code == 1) {
                                                               NSArray *dataList = responseObject[@"dataList"];
                                                               if (dataList && ![dataList isKindOfClass:[NSNull class]]) {
                                                                   comments = [MTLJSONAdapter modelsOfClass:[GFCommentMTL class] fromJSONArray:dataList error:nil];
                                                               }
                                                           }
                                                           
                                                           if (success) {
                                                               success(taskId, code, comments, queryTime, countQueryTime, errorMsg);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

+ (NSUInteger)getCommentWithCommentId:(NSNumber *)commentId
                              success:(void (^)(NSUInteger, NSInteger, NSString *, GFCommentMTL *))success
                              failure:(void (^)(NSUInteger, NSError *))failure {
    
    if (!commentId) {
        if (failure) {
            failure(0,nil);
        }
        return 0;
    }
    NSMutableDictionary *paramters = [@{
                                        @"id" : commentId,
                                        } mutableCopy];
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_GET_COMMENT_WITH_COMMENT_ID
                                                    parameters:paramters
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];
                                                           NSDictionary *commentDict = [responseObject objectForKey:@"extendComment"];
                                                           GFCommentMTL *comment = nil;
                            
                                                           if (commentDict && ![commentDict isKindOfClass:[NSNull class]]) {
                                                               comment = [MTLJSONAdapter modelOfClass:[GFCommentMTL class] fromJSONDictionary:commentDict error:nil];
                                                           }
                                                           if (success) {
                                                               success(taskId, code, apiErrorMessage, comment);
                                                           }
                                                           
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

+ (NSUInteger)getFunRecordWithUserId:(NSNumber *)userId
                        refQueryTime:(NSNumber *)refQueryTime
                             success:(void (^)(NSUInteger, NSInteger, NSString *, NSNumber *, GFUserMTL *, NSArray<GFFunRecordMTL *> *))success
                             failure:(void (^)(NSUInteger, NSError *))failure {
    if (!userId) {
        if (failure) {
            failure(0,nil);
        }
        return 0;
    }
    NSMutableDictionary *parameters = [@{
                                         @"userId" : userId
                                         } mutableCopy];
    if (refQueryTime) {
        [parameters setObject:refQueryTime forKey:@"queryTime"];
    }
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:ApiGetFunRecordsWithUserId
                                                    parameters:parameters
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];
                                                           GFUserMTL *user = nil;
                                                           NSArray<GFFunRecordMTL *> *funRecords = nil;
                                                           if (code == 1) {
                                                               NSDictionary *userDict = [responseObject objectForKey:@"user"];
                                                               if (userDict && ![userDict isKindOfClass:[NSNull class]]) {
                                                                    user = [MTLJSONAdapter modelOfClass:[GFUserMTL class] fromJSONDictionary:userDict error:nil];
                                                               }
                                                               
                                                               NSArray<GFFunRecordMTL *> *recordList = [responseObject objectForKey:@"dataList"];
                                                               if (recordList && ![recordList isKindOfClass:[NSNull class]]) {
                                                                   funRecords = [MTLJSONAdapter modelsOfClass:[GFFunRecordMTL class] fromJSONArray:recordList error:nil];
                                                               }
                                                           }
                                                           if (success) {
                                                               success(taskId, code, apiErrorMessage, responseObject[@"queryTime"], user, funRecords);
                                                           }
                                                           
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

@end
