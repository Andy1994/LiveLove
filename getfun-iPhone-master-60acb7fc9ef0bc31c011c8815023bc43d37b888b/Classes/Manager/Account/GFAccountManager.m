//
//  GFAccountManager.m
//  getfun
//
//  Created by zhouxz on 15/11/11.
//  Copyright © 2015年 getfun. All rights reserved.
//

#import "GFAccountManager.h"
#import <BlocksKit+UIKit.h>
#import <Mantle/Mantle.h>
#import "GFUserDefaultsUtil.h"
#import "AppDelegate.h"
#import "GFLoginRegisterViewController.h"
#import "GFNavigationController.h"
#import "GFMessageCenter.h"
#import "TalkingDataAppCpa.h"


NSString * const GFUserDefaultsKeyLoginType = @"GFUserDefaultsKeyLoginType";
NSString * const GFUserDefaultsKeyRefreshToken = @"GFUserDefaultsKeyRefreshToken";
NSString * const GFUserDefaultsKeyAccessToken = @"GFUserDefaultsKeyAccessToken";
NSString * const GFUserDefaultsKeyLoginUserInfo = @"GFUserDefaultsKeyLoginUserInfo";

NSString * const GFNotificationLoginUserChanged = @"GFNotificationLoginUserChanged";
NSString * const GFNotificationAccessTokenChanged = @"GFNotificationAccessTokenChanged";

@implementation GFAccountManager
- (void)setAccessToken:(NSString *)accessToken {
    _accessToken = accessToken;
    [GFNetworkManager gf_updateHTTPHeader];
    [[NSNotificationCenter defaultCenter] postNotificationName:GFNotificationAccessTokenChanged object:nil];
}

+ (instancetype)sharedManager {
    static GFAccountManager *sharedManager;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedManager = [[GFAccountManager alloc] init];
        sharedManager.loginType = [GFUserDefaultsUtil uintegerForKey:GFUserDefaultsKeyLoginType];
        sharedManager.refreshToken = [GFUserDefaultsUtil objectForKey:GFUserDefaultsKeyRefreshToken];
        sharedManager.accessToken = [GFUserDefaultsUtil objectForKey:GFUserDefaultsKeyAccessToken];
        
        NSData *dataUser = [GFUserDefaultsUtil objectForKey:GFUserDefaultsKeyLoginUserInfo];
        if (dataUser) {
            NSDictionary *dictUser = [NSJSONSerialization JSONObjectWithData:dataUser options:0 error:nil];
            sharedManager.loginUser = [MTLJSONAdapter modelOfClass:[GFUserMTL class] fromJSONDictionary:dictUser error:nil];
        }
    });
    return sharedManager;
}

+ (void)checkLoginStatus:(BOOL)needLogin loginCompletion:(void (^)(BOOL, GFUserMTL *))completion {
    
    GFLoginType type = [GFAccountManager sharedManager].loginType;
    if (needLogin && (type==GFLoginTypeAnonymous || type==GFLoginTypeNone)) {
        // 要求必须登录，则进行登录.
        [GFAccountManager sharedManager].checkLoginCompletionHandler = completion;
        GFLoginRegisterViewController *loginRegisterViewController = [[GFLoginRegisterViewController alloc] init];
        [[AppDelegate appDelegate] displayViewController:[[GFNavigationController alloc] initWithRootViewController:loginRegisterViewController]];
    } else {
        if (completion) {
            completion(NO, [GFAccountManager sharedManager].loginUser);
        }
    }
}

+ (void)registerUserWithParameters:(NSDictionary *)parameters
                           success:(void (^)(NSInteger, NSString *))success
                           failure:(void (^)())failure {
    
    [GFNetworkManager registerUserWithParameters:parameters
                                         success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, NSString *refreshToken, NSString *accessToken, GFUserMTL *userInfo) {
                                             if (code == 1) {

                                                 [[GFAccountManager sharedManager] updateLoginType:GFLoginTypeMobile
                                                                                 authorizeResponse:nil
                                                                                      refreshToken:refreshToken
                                                                                       accessToken:accessToken
                                                                                          userInfo:userInfo];
                                                 
                                                 if ([GFAccountManager sharedManager].checkLoginCompletionHandler) {
                                                     [GFAccountManager sharedManager].checkLoginCompletionHandler(YES, userInfo);
                                                     [GFAccountManager sharedManager].checkLoginCompletionHandler = nil;
                                                 }
                                                 
                                                 if (userInfo.userId) {
                                                     NSString *userIdString = [NSString stringWithFormat:@"%@", userInfo.userId];
                                                     [TalkingDataAppCpa onRegister:userIdString];
                                                 }
                                                 
                                                 if (success) {
                                                     success(code, apiErrorMessage);
                                                 }
                                             } else {
                                                 if (failure) {
                                                     failure();
                                                 }
                                             }
                                         } failure:^(NSUInteger taskId, NSError *error) {
                                             if (failure) {
                                                 failure();
                                             }
                                         }];
}

