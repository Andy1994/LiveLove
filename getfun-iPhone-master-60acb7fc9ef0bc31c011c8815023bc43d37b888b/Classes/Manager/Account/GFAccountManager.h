//
//  GFAccountManager.h
//  getfun
//
//  Created by zhouxz on 15/11/11.
//  Copyright © 2015年 getfun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GFNetworkManager+User.h"
#import "GFUserMTL.h"
#import "GFWXAuthorizeResponse.h"
#import "WeiboSDK.h"
#import <TencentOpenAPI/TencentOAuth.h>

/**
 *  账号管理模块. 管理当前用户的登录状态、token信息、用户信息等.
 */
@interface GFAccountManager : NSObject

@property (nonatomic, assign) GFLoginType loginType;

// getfun后台返回的数据
@property (nonatomic, copy) NSString *refreshToken;
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, strong) GFUserMTL *loginUser;

// 个推
@property (nonatomic, strong) NSString *getuiClientId;

// 第三方登录相关
/* --- qq微信微博共用 --- */
@property (nonatomic, strong) id authorizeResponse; //微博WBAuthorizeResponse, 微信GFWXAuthorizeResponse, QQ TencentOAuth, 就是下面的tencentOAuth属性
@property (nonatomic, copy) void (^jointLoginSuccessHandler)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, BOOL firstLogin, GFUserMTL *userInfo);
@property (nonatomic, copy) void (^jointLoginFailureHandler)(NSUInteger taskId, NSError *error);

/* --- qq自己的 --- */
@property (nonatomic, strong) TencentOAuth *tencentOAuth;// QQ SDK是大爷，给他多分配个属性
@property (nonatomic, copy) void (^getTencentUserProfileSuccess)(NSString *nickName, GFUserGender gender, NSString *avatarURL); // 一个不够，两个
@property (nonatomic, copy) void (^getTencentUserProfileFailure)(); // 两个还不够，大爷的QQ

+ (instancetype)sharedManager;

@property (nonatomic, copy) void(^checkLoginCompletionHandler)(BOOL login, GFUserMTL *user);
/**
 *  校验登录状态
 *
 *  @param needLogin  如果未登录，是否需要用户登录
 *  @param completion
 *
 *  @return
 */
+ (void)checkLoginStatus:(BOOL)needLogin
         loginCompletion:(void(^)(BOOL justLogin, GFUserMTL *user))completion;

+ (void)registerUserWithParameters:(NSDictionary *)parameters
                           success:(void (^)(NSInteger code, NSString *errorMsg))success
                           failure:(void (^)())failure;

/**
 *  匿名登录
 *
 *  @param success
 *  @param failure
 */
+ (void)anonymousLoginSuccess:(void (^)())success failure:(void (^)())failure;

/**
 *  用户名/手机 + 密码登录
 *
 *  @param user     用户名/手机号
 *  @param password 密码
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)loginUser:(NSString *)user
               password:(NSString *)password
                success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage))success
                failure:(void (^)(NSUInteger taskId, NSError *error))failure;

/**
 *  刷新token
 *
 *  @param success
 *  @param failure
 */
+ (void)refreshTokenSuccess:(void (^)())success failure:(void (^)())failure;

/**
 *  退出登录
 */
+ (void)exitSuccess:(void (^)())success
            failure:(void (^)())failure;

/**
 *  登录状态改变后更新登录信息
 */
- (void)updateLoginType:(GFLoginType)type
      authorizeResponse:(id)authorizeResponse
           refreshToken:(NSString *)refreshToken
            accessToken:(NSString *)accessToken
               userInfo:(GFUserMTL *)user;
@end
