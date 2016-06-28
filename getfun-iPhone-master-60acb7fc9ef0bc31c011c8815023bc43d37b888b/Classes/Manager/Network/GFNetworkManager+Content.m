//
//  GFNetworkManager+Content.m
//  GetFun
//
//  Created by zhouxz on 15/11/14.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFNetworkManager+Content.h"
#import "GFAccountManager.h"
#import "GFContentMTL.h"
#import "GFTagMTL.h"

#define GF_API_QUERY_HOME_CONTENT_LIST          ApiAddress(@"/api/content/front")
#define GF_API_DISLIKE_CONTENT                  ApiAddress(@"/api/content/dislike")
#define ApiGetContentDetail                     ApiAddress(@"/api/content/detail")
#define GF_API_QUERY_TAG_CONTENT_LIST           ApiAddress(@"/api/content/contentsWithTag")
#define ApiChangeFunStatus                      ApiAddress(@"/api/content/changeFunStatus")
#define APiReportContent                        ApiAddress(@"/api/content/report")
#define ApiVoteContent                          ApiAddress(@"/api/content/vote")
#define ApiDeleteContent                        ApiAddress(@"/api/content/delete")
#define GF_API_QUERY_USER_PUBLISHED_CONTENT     ApiAddress(@"/api/content/userContents")
#define GF_API_QUERY_USER_PARTICIPATE_CONTENT   ApiAddress(@"/api/content/takePartIn")
#define GF_API_DID_SHARE_CONTENT                ApiAddress(@"/api/content/share")

@implementation GFNetworkManager (Content)

+ (NSUInteger)queryContentListWithTag:(NSUInteger)tagId
                                count:(NSUInteger)count
                       maxPublishTime:(NSNumber *)maxPublishTime
                              success:(void (^)(NSUInteger, NSInteger, NSArray<GFContentMTL *> *))success
                              failure:(void (^)(NSUInteger, NSError *))failure {
    
    NSMutableDictionary *params = [@{@"tagId" : @(tagId),
                                     @"count":@(count)} mutableCopy];
    if (maxPublishTime) {
        [params setObject:maxPublishTime forKey:@"maxPublishTime"];
    }
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_QUERY_TAG_CONTENT_LIST
                                                    parameters:params
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           if (code == 1) {
                                                               
                                                               NSDictionary *dataDict = [responseObject objectForKey:@"data"];
                                                               
                                                               NSArray *tmpContentList = [dataDict objectForKey:@"contents"];
                                                               NSMutableArray *contentList = [[NSMutableArray alloc] initWithCapacity:[tmpContentList count]];
                                                               for (NSDictionary *dict in tmpContentList) {
                                                                   GFContentMTL *content = [MTLJSONAdapter modelOfClass:[GFContentMTL class] fromJSONDictionary:dict error:nil];
                                                                   if (content && content.contentInfo.type != GFContentStatusUnknown) {
                                                                       [contentList addObject:content];
                                                                   }
                                                               }
                                                               
                                                               success(taskId, code, contentList);
                                                               
                                                           } else {
                                                               success(taskId, code, nil);
                                                           }
                                                           
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           failure(taskId, error);
                                                       }];
    return taskId;
}

+ (NSUInteger)queryHomeContentSuccess:(void (^)(NSUInteger, NSInteger, NSArray<GFContentMTL *> *))success
                              failure:(void (^)(NSUInteger, NSError *))failure {
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_QUERY_HOME_CONTENT_LIST
                                                    parameters:@{@"count" : [NSNumber numberWithUnsignedInteger:kQueryHomeDataCount],
                                                                 @"reset" : @NO}
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSMutableArray *contentList = [[NSMutableArray alloc] initWithCapacity:0];
                                                           if (code == 1) {
                                                               
                                                               NSDictionary *dataDict = [responseObject objectForKey:@"data"];
                                                               
                                                               // 普通卡片
                                                               NSArray *tmpContentList = [dataDict objectForKey:@"contents"];
                                                               
                                                               for (NSDictionary *dict in tmpContentList) {
                                                                   
                                                                   GFContentMTL *content = [MTLJSONAdapter modelOfClass:[GFContentMTL class] fromJSONDictionary:dict error:nil];
                                                                   if (content && content.contentInfo.type != GFContentStatusUnknown) {
                                                                       [contentList addObject:content];
                                                                   }
                                                               }
                                                           }
                                                           if (success) {
                                                               success(taskId, code, contentList);
                                                           }
                                                           
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                           
                                                       }];
    return taskId;
}