+ (void)anonymousLoginSuccess:(void (^)())success failure:(void (^)())failure {
    
    [GFNetworkManager anonymousLoginSuccess:^(NSUInteger taskId, NSInteger code, NSString *refreshToken, NSString *accessToken) {
        if (code == 1) {
            
            [[GFAccountManager sharedManager] updateLoginType:GFLoginTypeAnonymous
                                            authorizeResponse:nil
                                                 refreshToken:refreshToken
                                                  accessToken:accessToken
                                                     userInfo:nil];
            
            if (success) {
                success();
            }
        } else {
            if (failure) {
                failure();
            }
        }
        
    } failure:^(NSUInteger taskId, NSError *error) {
        if (failure) {
            failure();
        }
    }];
}

+ (NSUInteger)loginUser:(NSString *)user
               password:(NSString *)password
                success:(void (^)(NSUInteger, NSInteger, NSString *))success
                failure:(void (^)(NSUInteger, NSError *))failure {
    
    NSUInteger taskId = [GFNetworkManager loginWithOption:YES
                                                     user:user
                                                 password:password
                                             refreshToken:nil
                                                  success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, NSString *refreshToken, NSString *accessToken, GFUserMTL *userInfo) {
                                                      if (code == 1) {
                                                          
                                                          [[GFAccountManager sharedManager] updateLoginType:GFLoginTypeMobile
                                                                                          authorizeResponse:nil
                                                                                               refreshToken:refreshToken
                                                                                                accessToken:accessToken
                                                                                                   userInfo:userInfo];
                                                          if ([GFAccountManager sharedManager].checkLoginCompletionHandler) {
                                                              [GFAccountManager sharedManager].checkLoginCompletionHandler(YES, userInfo);
                                                              [GFAccountManager sharedManager].checkLoginCompletionHandler = nil;
                                                          }
                                                      }

                                                      if (success) {
                                                          success(taskId, code, apiErrorMessage);
                                                      }
                                                  } failure:^(NSUInteger taskId, NSError *error) {
                                                      
                                                      if (failure) {
                                                          failure(taskId, error);
                                                      }
                                                  }];
    
    return taskId;
}

+ (void)refreshTokenSuccess:(void (^)())success failure:(void (^)())failure {
    
    [GFNetworkManager loginWithOption:NO
                                 user:nil
                             password:nil
                         refreshToken:[GFAccountManager sharedManager].refreshToken
                              success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, NSString *refreshToken, NSString *accessToken, GFUserMTL *userInfo) {
                                  if (code == 1) {
                                      
                                      GFLoginType type = [GFAccountManager sharedManager].loginType;
                                      id resp = [GFAccountManager sharedManager].authorizeResponse;
                                      
                                      [[GFAccountManager sharedManager] updateLoginType:type
                                                                      authorizeResponse:resp
                                                                           refreshToken:refreshToken
                                                                            accessToken:accessToken
                                                                               userInfo:userInfo];
                                      if (success) {
                                          success();
                                      }
                                  } else {
                                      if (failure) {
                                          failure();
                                      }
                                  }
                              } failure:^(NSUInteger taskId, NSError *error) {
                                  if (failure) {
                                      failure();
                                  }
                              }];
}

+ (void)exitSuccess:(void (^)())success failure:(void (^)())failure {
    
    NSString *clientId = [GFAccountManager sharedManager].getuiClientId;
    [GFNetworkManager logoutWithGeTuiClientId:clientId
                                      success:^(NSUInteger taskId, NSInteger code, NSString * refreshToken, NSString * accessToken) {
                                          if (code == 1) {
                                              
                                              if (success) {
                                                  success();
                                              }
                                          } else {
                                              if (failure) {
                                                  failure();
                                              }
                                          }
                                          
                                      } failure:^(NSUInteger taskId, NSError * error) {
                                          if (failure) {
                                              failure();
                                          }
                                      }];
}

- (void)updateLoginType:(GFLoginType)type
      authorizeResponse:(id)authorizeResponse
           refreshToken:(NSString *)refreshToken
            accessToken:(NSString *)accessToken
               userInfo:(GFUserMTL *)user {
    
    [GFUserDefaultsUtil setUInteger:type forKey:GFUserDefaultsKeyLoginType];
    [GFUserDefaultsUtil setObject:refreshToken forKey:GFUserDefaultsKeyRefreshToken];
    [GFUserDefaultsUtil setObject:accessToken forKey:GFUserDefaultsKeyAccessToken];
    
    if (user) {
        NSDictionary *dict = [MTLJSONAdapter JSONDictionaryFromModel:user];
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
        [GFUserDefaultsUtil setObject:data forKey:GFUserDefaultsKeyLoginUserInfo];
    } else {
        [GFUserDefaultsUtil setObject:nil forKey:GFUserDefaultsKeyLoginUserInfo];
    }
    
    self.loginType = type;
    self.authorizeResponse =  authorizeResponse;
    
    self.loginUser = user;
    self.refreshToken = refreshToken;
    self.accessToken = accessToken;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GFNotificationLoginUserChanged object:nil];
    
    if (user.userId) {
        NSString *userIdString = [NSString stringWithFormat:@"%@", user.userId];
        [TalkingDataAppCpa onLogin:userIdString];
    }
}
@end
