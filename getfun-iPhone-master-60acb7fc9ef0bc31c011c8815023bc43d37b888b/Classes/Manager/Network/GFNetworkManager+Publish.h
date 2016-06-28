//
//  GFNetworkManager+Publish.h
//  GetFun
//
//  Created by zhouxz on 15/11/30.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFNetworkManager.h"
#import "GFPublishParameterMTL.h"
#import "GFContentMTL.h"

@interface GFNetworkManager (Publish)

/**
 *  高级发布网页端二维码登录
 *
 *  @param secret  扫描二维码得到的secret字符串
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)qrWebLogin:(NSString *)secret
                 success:(void (^)(NSUInteger taskId, NSInteger code))success
                 failure:(void (^)(NSUInteger taskId, NSError *error))failure;

/**
 *  获取七牛上传图片需要的token
 *
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)queryQiNiuTokenSuccess:(void(^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, NSString *token))success
                             failure:(void(^)(NSUInteger taskId, NSError *error))failure;

/**
 *  发布图文
 *
 *  @param publishArticleMTL 发布图文参数
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)publishArticle:(GFPublishArticleMTL *)publishArticleMTL
                     success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, GFContentMTL *content))success
                     failure:(void(^)(NSUInteger taskId, NSError *error))failure;

/**
 *  发布投票
 *
 *  @param publishVoteMTL 发布投票参数
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)publishVote:(GFPublishVoteMTL *)publishVoteMTL
                  success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, GFContentMTL *content))success
                  failure:(void(^)(NSUInteger taskId, NSError *error))failure;

/**
 *  发布链接
 *
 *  @param publishLinkMTL 发布链接参数
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)publishLink:(GFPublishLinkMTL *)publishLinkMTL
                  success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, GFContentMTL *content))success
                  failure:(void(^)(NSUInteger taskId, NSError *error))failure;

/**
 *  发布图片
 *
 *  @param publishPictureMTL 发布图片参数
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)publishPicture:(GFPublishPictureMTL *)publishPictureMTL
                     success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, GFContentMTL *content))success
                     failure:(void(^)(NSUInteger taskId, NSError *error))failure;

/**
 *  预览内容详情
 *
 *  @param contentId 预览的内容ID
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)queryPreviewContent:(NSNumber *)contentId
                          success:(void (^)(NSUInteger taskId, NSInteger code, GFContentMTL *content, NSDictionary *data, NSString *errorMessage))success
                          failure:(void(^)(NSUInteger taskId, NSError *error))failure;
@end