+ (NSUInteger)dislikeContentWithContentId:(NSNumber *)contentId
                                  success:(void (^)(NSUInteger, NSInteger))success
                                  failure:(void (^)(NSUInteger, NSError *))failure {
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_DISLIKE_CONTENT
                                                    parameters:@{
                                                                 @"contentId":contentId
                                                                 }
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           success(taskId, code);
                                                           
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           failure(taskId, error);
                                                       }];
    return taskId;
    
}

+ (NSUInteger)getContentWithContentId:(NSNumber *)contentId
                              keyFrom:(GFKeyFrom)keyFrom
                              success:(void(^)(NSUInteger taskId, NSInteger code, GFContentMTL * content, NSDictionary *data, NSString *errorMessage))success
                              failure:(void(^)(NSUInteger taskId, NSError *error))failure {
    NSString *keyFromString = @"";
    switch (keyFrom) {
        case GFKeyFromUnkown:
            break;
        case GFKeyFromHome: {
            keyFromString = @"FRONT";
            break;
        }
        case GFKeyFromProfile: {
            keyFromString = @"PERSONAL";
            break;
        }
        case GFKeyFromGroup: {
            keyFromString = @"GROUP";
            break;
        }
        case GFKeyFromTag: {
            keyFromString = @"TAG";
            break;
        }
    }
    NSDictionary *parameters = @{
                                 @"id" : contentId,
                                 @"keyFrom" : keyFromString,
                                 };
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:ApiGetContentDetail parameters:parameters success:^(NSUInteger taskId, id responseObject) {
        NSInteger code = [responseObject[@"code"] integerValue];
        NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];
        GFContentMTL *content = nil;
        id dictObj = nil;
        
        if (code == 1) {
            NSDictionary *data = responseObject[@"data"];
            GFContentMTL *tmpContent = [MTLJSONAdapter modelOfClass:[GFContentMTL class] fromJSONDictionary:data error:nil];
            if (tmpContent && tmpContent.contentInfo.type != GFContentTypeUnknown) {
                content = tmpContent;
                dictObj = responseObject;
            }
        }
        
        if (success) {
            success(taskId, code, content, dictObj, apiErrorMessage);
        }
    } failure:^(NSUInteger taskId, NSError *error) {
        if (failure) {
            failure(taskId, error);
        }
    }];
    
    return taskId;
}

+ (NSUInteger)changeFunStatusWithContentId:(NSNumber *)contentId isFun:(BOOL)isFun success:(void (^)(NSUInteger, NSInteger, NSString *))success failure:(void (^)(NSUInteger, NSError *))failure {
    
    NSDictionary *parameters = @{
                                 @"contentId" : contentId
                                 };
    
//    NSDictionary *parameters = @{
//                                 @"contentId" : contentId,
//                                 @"isFun" : @(isFun),
//                                 };
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:ApiChangeFunStatus parameters:parameters success:^(NSUInteger taskId, id responseObject) {
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 1) {
            if (success) {
                success(taskId, code, nil);
            }
        } else {
            if (success) {
                success(taskId, code, responseObject[@"apiErrorMessage"]);
            }
        }
    } failure:^(NSUInteger taskId, NSError *error) {
        if (failure) {
            failure(taskId, error);
        }
    }];
    
    return taskId;
}

