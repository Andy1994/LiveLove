//
//  GFContentMTL.m
//  GetFun
//
//  Created by muhuaxin on 15/11/14.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFContentMTL.h"
#import "GFUserMTL.h"
#import "GFContentInfoMTL.h"
#import "GFContentSummaryMTL.h"
#import "GFContentDetailMTL.h"

#import "GFTagMTL.h"
#import "GFPictureMTL.h"
#import "GFCommentMTL.h"

/**
 *  actionStatuses字典中的key
 *  value的类型是{
        "count": 0,
        "relatedId": 0
    }
 */
NSString * const GFContentMTLActionStatusesKeyCollect = @"COLLECT";
NSString * const GFContentMTLActionStatusesKeyPublish = @"PUBLISH";
NSString * const GFContentMTLActionStatusesKeySpecial = @"SPECIAL";
NSString * const GFContentMTLActionStatusesKeyInit = @"INIT";
NSString * const GFContentMTLActionStatusesKeyFun = @"FUN";
NSString * const GFContentMTLActionStatusesKeyShare = @"SHARE";
NSString * const GFContentMTLActionStatusesKeyComment = @"COMMENT";
NSString * const GFContentMTLActionStatusesKeyForward = @"FORWARD";
NSString * const GFContentMTLActionStatusesKeyView = @"VIEW";
NSString * const GFContentMTLActionStatusesKeyCheckin = @"CHECKIN";

@implementation GFSubContentMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"subContentId" : @"id",
             @"contentId" : @"contentId",
             @"userId" : @"userId",
             @"content" : @"content",
             @"createTime" : @"createTime",
             @"updateTime" : @"updateTime"
             };
}

- (NSString *)content {
    return [_content stringByReplacingHTMLEntities];
}

@end

@implementation GFContentActionStatus

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"count" : @"count",
             @"relatedId" : @"relatedId",
             };
}

@end


@implementation GFContentMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"contentInfo" : @"content",
             @"user" : @"user",
             @"funUsers" : @"funUsers",
             @"contentSummary" : @"contentSummary",
             @"contentDetail" : @"contentDetail",
             @"tags" : @"tags",
             @"topics" : @"topics",
             @"comments":@"comments",
             @"pictures" : @"pictures",
             @"actionStatuses" : @"actionStatuses",
             @"subContents" : @"broadcastingList"
             };
}

+ (NSValueTransformer *)contentInfoJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[GFContentInfoMTL class]];
}

+ (NSValueTransformer *)userJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[GFUserMTL class]];
}

+ (NSValueTransformer *)funUsersJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[GFUserMTL class]];
}

+ (NSValueTransformer *)contentSummaryJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[GFContentSummaryMTL class]];
}

+ (NSValueTransformer *)contentDetailJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[GFContentDetailMTL class]];
}

+ (NSValueTransformer *)tagsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[GFTagInfoMTL class]];
}

+ (NSValueTransformer *)commentsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[GFCommentMTL class]];
}

+ (NSValueTransformer *)picturesJSONTransformer {
    
    return [MTLValueTransformer transformerWithBlock:^id(id pictures) {
        NSDictionary *jsonDict = pictures;
        NSMutableDictionary *picturesDict = [[NSMutableDictionary alloc] initWithCapacity:[jsonDict count]];

        [jsonDict bk_each:^(id key, id obj) {
            GFPictureMTL *picture = [MTLJSONAdapter modelOfClass:[GFPictureMTL class] fromJSONDictionary:obj error:nil];
            [picturesDict setObject:picture forKey:key];
        }];
        
        return picturesDict;
    }];
}

+ (NSValueTransformer *)actionStatusesJSONTransformer {
    
    return [MTLValueTransformer transformerWithBlock:^id(id value) {
        if ([value isKindOfClass:[NSDictionary class]]) {
            NSDictionary *jsonDict = value;
            NSMutableDictionary *actionStatuses = [[NSMutableDictionary alloc] initWithCapacity:[jsonDict count]];

            [jsonDict bk_each:^(id key, id obj) {
                GFContentActionStatus *actionStatus = [MTLJSONAdapter modelOfClass:[GFContentActionStatus class] fromJSONDictionary:obj error:nil];
                [actionStatuses setObject:actionStatus forKey:key];
            }];
            return actionStatuses;
        } else {
            return nil;
        }
        return nil;
    }];
}

+ (NSValueTransformer *)subContentsJSONTransformer {
    return [MTLValueTransformer mtl_JSONArrayTransformerWithModelClass:[GFSubContentMTL class]];
}

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    if (!object || ![object isKindOfClass:[GFContentMTL class]]) return NO;
    GFContentMTL *content = (GFContentMTL *)object;
    return [self.contentInfo isEqual:content.contentInfo];
}

- (BOOL)isGetfunLesson {
    
    if (self.contentInfo.type != GFContentTypeArticle) return NO;
    if (!self.subContents || [self.subContents count] == 0) return NO;
    
    return YES;
}

- (BOOL)isFunned {
    GFContentActionStatus *funActionStatus = [self.actionStatuses objectForKey:GFContentMTLActionStatusesKeyFun];
    return [funActionStatus.count integerValue] > 0;
}

@end