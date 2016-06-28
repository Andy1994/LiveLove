//
//  GFAccountManager+QQ.h
//  GetFun
//
//  Created by zhouxz on 15/12/15.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFAccountManager.h"
#import <TencentOpenAPI/TencentApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>

@interface GFAccountManager (QQ) <TencentSessionDelegate>

+ (void)qqSSOLoginSuccess:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, BOOL firstLogin, GFUserMTL *userInfo))success
                  failure:(void (^)(NSUInteger taskId, NSError *error))failure;

+ (BOOL)handleQQURL:(NSURL *)url;

+ (void)queryQQProfileWithSuccess:(void (^)(NSString *nickName, GFUserGender gender, NSString *avatarURL))success
                          failure:(void (^)())failure;

@end
