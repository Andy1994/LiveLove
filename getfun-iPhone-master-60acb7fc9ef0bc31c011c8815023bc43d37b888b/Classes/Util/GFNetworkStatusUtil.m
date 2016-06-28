//
//  GFNetworkStatusUtil.m
//  IfengFM
//
//  Created by zhouxz on 14/12/26.
//  Copyright (c) 2014年 IfengFM. All rights reserved.
//

#import "GFNetworkStatusUtil.h"

@interface GFNetworkStatusUtil ()

@property (nonatomic, strong) AFNetworkReachabilityManager *networkReachabilityManager;

+ (instancetype)sharedInstance;

@end

@implementation GFNetworkStatusUtil

- (AFNetworkReachabilityManager *)networkReachabilityManager {
    if (!_networkReachabilityManager) {
        _networkReachabilityManager = [AFNetworkReachabilityManager sharedManager];
    }
    return _networkReachabilityManager;
}

+ (instancetype)sharedInstance {
    static GFNetworkStatusUtil *instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[GFNetworkStatusUtil alloc] init];
    });
    return instance;
}

+ (AFNetworkReachabilityStatus)networkStatus {
    return [GFNetworkStatusUtil sharedInstance].networkReachabilityManager.networkReachabilityStatus;
}

+ (void)startMonitoring {
    [[GFNetworkStatusUtil sharedInstance].networkReachabilityManager startMonitoring];
}

+ (void)stopMonitoring {
    [[GFNetworkStatusUtil sharedInstance].networkReachabilityManager stopMonitoring];
}

+ (void)setNetworkStatusChangeBlock:(void (^)(AFNetworkReachabilityStatus))block {
    [[GFNetworkStatusUtil sharedInstance].networkReachabilityManager setReachabilityStatusChangeBlock:block];
}


@end
