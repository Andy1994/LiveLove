//
//  GFNetworkManager+Common.h
//  GetFun
//
//  Created by zhouxz on 16/1/6.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFNetworkManager.h"
#import "GFAdvertiseMTL.h"
#import <CoreLocation/CoreLocation.h>

@interface GFNetworkManager (Common)

+ (NSUInteger)getStartupImageSuccess:(void (^)(NSUInteger taskId, NSInteger code, GFAdImageMTL *image, NSString *versionInAppStore))success
                             failure:(void (^)(NSUInteger taskId, NSError *error))failure;

+ (NSUInteger)getFeedAdvertiseListSuccess:(void (^)(NSUInteger taskId, NSInteger code, NSArray<GFAdFeedMTL *> *advertises))success
                                  failure:(void (^)(NSUInteger taskId, NSInteger code))failure;

+ (void)reportLoginTimeToGetfunServer;

+ (void)reportLocationLatitude:(CLLocationDegrees)latitude
                     longitude:(CLLocationDegrees)longitude;

@end
