//
//  GFNetworkStatusUtil.h
//  IfengFM
//
//  Created by zhouxz on 14/12/26.
//  Copyright (c) 2014年 IfengFM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface GFNetworkStatusUtil : NSObject

+ (AFNetworkReachabilityStatus)networkStatus;
+ (void)startMonitoring;
+ (void)stopMonitoring;
+ (void)setNetworkStatusChangeBlock:(void (^)(AFNetworkReachabilityStatus status))block;

@end
