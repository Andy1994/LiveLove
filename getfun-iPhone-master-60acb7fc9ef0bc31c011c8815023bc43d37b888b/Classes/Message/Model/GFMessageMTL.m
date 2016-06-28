//
//  GFMessageMTL.m
//  GetFun
//
//  Created by zhouxz on 16/1/26.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFMessageMTL.h"

@implementation GFMessageDetailMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {

    return @{
             @"messageId" : @"id",
             @"sessionId" : @"sessionId",
             @"sourceUserId" : @"fromUserId",
             @"destUserId" : @"toUserId",
             @"messageType" : @"messageType",
             @"sendTime" : @"sentTime",
             @"unread" : @"unread",
             @"title" : @"title",
             @"content" : @"content",
             @"linkUrl" : @"linkUrl",
             @"relatedId" : @"relatedId",
             @"relatedUserId" : @"relatedUserId",
             @"relatedUserCount" : @"relatedUserCount"
             };
}

+ (NSValueTransformer *)messageTypeJSONTransformer {
    
    return [MTLValueTransformer transformerWithBlock:^id(id type) {
        return @(messageType(type));
    }];
}

- (NSString *)title {
    return [_title stringByReplacingHTMLEntities];
}

- (NSString *)content {
    return [_content stringByReplacingHTMLEntities];
}

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    if (!object || ![object isKindOfClass:[GFMessageDetailMTL class]]) return NO;
    GFMessageDetailMTL *message = (GFMessageDetailMTL *)object;
    return message.messageId && [self.messageId isEqualToNumber:message.messageId];
}

@end

@implementation GFRelatedDataMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    
    return @{
             @"relatedCommentInfo" : @"comment",
             @"relatedUser" : @"user",
             @"relatedGroupInfo" : @"group"
             };
}

+ (NSValueTransformer *)relatedCommentInfoJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[GFCommentInfoMTL class]];
}

+ (NSValueTransformer *)relatedUserJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[GFUserMTL class]];
}

+ (NSValueTransformer *)relatedGroupInfoJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[GFGroupInfoMTL class]];
}

@end

@implementation GFMessageMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {

    return @{
             @"messageDetail" : @"message",
             @"messageSender" : @"sender",
             @"relatedData" : @"relatedData"
             };
}

+ (NSValueTransformer *)messageDetailJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[GFMessageDetailMTL class]];
}

+ (NSValueTransformer *)messageSenderJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[GFUserMTL class]];
}

+ (NSValueTransformer *)relatedDataJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[GFRelatedDataMTL class]];
}

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    if (!object || ![object isKindOfClass:[GFMessageMTL class]]) return NO;
    GFMessageMTL *message = (GFMessageMTL *)object;
    return [self.messageDetail isEqual:message.messageDetail];
}

@end