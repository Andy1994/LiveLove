//
//  GFAccountManager+Wechat.m
//  GetFun
//
//  Created by zhouxz on 15/12/15.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFAccountManager+Wechat.h"
#import "GFWXAuthorizeResponse.h"

@implementation GFAccountManager (Wechat)

+ (void)wechatSSOLoginSuccess:(void (^)(NSUInteger, NSInteger, NSString *, BOOL, GFUserMTL *))success
                      failure:(void (^)(NSUInteger, NSError *))failure {
    
    [WXApi registerApp:kWXAppId];
    
    if (![WXApi isWXAppInstalled]) {
        [MBProgressHUD showHUDWithTitle:@"您尚未安装微信客户端" duration:kCommonHudDuration];
        return;
    }
    
    if (![WXApi isWXAppSupportApi]) {
        [MBProgressHUD showHUDWithTitle:@"请升级微信至最新版" duration:kCommonHudDuration];
        return;
    }
    
    [GFAccountManager sharedManager].jointLoginSuccessHandler = success;
    [GFAccountManager sharedManager].jointLoginFailureHandler = failure;

    SendAuthReq* req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact,post_timeline,sns";
    req.state = @"xxx";
    [WXApi sendReq:req];
}

+ (BOOL)handleWechatURL:(NSURL *)url {
    return [WXApi handleOpenURL:url delegate:[GFAccountManager sharedManager]];
}

+ (void)queryWechatProfileWithOpenId:(NSString *)openId
                         accessToken:(NSString *)accessToken
                             success:(void (^)(NSString *, GFUserGender, NSString *))success
                             failure:(void (^)())failure {
    
    NSDictionary *parameters = @{
                                 @"openid" : openId,
                                 @"access_token" : accessToken
                                 };

    NSString *urlStr = @"https://api.weixin.qq.com/sns/userinfo";
    
    AFSecurityPolicy *securityPolicy = [[AFSecurityPolicy alloc] init];
    [securityPolicy setAllowInvalidCertificates:YES];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy = securityPolicy;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/plain"];
    
    [manager GET:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSString *nickName = [responseObject objectForKey:@"nickname"];
            GFUserGender gender = GFUserGenderUnknown;
            NSString *avatarURL = [responseObject objectForKey:@"headimgurl"];
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

#pragma mark - WXApiDelegate
- (void)onReq:(BaseReq *)req {
    
}

- (void)onResp:(BaseResp *)resp {
    
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *authResp = (SendAuthResp *)resp;
//        WXSuccess           = 0,    /**< 成功    */
//        WXErrCodeCommon     = -1,   /**< 普通错误类型    */
//        WXErrCodeUserCancel = -2,   /**< 用户点击取消并返回    */
//        WXErrCodeSentFail   = -3,   /**< 发送失败    */
//        WXErrCodeAuthDeny   = -4,   /**< 授权失败    */
//        WXErrCodeUnsupport  = -5,   /**< 微信不支持    */
        if (authResp.errCode == WXSuccess) { // 用户同意授权
            // 使用code换取accessToken
            [self getWechatAccessToken:authResp.code];
        } else {
            
        }
    } else if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        // 分享的回调也跑到这里了，需要调整
        SendMessageToWXResp *sendMsgResp = (SendMessageToWXResp *)resp;
        if (sendMsgResp.errCode == WXSuccess) {
            [MBProgressHUD showHUDWithTitle:@"分享成功" duration:kCommonHudDuration];
        } else if (sendMsgResp.errCode != WXErrCodeUserCancel) {
            [MBProgressHUD showHUDWithTitle:@"分享失败" duration:kCommonHudDuration];
        }
    }
}

- (void)getWechatAccessToken:(NSString *)code {
    
    NSString *urlStr = @"https://api.weixin.qq.com/sns/oauth2/access_token";
    NSMutableDictionary *para = [NSMutableDictionary dictionary];
    [para setObject:kWXAppId forKey:@"appid"];
    [para setObject:kWXAppSecret forKey:@"secret"];
    [para setObject:code forKey:@"code"];
    [para setObject:@"authorization_code" forKey:@"grant_type"];
    
    AFSecurityPolicy *securityPolicy = [[AFSecurityPolicy alloc] init];
    [securityPolicy setAllowInvalidCertificates:YES];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy = securityPolicy;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/plain"];
    
    __weak typeof(self) weakSelf = self;
    [manager GET:urlStr parameters:para success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        GFWXAuthorizeResponse *resp = [MTLJSONAdapter modelOfClass:[GFWXAuthorizeResponse class] fromJSONDictionary:responseObject error:nil];
        [GFNetworkManager jointLogin:GFLoginTypeWechat
                                 uid:resp.openid
                             unionId:resp.unionid
                             success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, BOOL firstLogin, NSString *refreshToken, NSString *accessToken, GFUserMTL *userInfo) {
                                 
                                 if (code == 1) {
                                     [weakSelf updateLoginType:GFLoginTypeWechat
                                             authorizeResponse:resp
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
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}
@end