+ (NSUInteger)reportContentWithContentId:(NSNumber *)contentId
                              reportInfo:(NSString *)reportInfo
                                 success:(void(^)(NSUInteger taskId, NSInteger code, NSString *errorMessage))success
                                 failure:(void(^)(NSUInteger taskId, NSError *error))failure {
    NSDictionary *paramter = @{
                               @"contentId" : contentId,
                               @"reportInfo" : reportInfo.length > 0 ? reportInfo : @"",
                               };
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:APiReportContent parameters:paramter success:^(NSUInteger taskId, id responseObject) {
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

+ (NSUInteger)voteWithContentId:(NSNumber *)contentId
                     voteItemId:(NSNumber *)voteItemId
                        success:(void(^)(NSUInteger taskId, NSInteger code, NSString *errorMessage))success
                        failure:(void(^)(NSUInteger taskId, NSError *error))failure {
    NSDictionary *paramter = @{
                               @"contentId" : contentId,
                               @"voteItemId" : voteItemId,
                               };
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:ApiVoteContent parameters:paramter success:^(NSUInteger taskId, id responseObject) {
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

+ (NSUInteger)queryPublishedContentWithUserId:(NSNumber *)userId
                               refPublishTime:(NSNumber *)refPublishTime
                                        count:(NSInteger)count
                                      success:(void (^)(NSUInteger, NSInteger, NSString *, NSArray<GFContentMTL *> *))success
                                      failure:(void (^)(NSUInteger, NSError *))failure {
    
    if (!userId) {
        if (failure) {
            failure(0, nil);
        }
        return 0;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                    @"userId" : userId,
                                                                                    @"count" : [NSNumber numberWithInteger:count]
                                                                                    }];
    if (refPublishTime) {
        [params setObject:refPublishTime forKey:@"maxPublishTime"];
    }
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_QUERY_USER_PUBLISHED_CONTENT
                                                    parameters:params
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *apiErrorMsg = [responseObject objectForKey:@"apiErrorMessage"];
                                                           NSMutableArray *contentList = [[NSMutableArray alloc] initWithCapacity:0];
                                                           NSDictionary *data = [responseObject objectForKey:@"data"];
                                                           if (data) {
                                                               NSArray *jsonContentList = [data objectForKey:@"contents"];
                                                               
                                                               for (NSDictionary *dict in jsonContentList) {
                                                                   GFContentMTL *content = [MTLJSONAdapter modelOfClass:[GFContentMTL class] fromJSONDictionary:dict error:nil];
                                                                   if (content && content.contentInfo.type != GFContentTypeUnknown) {
                                                                       [contentList addObject:content];
                                                                   }
                                                               }
                                                           }
                                                           if (success) {
                                                               success(taskId, code, apiErrorMsg, contentList);
                                                           }
                                                           
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

+ (NSUInteger)queryParticipateContentWithUserId:(NSNumber *)userId
                                 refPublishTime:(NSNumber *)refPublishTime
                                          count:(NSInteger)count
                                        success:(void (^)(NSUInteger, NSInteger, NSString *, NSArray<GFContentMTL *> *))success
                                        failure:(void (^)(NSUInteger, NSError *))failure {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                    @"userId" : userId,
                                                                                    @"count" : [NSNumber numberWithInteger:count]
                                                                                    }];
    if (refPublishTime) {
        [params setObject:refPublishTime forKey:@"maxPublishTime"];
    }
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_QUERY_USER_PARTICIPATE_CONTENT
                                                    parameters:params
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *apiErrorMsg = [responseObject objectForKey:@"apiErrorMessage"];
                                                           NSMutableArray *contentList = [[NSMutableArray alloc] initWithCapacity:0];
                                                           NSDictionary *data = [responseObject objectForKey:@"data"];
                                                           if (data) {
                                                               NSArray *jsonContentList = [data objectForKey:@"contents"];
                                                               
                                                               for (NSDictionary *dict in jsonContentList) {
                                                                   GFContentMTL *content = [MTLJSONAdapter modelOfClass:[GFContentMTL class] fromJSONDictionary:dict error:nil];
                                                                   if (content && content.contentInfo.type != GFContentTypeUnknown) {
                                                                       [contentList addObject:content];
                                                                   }
                                                               }
                                                           }
                                                           success(taskId, code, apiErrorMsg, contentList);
                                                           
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           failure(taskId, error);
                                                       }];
    return taskId;
}

+ (NSUInteger)deleteContentWithContentId:(NSNumber *)contentId
                                 success:(void(^)(NSUInteger taskId, NSInteger code, NSString *errorMessage))success
                                 failure:(void(^)(NSUInteger taskId, NSError *error))failure {
    if (contentId == nil) {
        return 0;
    }
    
    NSDictionary *parameters = @{@"contentId" : contentId};
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:ApiDeleteContent parameters:parameters success:^(NSUInteger taskId, id responseObject) {
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

+ (NSUInteger)didShareContentWithContentId:(NSNumber *)contentId shareType:(NSString *)shareType {
    if (!contentId) {
        return 0;
    }
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_DID_SHARE_CONTENT
                                                    parameters:@{
                                                                 @"contentId" : contentId,
                                                                 @"keyFrome" : shareType
                                                                 }
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           //
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           //
                                                       }];
    
    return taskId;
}

+ (NSUInteger)didShareContentWithContentId:(NSNumber *)contentId shareType:(NSString *)shareType success:(void (^)())success fail: (void (^)())fail {
    if (!contentId) {
        return 0;
    }
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_DID_SHARE_CONTENT
                                                    parameters:@{
                                                                 @"contentId" : contentId,
                                                                 @"keyFrome" : shareType
                                                                 }
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           //
                                                           if (success) {
                                                               success();
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           //
                                                           if (fail) {
                                                               fail();
                                                           }
                                                       }];
    
    return taskId;

}
@end
