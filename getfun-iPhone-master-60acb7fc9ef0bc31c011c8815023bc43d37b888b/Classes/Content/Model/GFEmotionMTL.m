//
//  GFEmotionMTL.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/23.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFEmotionMTL.h"

@implementation GFEmotionMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"emotionId" : @"id",
             @"emotionName" : @"name",
             @"emotionDesc" : @"description",
             @"packageId" : @"packageId",
             @"storeKey" : @"storeKey",
             @"pictureKey" : @"pictureKey",
             @"imgUrl" : @"imgUrl"
             };
}

- (NSString *)emotionName {
    return [_emotionName stringByReplacingHTMLEntities];
}

- (NSString *)emotionDesc {
    return [_emotionDesc stringByReplacingHTMLEntities];
}

@end
