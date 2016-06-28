//
//  GFContentInfoMTL.m
//  GetFun
//
//  Created by zhouxz on 15/11/14.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFContentInfoMTL.h"

@implementation GFContentInfoMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    
    return @{
             @"contentId" : @"id",
             @"type" : @"type",
             @"createTime" : @"createTime",
             @"latitude" : @"latitude",
             @"longitude" : @"longitude",
             @"address" : @"address",
             @"userId" : @"userId",
             @"viewCount" : @"viewCount",
             @"commentCount" : @"commentCount",
             @"forwardCount" : @"forwardCount",
             @"shareCount" : @"shareCount",
             @"collectCount" : @"collectCount",
             @"funCount" : @"funCount",
             @"specialCount" : @"specialCount",
             @"pullCount" : @"pullCount",
             @"status" : @"status"
             };
}

+ (NSValueTransformer *)typeJSONTransformer {
    
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(id type) {
        return @(contentType(type));
    } reverseBlock:^id(id type) {
        return contentTypeKey([type integerValue]);
    }];
}
+ (NSValueTransformer *)statusJSONTransformer {

    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(id status) {
        return @(contentStatus(status));
    } reverseBlock:^id(id status) {
        return contentStatusKey([status integerValue]);
    }];
}

- (NSString *)address {
    return [_address stringByReplacingHTMLEntities];
}

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    if (!object || ![object isKindOfClass:[GFContentInfoMTL class]]) return NO;
    GFContentInfoMTL *contentInfo = (GFContentInfoMTL *)object;
    return [self.contentId integerValue] == [contentInfo.contentId integerValue];
}
@end
