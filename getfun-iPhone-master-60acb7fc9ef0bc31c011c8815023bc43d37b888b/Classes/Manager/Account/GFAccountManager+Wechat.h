//
//  GFAccountManager+Wechat.h
//  GetFun
//
//  Created by zhouxz on 15/12/15.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFAccountManager.h"
#import "WXApi.h"

@interface GFAccountManager (Wechat) <WXApiDelegate>

+ (void)wechatSSOLoginSuccess:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, BOOL firstLogin, GFUserMTL *userInfo))success
                      failure:(void (^)(NSUInteger taskId, NSError *error))failure;

+ (BOOL)handleWechatURL:(NSURL *)url;

+ (void)queryWechatProfileWithOpenId:(NSString *)openId
                        accessToken:(NSString *)accessToken
                             success:(void (^)(NSString *nickName, GFUserGender gender, NSString *avatarURL))success
                             failure:(void (^)())failure;

@end
