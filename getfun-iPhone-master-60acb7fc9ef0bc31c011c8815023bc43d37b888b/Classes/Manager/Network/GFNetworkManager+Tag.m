//
//  GFNetworkManager+Tag.m
//  GetFun
//
//  Created by zhouxz on 15/12/18.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFNetworkManager+Tag.h"
#import "GFAccountManager.h"

#define GF_API_QUERY_HOT_TAGS                   ApiAddress(@"/api/tag/hotTags")
#define GF_API_QUERY_TAG_DETAIL                 ApiAddress(@"/api/tag/detail")
#define GF_API_QUERY_COLLECTED_TAG              ApiAddress(@"/api/user/allCollectTags")
#define GF_API_ADD_COLLECT_TAG                  ApiAddress(@"/api/user/collectTag")
#define GF_API_REMOVE_COLLECT_TAG               ApiAddress(@"/api/user/removeCollectTag")
#define GF_API_QUERY_RECOMMEND_INTEREST_TAGS    ApiAddress(@"/api/tag/recommendedInterests")
#define GF_API_QUERY_ALL_INTEREST_TAGS          ApiAddress(@"/api/tag/allInterests")

@implementation GFNetworkManager (Tag)
+ (NSUInteger)getHotTagSuccess:(void (^)(NSUInteger, NSInteger, NSString *, NSArray<GFTagMTL *> *))success
                       failure:(void (^)(NSUInteger, NSError *))failure {
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_QUERY_HOT_TAGS
                                                    parameters:nil
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *apiErrorMsg = [responseObject objectForKey:@"apiErrorMessage"];
                                                           NSArray *hotTags = nil;
                                                           if (code == 1) {
                                                               NSArray *tmpTagList = [responseObject objectForKey:@"data"];
                                                               hotTags = [MTLJSONAdapter modelsOfClass:[GFTagMTL class] fromJSONArray:tmpTagList error:nil];
                                                           }
                                                           
                                                           if (success) {
                                                               success(taskId, code, apiErrorMsg, hotTags);
                                                           }

                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

+ (NSUInteger)getTagDetail:(NSNumber *)tagId
                   success:(void (^)(NSUInteger, NSInteger, NSString *, NSArray<GFContentMTL *> *, NSArray<GFGroupMTL *> *, GFTagMTL *))success
                   failure:(void (^)(NSUInteger, NSError *))failure {
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_QUERY_TAG_DETAIL
                                                    parameters:@{
                                                                 @"tagId" : tagId,
                                                                 @"contentCount" : [NSNumber numberWithInteger:kQueryDataCount]
                                                                 }
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *errorMsg = [responseObject objectForKey:@"apiErrorMessage"];
                                                           
                                                           GFTagMTL *tag = nil;
                                                           NSMutableArray<GFContentMTL *> *contents = [[NSMutableArray alloc] initWithCapacity:0];
                                                           NSArray<GFGroupMTL *> *groups = nil;
                                                           
                                                           if (code == 1) {
                                                               NSDictionary *dataDict = [responseObject objectForKey:@"data"];
                                                               
                                                               // Tag
                                                               tag = [MTLJSONAdapter modelOfClass:[GFTagMTL class] fromJSONDictionary:dataDict error:nil];
                                                               
                                                               // 置顶帖
                                                               NSArray *tmpTopContents = [dataDict objectForKey:@"topContents"];
                                                               NSArray *topContents = [MTLJSONAdapter modelsOfClass:[GFContentMTL class] fromJSONArray:tmpTopContents error:nil];
                                                               for (GFContentMTL *tmpContent in topContents) {
                                                                   if (tmpContent.contentInfo.type != GFContentTypeUnknown) {
                                                                       [contents addObject:tmpContent];
                                                                   }
                                                               }
                                                               
                                                               // 普通帖
                                                               NSArray *tmpCommonContents = [dataDict objectForKey:@"contents"];
                                                               NSArray *commonContents = [MTLJSONAdapter modelsOfClass:[GFContentMTL class] fromJSONArray:tmpCommonContents error:nil];
                                                               for (GFContentMTL *tmpContent in commonContents) {
                                                                   if (tmpContent.contentInfo.type != GFContentTypeUnknown) {
                                                                       [contents addObject:tmpContent];
                                                                   }
                                                               }
                                                               
                                                               // Get帮
                                                               NSArray *tmpGroups = [dataDict objectForKey:@"groups"];
                                                               groups = [MTLJSONAdapter modelsOfClass:[GFGroupMTL class] fromJSONArray:tmpGroups error:nil];
                                                           }
                                                           
                                                           if (success) {
                                                               success(taskId, code, errorMsg, contents, groups, tag);
                                                           }
                                                           
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

+ (NSUInteger)getCollectedTagWithRefTime:(NSNumber *)refTime
                                 success:(void (^)(NSUInteger, NSInteger, NSString *, NSArray<GFTagMTL *> *, NSInteger))success
                                 failure:(void (^)(NSUInteger, NSError *))failure {
    NSMutableDictionary *params = [@{
                                     @"count" : [NSNumber numberWithInteger:kQueryDataCount]
                                     } mutableCopy];
    if (refTime) {
        [params setObject:refTime forKey:@"maxAddTime"];
    }
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_QUERY_COLLECTED_TAG
                                                    parameters:params
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *errMsg = [responseObject objectForKey:@"apiErrorMessage"];
                                                           NSInteger totalCount = 0;
                                                           NSArray *tags = nil;
                                                           if (code == 1) {
                                                               NSDictionary *dataDict = [responseObject objectForKey:@"data"];
                                                               totalCount = [[dataDict objectForKey:@"tagCount"] integerValue];
                                                               NSArray *tmpTagsList = [dataDict objectForKey:@"tags"];
                                                               tags = [MTLJSONAdapter modelsOfClass:[GFTagMTL class] fromJSONArray:tmpTagsList error:nil];
                                                           }
                                                           if (success) {
                                                               success(taskId, code, errMsg, tags, totalCount);
                                                           }
                                                           
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

+ (NSUInteger)collectTag:(NSNumber *)tagId
                 collect:(BOOL)collect
                 success:(void (^)(NSUInteger, NSInteger, NSString *))success
                 failure:(void (^)(NSUInteger, NSError *))failure {
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:collect ? GF_API_ADD_COLLECT_TAG : GF_API_REMOVE_COLLECT_TAG
                                                    parameters:@{
                                                                 @"tagId" : tagId
                                                                 }
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *errorMsg = [responseObject objectForKey:@"apiErrorMessage"];
                                                           if (success) {
                                                               success(taskId, code, errorMsg);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

+ (NSUInteger)getRecommendInterestTagsSuccess:(void (^)(NSUInteger taskId, NSInteger code, NSArray<GFTagMTL *>  * tags, NSString *errorMessage))success
                                      failure:(void (^)(NSUInteger taskId, NSError *error))failure {
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_QUERY_RECOMMEND_INTEREST_TAGS
                                                    parameters:nil
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSArray<GFTagMTL *> *tags = nil;
                                                           if (code == 1) {
                                                               NSArray *tmpTags = [responseObject objectForKey:@"data"];
                                                               tags = [MTLJSONAdapter modelsOfClass:[GFTagMTL class] fromJSONArray:tmpTags error:nil];
                                                           }
                                                          success(taskId, code, tags, nil);
                                                           
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           failure(taskId, error);
                                                       }];
    return taskId;
}

+ (NSUInteger)getAllInterestTagsSuccess:(void (^)(NSUInteger, NSInteger, NSArray<GFTagInfoMTL *> *, NSString *))success
                                failure:(void (^)(NSUInteger, NSError *))failure {
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_QUERY_ALL_INTEREST_TAGS
                                                    parameters:nil
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *errorMessage = [responseObject objectForKey:@"apiErrorMessage"];
                                                           NSArray *tags = nil;
                                                           if (code == 1) {
                                                               NSArray *tmpTags = [responseObject objectForKey:@"data"];
                                                               tags = [MTLJSONAdapter modelsOfClass:[GFTagInfoMTL class] fromJSONArray:tmpTags error:nil];
                                                           }
                                                           if (success) {
                                                               success(taskId, code, tags, errorMessage);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

@end
