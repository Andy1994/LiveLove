//
//  GFNetworkManager+Common.m
//  GetFun
//
//  Created by zhouxz on 16/1/6.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFNetworkManager+Common.h"

#define GF_API_GET_STARTUP_IMAGE ApiAddress(@"/api/startup/getStartupImage")
#define GF_API_GET_FEED_ADVERTISE ApiAddress(@"/api/ad/frontAd")
#define GF_API_REPORT_LOGIN_TIME ApiAddress(@"/api/user/updateLastLoginTime")
#define GF_API_REPORT_LOCATION ApiAddress(@"/api/userLocation/add")

@implementation GFNetworkManager (Common)

+ (NSUInteger)getStartupImageSuccess:(void (^)(NSUInteger, NSInteger, GFAdImageMTL *, NSString *))success
                             failure:(void (^)(NSUInteger, NSError *))failure {
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_GET_STARTUP_IMAGE
                                                    parameters:nil
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *versionInAppStore = [responseObject objectForKey:@"iOSOnlineVersion"];
                                                           NSDictionary *dict = [responseObject objectForKey:@"image"];
                                                           GFAdImageMTL *adImage = nil;
                                                           if (dict && [dict isKindOfClass:[NSDictionary class]]) {
                                                               adImage = [MTLJSONAdapter modelOfClass:[GFAdImageMTL class] fromJSONDictionary:dict error:nil];
                                                           }
                                                           if (success) {
                                                               success(taskId, code, adImage, versionInAppStore);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

+ (NSUInteger)getFeedAdvertiseListSuccess:(void (^)(NSUInteger, NSInteger, NSArray<GFAdFeedMTL *> *))success
                                  failure:(void (^)(NSUInteger, NSInteger))failure {
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_GET_FEED_ADVERTISE
                                                    parameters:nil
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSArray *advertises = nil;
                                                           if (code == 1) {
                                                               NSArray *tmpAdList = [responseObject objectForKey:@"data"];
                                                               if (tmpAdList) {
                                                                   advertises = [MTLJSONAdapter modelsOfClass:[GFAdFeedMTL class] fromJSONArray:tmpAdList error:nil];
                                                               }
                                                           }
                                                           if (success) {
                                                               success(taskId, code, advertises);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           //
                                                       }];
    return taskId;
}

+ (void)reportLoginTimeToGetfunServer {
    [[GFNetworkManager sharedManager] POST:GF_API_REPORT_LOGIN_TIME
                                parameters:nil
                                   success:^(NSUInteger taskId, id responseObject) {
                                       //
                                   } failure:^(NSUInteger taskId, NSError *error) {
                                       //
                                   }];
}

+ (void)reportLocationLatitude:(CLLocationDegrees)latitude
                     longitude:(CLLocationDegrees)longitude {
    
    NSNumber *la = [NSNumber numberWithDouble:latitude];
    NSNumber *lo = [NSNumber numberWithDouble:longitude];
    [[GFNetworkManager sharedManager] POST:GF_API_REPORT_LOCATION
                                parameters:@{
                                             @"latitude" : la,
                                             @"longitude" : lo
                                             }
                                   success:^(NSUInteger taskId, id responseObject) {
                                       //
                                   } failure:^(NSUInteger taskId, NSError *error) {
                                       //
                                   }];
}

@end
