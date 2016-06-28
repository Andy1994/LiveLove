//
//  GFFunRecordMTL.m
//  GetFun
//
//  Created by zhouxz on 15/12/10.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFFunRecordMTL.h"

NSString *funTypeKey(GFFunType type) {
    
    NSString *key = nil;
    switch (type) {
        case GFFunTypeContent: {
            key = @"content";
            break;
        }
        case GFFunTypeComment: {
            key = @"comment";
            break;
        }
    }
    
    return [key uppercaseString];
}

GFFunType funType(NSString *key) {
    
    key = [key uppercaseString];
    GFFunType funType = 0;
    
    if ([key isEqualToString:funTypeKey(GFFunTypeComment)]) funType = GFFunTypeComment;
    if ([key isEqualToString:funTypeKey(GFFunTypeContent)]) funType = GFFunTypeContent;
    
    return funType;
}

@implementation GFFunRecordMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"funType" : @"funType",
             @"extendComment" : @"extendComment",
             @"content" : @"contentSummaryForDisplay"
             };
}

+ (NSValueTransformer *)funTypeJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(id type) {
        return @(funType(type));
    } reverseBlock:^id(id type) {
        return funTypeKey([type integerValue]);
    } ];
//    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
//                                                                           @"CONTENT": @(GFFunTypeContent),
//                                                                           @"COMMENT": @(GFFunTypeComment)
//                                                                           }];
}

+ (NSValueTransformer *)extendCommentJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[GFCommentMTL class]];
//    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[GFCommentMTL class]];
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
    
//    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[GFContentMTL class]];

    //    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[GFContentMTL class]];
}
@end
