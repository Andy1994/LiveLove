//
//  GFGroupContentMTL.m
//  GetFun
//
//  Created by Liu Peng on 15/12/2.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFGroupContentMTL.h"

@implementation GFGroupContentMTL
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    
    return @{
             @"user" : @"user",
             @"content" : @"content",
             @"action" : @"action"
             };
}

+ (NSValueTransformer *)userJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[GFUserMTL class]];
}

+ (NSValueTransformer *)contentJSONTransformer {
    
    return [MTLValueTransformer transformerWithBlock:^id(id content) {
        GFContentMTL *contentMTL = [MTLJSONAdapter modelOfClass:[GFContentMTL class] fromJSONDictionary:content error:nil];
        if (contentMTL && contentMTL.contentInfo.type != GFContentTypeUnknown) {
            return contentMTL;
        } else {
            return nil;
        }
    }];
}

+ (NSValueTransformer *)actionJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(id action) {
        return @(userAction(action));
    } reverseBlock:^id(id action) {
        return userActionKey([action integerValue]);
    }];
}

@end
