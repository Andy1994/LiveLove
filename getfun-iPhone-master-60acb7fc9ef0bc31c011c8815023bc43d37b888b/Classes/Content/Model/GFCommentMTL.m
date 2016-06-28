//
//  GFCommentMTL.m
//  GetFun
//
//  Created by muhuaxin on 15/11/17.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFCommentMTL.h"
#import "GFUserMTL.h"
#import "GFPictureMTL.h"
#import "GFContentMTL.h"

@implementation GFCommentMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"commentInfo" : @"comment",
             @"user" : @"user",
             @"parent" : @"parent",
             @"children" : @"children",
             @"hasMoreChildren" : @"hasMoreChildren",
             @"loginUserHasFuned" : @"loginUserHasFuned",
             @"content" : @"content",
             @"pictures" : @"pictureMap",
             @"emotions" : @"emoticonMap"
             };
}

+ (NSValueTransformer *)commentInfoJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[GFCommentInfoMTL class]];
}

+ (NSValueTransformer *)userJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[GFUserMTL class]];
}

+ (NSValueTransformer *)parentJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[GFCommentMTL class]];
}

+ (NSValueTransformer *)childrenJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[GFCommentMTL class]];
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

+ (NSValueTransformer *)emotionsJSONTransformer {
    
    return [MTLValueTransformer transformerWithBlock:^id(id emotions) {
        NSDictionary *jsonDict = emotions;
        NSMutableDictionary *emotionsDict = [[NSMutableDictionary alloc] initWithCapacity:[jsonDict count]];
        
        [jsonDict bk_each:^(id key, id obj) {
            GFEmotionMTL *emotion = [MTLJSONAdapter modelOfClass:[GFEmotionMTL class] fromJSONDictionary:obj error:nil];
            [emotionsDict setObject:emotion forKey:key];
        }];
        
        return emotionsDict;
    }];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (!object || ![object isKindOfClass:[GFCommentMTL class]]) {
        return NO;
    }
    GFCommentMTL *commentMTL = (GFCommentMTL *)object;
    return [self.commentInfo.commentId integerValue] == [commentMTL.commentInfo.commentId integerValue];
}
@end

@implementation GFCommentInfoMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"commentId" : @"id",
             @"commentContent" : @"content",
             @"replyCountTotal" : @"replyCountTotal",
             @"funCount" : @"funCount",
             @"createTime" : @"createTime",
             @"parentId" : @"parentId",
             @"relatedId" : @"relatedId",
             @"rootCommentId" : @"rootId",
             @"pictureKeys" : @"pictureKeys",
             @"emotionIds" : @"emoticonIds"
             };
}

- (NSString *)commentContent {
    return [_commentContent stringByReplacingHTMLEntities];
}

@end
