//
//  GFLocationPicker.h
//  GetFun
//
//  Created by zhouxz on 15/12/12.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GFProvinceAndCityPicker : NSObject

+ (void)gf_showProvinceAndCityPickerInitialProvinceId:(NSNumber *)iniProvinceId
                                        initialCityId:(NSNumber *)iniCityId
                                           completion:(void (^)(NSNumber *provinceId, NSString *provinceName, NSNumber *cityId, NSString *cityName))completion
                                               cancel:(void (^)())cancel;



+(NSString *)gf_getProvinceAndCityByProvinceId:(NSNumber *)provinceId cityId:(NSNumber *)cityId;

@end
