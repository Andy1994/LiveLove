//
//  GFCollegeMTL.m
//  GetFun
//
//  Created by zhouxz on 15/12/11.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFCollegeMTL.h"

@implementation GFCollegeMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"collegeId" : @"id",
             @"code" : @"code",
             @"name" : @"name",
             @"countryId" : @"countryId",
             @"provinceId" : @"provinceId"
             };
}

- (NSString *)name {
    return [_name stringByReplacingHTMLEntities];
}

@end
