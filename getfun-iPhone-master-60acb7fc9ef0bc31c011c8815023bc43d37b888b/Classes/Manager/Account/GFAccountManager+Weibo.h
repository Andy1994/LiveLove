//
//  GFAccountManager+Weibo.h
//  GetFun
//
//  Created by zhouxz on 15/12/15.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFAccountManager.h"
#import "WeiboSDK.h"

@interface GFAccountManager (Weibo) <WeiboSDKDelegate>

+ (void)weiboSSOLoginSuccess:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, BOOL firstLogin, GFUserMTL *userInfo))success
                     failure:(void (^)())failure;

+ (BOOL)handleWeiboURL:(NSURL *)url;

+ (void)queryWeiboProfileWithUID:(NSString *)uid
                     accessToken:(NSString *)accessToken
                         success:(void (^)(NSString *nickName, GFUserGender gender, NSString *avatarURL))success
                         failure:(void (^)())failure;

@end
