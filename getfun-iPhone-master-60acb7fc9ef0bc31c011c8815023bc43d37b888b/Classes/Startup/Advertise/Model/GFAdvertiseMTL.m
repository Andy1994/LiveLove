//
//  GFAdvertiseMTL.m
//  GetFun
//
//  Created by zhouxz on 16/1/6.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFAdvertiseMTL.h"

@implementation GFAdImageMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"adId" : @"id",
             @"title" : @"title",
             @"adType" : @"type",
             @"channelId" : @"channelId",
             @"imageUrl" : @"imageUrl",
             @"linkUrl" : @"linkUrl"
             };
}

- (NSString *)title {
    return [_title stringByReplacingHTMLEntities];
}

- (NSString *)adType {
    return [_adType stringByReplacingHTMLEntities];
}

- (NSString *)channelId {
    return [_channelId stringByReplacingHTMLEntities];
}

@end

@implementation GFAdFeedMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"adId" : @"id",
             @"adLocationId" : @"location",
             @"adTitle" : @"title",
             @"adDescription" : @"description",
             @"adImageUrl" : @"image",
             @"adRedirectUrl" : @"protocol",
             @"adCreateTime" : @"addTime"
             };
}


- (NSString *)adTitle {
    return [_adTitle stringByReplacingHTMLEntities];
}

- (NSString *)adDescription {
    return [_adDescription stringByReplacingHTMLEntities];
}



@end
