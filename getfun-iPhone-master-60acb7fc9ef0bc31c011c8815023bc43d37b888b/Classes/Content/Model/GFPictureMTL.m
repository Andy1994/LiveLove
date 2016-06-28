//
//  GFPictureMTL.m
//  GetFun
//
//  Created by zhouxz on 15/11/14.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFPictureMTL.h"

@implementation GFPictureMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    
    return @{
             @"storeKey" : @"storeKey",
             @"url" : @"url",
             @"width" : @"width",
             @"height" : @"height",
             @"format" : @"format"
             };
}

+ (NSValueTransformer *)formatJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(id format) {
        return @(pictureFormat(format));
    } reverseBlock:^id(id format) {
        return pictureFormatKey([format integerValue]);
    }];
//    return [MTLValueTransformer transformerWithBlock:^id(id format) {
//        return @(pictureFormat(format));
//    }];
}
@end
