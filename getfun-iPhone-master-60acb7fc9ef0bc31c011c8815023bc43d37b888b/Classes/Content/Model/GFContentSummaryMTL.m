//
//  GFContentSummaryMTL.m
//  GetFun
//
//  Created by muhuaxin on 15/11/21.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFContentSummaryMTL.h"

@implementation GFContentSummaryMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"contentId" : @"id",
             @"title" : @"title",
             @"type" : @"type",
             };
}

+ (Class)classForParsingJSONDictionary:(NSDictionary *)JSONDictionary {
    
    NSString *typeKey = JSONDictionary[@"type"];
    
    if (contentType(typeKey) == GFContentTypeArticle) return [GFContentSummaryArticleMTL class];
    if (contentType(typeKey) == GFContentTypeLink) return [GFContentSummaryLinkMTL class];
    if (contentType(typeKey) == GFContentTypeVote) return [GFContentSummaryVoteMTL class];
    if (contentType(typeKey) == GFContentTypePicture) return [GFContentSummaryPictureMTL class];
    
    return nil;
}

+ (NSValueTransformer *)typeJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(id type) {
        return @(contentType(type));
    } reverseBlock:^id(id type) {
        return contentTypeKey([type integerValue]);
    }];
}

- (NSString *)title {
    return [_title stringByReplacingHTMLEntities];
}

@end


@implementation GFContentSummaryArticleMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"contentId" : @"id",
             @"title" : @"title",
             @"type" : @"type",
             @"imageUrl" : @"imageUrl",
             @"summary" : @"summary",
             @"pictureSummary" : @"pictureSummary",
             };
}

- (NSString *)summary {
    return [_summary stringByReplacingHTMLEntities];
}

@end

@implementation GFContentSummaryVoteMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"contentId" : @"id",
             @"title" : @"title",
             @"type" : @"type",
             @"voteItems" : @"voteItems",
             };
}

+ (NSValueTransformer *)voteItemsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[GFVoteItemMTL class]];
}

@end

@implementation GFContentSummaryLinkMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"contentId" : @"id",
             @"title" : @"title",
             @"type" : @"type",
             @"url" : @"url",
             @"urlTitle" : @"urlTitle",
             @"urlSummary" : @"urlSummary",
             @"urlImageUrl" : @"urlImageUrl",
             @"hasVideo" : @"hasVideo",
             };
}

- (NSString *)urlTitle {
    return [_urlTitle stringByReplacingHTMLEntities];
}

- (NSString *)urlSummary {
    return [_urlSummary stringByReplacingHTMLEntities];
}

@end

@implementation GFContentSummaryPictureMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"contentId" : @"id",
             @"title" : @"title",
             @"type" : @"type",
             @"pictureSummary" : @"pictureSummary",
             };
}

@end