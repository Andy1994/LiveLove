//
//  GFAccountManager+Weibo.m
//  GetFun
//
//  Created by zhouxz on 15/12/15.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFAccountManager+Weibo.h"

@implementation GFAccountManager (Weibo)

+ (void)weiboSSOLoginSuccess:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, BOOL firstLogin, GFUserMTL *userInfo))success failure:(void (^)())failure {
    
    [WeiboSDK registerApp:kWeiboAppKey];
    [GFAccountManager sharedManager].jointLoginSuccessHandler = success;
    [GFAccountManager sharedManager].jointLoginFailureHandler = failure;
    
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = kRedirectURI;
    request.scope = @"all";
    [WeiboSDK sendRequest:request];
}

+ (BOOL)handleWeiboURL:(NSURL *)url {
    return [WeiboSDK handleOpenURL:url delegate:[GFAccountManager sharedManager]];
}

+ (void)queryWeiboProfileWithUID:(NSString *)uid
                     accessToken:(NSString *)accessToken
                         success:(void (^)(NSString *, GFUserGender, NSString *))success
                         failure:(void (^)())failure {
    
     NSString *oathString = [NSString stringWithFormat:@"https://api.weibo.com/2/users/show.json?source=%@&uid=%@&access_token=%@", kWeiboAppKey, uid, accessToken];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:oathString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSString *nickName = [responseObject objectForKey:@"screen_name"];
            GFUserGender gender = GFUserGenderUnknown;
            NSString *avatarURL = [responseObject objectForKey:@"avatar_hd"];
            if (success) {
                success(nickName, gender, avatarURL);
            }
        } else {
            if (failure) {
                failure();
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure();
        }
    }];
}

#pragma mark - WeiboSDKDelegate
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {
    
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    
    if ([response isKindOfClass:[WBAuthorizeResponse class]]) {
        WBAuthorizeResponse *authResponse = (WBAuthorizeResponse *)response;
        __weak typeof(self) weakSelf = self;
        [GFNetworkManager jointLogin:GFLoginTypeWeiBo
                                 uid:authResponse.userID
                             unionId:nil
                             success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, BOOL firstLogin, NSString *refreshToken, NSString *accessToken, GFUserMTL *userInfo) {
                                 
                                 if (code == 1) {
                                     
                                     [weakSelf updateLoginType:GFLoginTypeWeiBo
                                             authorizeResponse:authResponse
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
                                 
                             } failure:^(NSUInteger taskId, NSError *error) {
                                 
                                 if (weakSelf.jointLoginFailureHandler) {
                                     weakSelf.jointLoginFailureHandler(taskId, error);
                                 }
                             }];
    } else if ([response isKindOfClass:[WBSendMessageToWeiboResponse class]]) {
        WBSendMessageToWeiboResponse *sendMsgResp = (WBSendMessageToWeiboResponse *)response;
//        WeiboSDKResponseStatusCodeSuccess               = 0,//成功
//        WeiboSDKResponseStatusCodeUserCancel            = -1,//用户取消发送
//        WeiboSDKResponseStatusCodeSentFail              = -2,//发送失败
//        WeiboSDKResponseStatusCodeAuthDeny              = -3,//授权失败
//        WeiboSDKResponseStatusCodeUserCancelInstall     = -4,//用户取消安装微博客户端
//        WeiboSDKResponseStatusCodePayFail               = -5,//支付失败
//        WeiboSDKResponseStatusCodeShareInSDKFailed      = -8,//分享失败 详情见response UserInfo
//        WeiboSDKResponseStatusCodeUnsupport             = -99,//不支持的请求
//        WeiboSDKResponseStatusCodeUnknown               = -100,
        
        if (sendMsgResp.statusCode == WeiboSDKResponseStatusCodeSuccess) {
            [MBProgressHUD showHUDWithTitle:@"分享成功" duration:kCommonHudDuration];
        } else if (sendMsgResp.statusCode != WeiboSDKResponseStatusCodeUserCancel) {
            [MBProgressHUD showHUDWithTitle:@"分享失败" duration:kCommonHudDuration];
        }
    }
}
@end
