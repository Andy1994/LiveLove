//
//  GFLocationManager.h
//  GetFun
//
//  Created by zhouxz on 15/11/28.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

@interface GFLocationManager : NSObject

+ (void)initManager;

+ (CLLocation *)lastLocation;

+ (void)startUpdateLocationSuccess:(void (^)(CLLocation *location, AMapLocationReGeocode *regeocode))success
                           failure:(void (^)(NSError *error))failure;

/**
 *  正向地理编码，地址转换为经纬度
 *
 *  @param address 地址
 *  @param success
 *  @param failure
 */
+ (void)locationFromAddress:(NSString *)address
                    success:(void (^)(AMapGeocode *geocode))success
                    failure:(void (^)())failure;

/**
 *  反向地理编码，经纬度转换为地址
 *
 *  @param location 坐标(经纬度)
 *  @param success
 *  @param failure
 */
+ (void)addressFromLocation:(CLLocation *)location
                    success:(void (^)(AMapReGeocode *reGeocode))success
                    failure:(void (^)())failure;

/**
 *  搜索附近地址
 *
 *  @param location 坐标(经纬度)
 *  @param keyword 关键词
 *  @param success
 *  @param failure
 */
+ (void)addressAroundLocation:(CLLocation *)location
                      keyword:(NSString *)keyword
                      success:(void (^)(AMapPOISearchResponse *result))success
                      failure:(void(^)())failure;
@end
