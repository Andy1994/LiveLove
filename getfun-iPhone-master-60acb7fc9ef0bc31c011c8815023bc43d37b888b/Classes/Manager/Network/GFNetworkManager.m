//
//  GFNetworkManager.m
//  getfun
//
//  Created by zhouxz on 15/11/10.
//  Copyright © 2015年 getfun. All rights reserved.
//

#import "GFNetworkManager.h"
#import "GFUserDefaultsUtil.h"
#import "AppDelegate.h"
#import "GFNetworkStatusUtil.h"

@implementation GFNetworkManager

+ (void)gf_updateHTTPHeader {
    
    NSMutableDictionary *dictHTTPHeader = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSString *access_token = [GFUserDefaultsUtil objectForKey:GFUserDefaultsKeyAccessToken];
    if (access_token) {
        [dictHTTPHeader setObject:access_token forKey:@"access_token"];
    } else {
        [dictHTTPHeader removeObjectForKey:@"access_token"];
    }
    [dictHTTPHeader setObject:[UIDevice gf_idfv] forKey:@"device_no"];
    [dictHTTPHeader setObject:APP_VERSION forKey:@"appVersion"];
    
    NSString *filterString = [NSString stringWithFormat:@"Getfun App iOS %@", APP_VERSION];
    [dictHTTPHeader setObject:filterString forKey:@"User-Agent"];
    
    [[self sharedManager].sessionManager setDefaultHeaderFields:dictHTTPHeader];
}

+ (void)cancelTask:(NSUInteger)taskId {
    [[GFNetworkManager sharedManager] cancelTaskForTaskId:taskId];
}

- (NSUInteger)POST:(NSString *)URLString
        parameters:(id)parameters
           success:(void (^)(NSUInteger taskId, id responseObject))success
           failure:(void (^)(NSUInteger taskId, NSError *error))failure
{
    NSUInteger taskId = [super POST:URLString
                       parameters:parameters
                          success:^(NSUInteger taskId, id responseObject){
                              NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                              if (code == 521) {
                                  // refreshToken
                                  [[AppDelegate appDelegate] refreshGetfunTokenCompletion:^{
                                      //
                                  }];
                              }
                              if (success) {
                                  success(taskId, responseObject);
                              }
                          }
                          failure:^(NSUInteger taskId, NSError *error) {
                              
                              if ([error.localizedDescription rangeOfString:@"(521)"].location != NSNotFound) {
                                  [[AppDelegate appDelegate] refreshGetfunTokenCompletion:^{
                                      //
                                  }];
                              }
                              
                              AFNetworkReachabilityStatus status = [GFNetworkStatusUtil networkStatus];
                              if (status == AFNetworkReachabilityStatusNotReachable) {
                                  [MBProgressHUD showHUDWithTitle:@"请检查网络设置" duration:kCommonHudDuration];
                              }
                              
                              if (failure) {
                                  failure(taskId, error);
                              }
                          }];
    return taskId;
}
@end
