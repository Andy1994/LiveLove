//
//  GFAccountManager+QQ.m
//  GetFun
//
//  Created by zhouxz on 15/12/15.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFAccountManager+QQ.h"

@implementation GFAccountManager (QQ)

+ (void)qqSSOLoginSuccess:(void (^)(NSUInteger, NSInteger, NSString *, BOOL, GFUserMTL *))success
                  failure:(void (^)(NSUInteger, NSError *))failure {
    
    GFAccountManager *manager = [GFAccountManager sharedManager];
    
    manager.jointLoginSuccessHandler = success;
    manager.jointLoginFailureHandler = failure;
    
    NSArray *permissions = @[kOPEN_PERMISSION_GET_USER_INFO,
                             kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                             kOPEN_PERMISSION_ADD_ALBUM,
                             kOPEN_PERMISSION_ADD_IDOL,
                             kOPEN_PERMISSION_ADD_ONE_BLOG,
                             kOPEN_PERMISSION_ADD_PIC_T,
                             kOPEN_PERMISSION_ADD_SHARE,
                             kOPEN_PERMISSION_ADD_TOPIC,
                             kOPEN_PERMISSION_CHECK_PAGE_FANS,
                             kOPEN_PERMISSION_DEL_IDOL,
                             kOPEN_PERMISSION_DEL_T,
                             kOPEN_PERMISSION_GET_FANSLIST,
                             kOPEN_PERMISSION_GET_IDOLLIST,
                             kOPEN_PERMISSION_GET_INFO,
                             kOPEN_PERMISSION_GET_OTHER_INFO,
                             kOPEN_PERMISSION_GET_REPOST_LIST,
                             kOPEN_PERMISSION_LIST_ALBUM,
                             kOPEN_PERMISSION_UPLOAD_PIC,
                             kOPEN_PERMISSION_GET_VIP_INFO,
                             kOPEN_PERMISSION_GET_VIP_RICH_INFO,
                             kOPEN_PERMISSION_GET_INTIMATE_FRIENDS_WEIBO,
                             kOPEN_PERMISSION_MATCH_NICK_TIPS_WEIBO];
    
    if (!manager.tencentOAuth) {
        manager.tencentOAuth = [[TencentOAuth alloc] initWithAppId:kTencentAppId andDelegate:manager];
    }
    [manager.tencentOAuth authorize:permissions];
}

+ (BOOL)handleQQURL:(NSURL *)url {

    if (YES == [TencentOAuth CanHandleOpenURL:url]) {
        return [TencentOAuth HandleOpenURL:url];
    }
    return YES;
}

+ (void)queryQQProfileWithSuccess:(void (^)(NSString *, GFUserGender, NSString *))success
                          failure:(void (^)())failure {
    
    GFAccountManager *manager = [GFAccountManager sharedManager];
    if (manager.tencentOAuth) {
        manager.getTencentUserProfileSuccess = success;
        manager.getTencentUserProfileFailure = failure;
        [manager.tencentOAuth getUserInfo];
    } else {
        failure();
    }
}

#pragma mark - TencentLoginDelegate
- (void)tencentDidLogin {
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager jointLogin:GFLoginTypeQQ
                             uid:self.tencentOAuth.openId
                         unionId:nil
                         success:^(NSUInteger taskId, NSInteger code, NSString * apiErrorMessage, BOOL firstLogin, NSString * refreshToken, NSString * accessToken, GFUserMTL * userInfo) {
                             if (code == 1) {
                                 
                                 [weakSelf updateLoginType:GFLoginTypeQQ
                                         authorizeResponse:weakSelf.tencentOAuth
                                              refreshToken:refreshToken
                                               accessToken:accessToken
                                                  userInfo:userInfo];

                                 if (weakSelf.checkLoginCompletionHandler) {
                                     weakSelf.checkLoginCompletionHandler(YES, userInfo);
                                     weakSelf.checkLoginCompletionHandler = nil;
                                 }
                             }
                             
                             if (weakSelf.jointLoginSuccessHandler) {
                                 weakSelf.jointLoginSuccessHandler(taskId, code, apiErrorMessage, firstLogin, userInfo);
                             }
                             
                         } failure:^(NSUInteger taskId, NSError * error) {
                             
                             if (weakSelf.jointLoginFailureHandler) {
                                 weakSelf.jointLoginFailureHandler(taskId, error);
                             }
                         }];
}

- (void)tencentDidNotLogin:(BOOL)cancelled {
    
}

- (void)tencentDidNotNetWork {
    
}

#pragma mark - TencentSessionDelegate
- (void)getUserInfoResponse:(APIResponse*)response {
    
    if (self.getTencentUserProfileSuccess) {
        
        NSDictionary *resultDic = [NSDictionary dictionaryWithDictionary:(NSDictionary *)response.jsonResponse];
        
        NSString *nickName = [resultDic objectForKey:@"nickname"];
        GFUserGender gender = GFUserGenderUnknown;
        NSString *avatarURL = [resultDic objectForKey:@"figureurl_qq_2"];

        self.getTencentUserProfileSuccess(nickName, gender, avatarURL);
    }
}

@end
