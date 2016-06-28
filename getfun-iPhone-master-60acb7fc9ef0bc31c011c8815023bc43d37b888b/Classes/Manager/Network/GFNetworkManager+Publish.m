//
//  GFNetworkManager+Publish.m
//  GetFun
//
//  Created by zhouxz on 15/11/30.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFNetworkManager+Publish.h"

#define GF_API_QR_LOGIN ApiAddress(@"/qrLogin")
#define GF_API_QUERY_QINIU_TOKEN ApiAddress(@"/api/upload/token")
#define GF_API_PUBLISH_ARTICLE ApiAddress(@"/api/content/newArticle")
#define GF_API_PUBLISH_VOTE ApiAddress(@"/api/content/newVote")
#define GF_API_PUBLISH_LINK ApiAddress(@"/api/content/newLink")
#define GF_API_PUBLISH_PICTURE ApiAddress(@"/api/content/newAlbum")
#define GF_API_QUERY_PREVIEW ApiAddress(@"/api/content/preview")

@implementation GFNetworkManager (Publish)

+ (NSUInteger)qrWebLogin:(NSString *)secret
                 success:(void (^)(NSUInteger, NSInteger))success
                 failure:(void (^)(NSUInteger, NSError *))failure {
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_QR_LOGIN
                                                    parameters:@{
                                                                 @"secret" : secret
                                                                 }
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           if (success) {
                                                               success(taskId, code);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

+ (NSUInteger)queryQiNiuTokenSuccess:(void (^)(NSUInteger, NSInteger, NSString *, NSString *))success
                             failure:(void (^)(NSUInteger, NSError *))failure {
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_QUERY_QINIU_TOKEN
                                                    parameters:nil
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];
                                                           NSString *token = [responseObject objectForKey:@"token"];
                                                           if (success) {
                                                               success(taskId, code, apiErrorMessage, token);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

+ (NSUInteger)publishArticle:(GFPublishArticleMTL *)publishArticleMTL
                     success:(void (^)(NSUInteger, NSInteger, NSString *, GFContentMTL *))success
                     failure:(void (^)(NSUInteger, NSError *))failure {
    
    NSDictionary *articleParameters = [MTLJSONAdapter JSONDictionaryFromModel:publishArticleMTL];
//    NSDictionary *articleParameters = [MTLJSONAdapter JSONDictionaryFromModel:publishArticleMTL error:nil];
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_PUBLISH_ARTICLE
                                                    parameters:[articleParameters mtl_dictionaryByRemovingEntriesWithKeys:[NSSet setWithObjects:@"state", @"publishId", nil]]
//                         [articleParameters mtl_dictionaryByRemovingValuesForKeys:@[@"state", @"publishId"]]
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];
                                                           GFContentMTL *content = nil;
                                                           if (code == 1) {
                                                               NSDictionary *dataDict = [responseObject objectForKey:@"data"];
                                                               GFContentMTL *contentMTL = [MTLJSONAdapter modelOfClass:[GFContentMTL class] fromJSONDictionary:dataDict error:nil];
                                                               if (contentMTL && contentMTL.contentInfo.type != GFContentTypeUnknown) {
                                                                   content = contentMTL;
                                                               }
                                                           }
                                                           if (success) {
                                                               success(taskId, code, apiErrorMessage, content);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                              failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

+ (NSUInteger)publishVote:(GFPublishVoteMTL *)publishVoteMTL
                  success:(void (^)(NSUInteger, NSInteger, NSString *, GFContentMTL *))success
                  failure:(void (^)(NSUInteger, NSError *))failure {
    
    NSDictionary *voteParameters = [MTLJSONAdapter JSONDictionaryFromModel:publishVoteMTL];
//    NSDictionary *voteParameters = [MTLJSONAdapter JSONDictionaryFromModel:publishVoteMTL error:nil];
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_PUBLISH_VOTE
                                                    parameters:[voteParameters mtl_dictionaryByRemovingEntriesWithKeys:[NSSet setWithObjects:@"state", @"publishId", nil]]
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];
                                                           GFContentMTL *content = nil;
                                                           if (code == 1) {
                                                               NSDictionary *dataDict = [responseObject objectForKey:@"data"];
                                                               GFContentMTL *contentMTL = [MTLJSONAdapter modelOfClass:[GFContentMTL class] fromJSONDictionary:dataDict error:nil];
                                                               if (contentMTL && contentMTL.contentInfo.type != GFContentTypeUnknown) {
                                                                   content = contentMTL;
                                                               }
                                                           }
                                                           if (success) {
                                                               success(taskId, code, apiErrorMessage, content);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                              failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

+ (NSUInteger)publishLink:(GFPublishLinkMTL *)publishLinkMTL
                  success:(void (^)(NSUInteger, NSInteger, NSString *, GFContentMTL *))success
                  failure:(void (^)(NSUInteger, NSError *))failure {
    NSDictionary *linkParameters = [MTLJSONAdapter JSONDictionaryFromModel:publishLinkMTL];
//    NSDictionary *linkParameters = [MTLJSONAdapter JSONDictionaryFromModel:publishLinkMTL error:nil];
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_PUBLISH_LINK
                                                    parameters:[linkParameters mtl_dictionaryByRemovingEntriesWithKeys:[NSSet setWithObjects:@"state", @"publishId", nil]]
//                         [linkParameters mtl_dictionaryByRemovingValuesForKeys:@[@"state", @"publishId"]]
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];
                                                           GFContentMTL *content = nil;
                                                           if (code == 1) {
                                                               NSDictionary *dataDict = [responseObject objectForKey:@"data"];
                                                               GFContentMTL *contentMTL = [MTLJSONAdapter modelOfClass:[GFContentMTL class] fromJSONDictionary:dataDict error:nil];
                                                               if (contentMTL && contentMTL.contentInfo.type != GFContentTypeUnknown) {
                                                                   content = contentMTL;
                                                               }
                                                           }
                                                           if (success) {
                                                               success(taskId, code, apiErrorMessage, content);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

+ (NSUInteger)publishPicture:(GFPublishPictureMTL *)publishPictureMTL
                     success:(void (^)(NSUInteger, NSInteger, NSString *, GFContentMTL *))success
                     failure:(void (^)(NSUInteger, NSError *))failure {
    NSDictionary *pictureParameters = [MTLJSONAdapter JSONDictionaryFromModel:publishPictureMTL];
    
//    [pictureParameters mtl_dictionaryByRemovingEntriesWithKeys:[NSSet setWithObjects:@"pictures", nil]]
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_PUBLISH_PICTURE
                                                    parameters:pictureParameters
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];
                                                           GFContentMTL *content = nil;
                                                           if (code == 1) {
                                                               NSDictionary *dataDict = [responseObject objectForKey:@"data"];
                                                               GFContentMTL *contentMTL = [MTLJSONAdapter modelOfClass:[GFContentMTL class] fromJSONDictionary:dataDict error:nil];
                                                               if (contentMTL && contentMTL.contentInfo.type != GFContentTypeUnknown) {
                                                                   content = contentMTL;
                                                               }
                                                           }
                                                           if (success) {
                                                               success(taskId, code, apiErrorMessage, content);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

+ (NSUInteger)queryPreviewContent:(NSNumber *)contentId
                          success:(void (^)(NSUInteger, NSInteger, GFContentMTL *, NSDictionary *, NSString *))success
                          failure:(void (^)(NSUInteger, NSError *))failure {
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_QUERY_PREVIEW
                                                    parameters:@{
                                                                 @"id" : contentId
                                                                 }
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *errorMessage = [responseObject objectForKey:@"apiErrorMessage"];
                                                           GFContentMTL *content = nil;
                                                           if (code == 1) {
                                                               NSDictionary *dataDict = [responseObject objectForKey:@"data"];
                                                               GFContentMTL *contentMTL = [MTLJSONAdapter modelOfClass:[GFContentMTL class] fromJSONDictionary:dataDict error:nil];
                                                               if (contentMTL && contentMTL.contentInfo.type != GFContentTypeUnknown) {
                                                                   content = contentMTL;
                                                               }
                                                           }
                                                           if (success) {
                                                               success(taskId, code, content, responseObject, errorMessage);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                              failure(taskId, error);
                                                           }
                                                       }];
    
    return taskId;
}
@end
