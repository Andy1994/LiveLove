//
//  GFContentDetailMTL.m
//  GetFun
//
//  Created by muhuaxin on 15/11/21.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFContentDetailMTL.h"
#import "GFVoteItemMTL.h"

@implementation GFContentDetailMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"contentId" : @"id",
             @"title" : @"title",
             @"content" : @"content",
             @"type" : @"type",
             };
}

+ (Class)classForParsingJSONDictionary:(NSDictionary *)JSONDictionary {

    NSString *typeKey = JSONDictionary[@"type"];
    
    if (contentType(typeKey) == GFContentTypeArticle) return [GFContentDetailArticleMTL class];
    if (contentType(typeKey) == GFContentTypeLink) return [GFContentDetailLinkMTL class];
    if (contentType(typeKey) == GFContentTypeVote) return [GFContentDetailVoteMTL class];
    if (contentType(typeKey) == GFContentTypePicture) return [GFContentDetailPictureMTL class];
    
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

- (NSString *)content {
    return [_content stringByReplacingHTMLEntities];
}

@end


@implementation GFContentDetailArticleMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"contentId" : @"id",
             @"title" : @"title",
             @"content" : @"content",
             @"type" : @"type",
             @"imageUrl" : @"imageUrl",
             @"summary" : @"summary",
             };
}

- (NSString *)summary {
    return [_summary stringByReplacingHTMLEntities];
}

@end

@implementation GFContentDetailPictureMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"contentId" : @"id",
             @"title" : @"title",
             @"content" : @"content",
             @"type" : @"type",
             @"pictureSummary" : @"pictureSummary"
             };
}

@end

@implementation GFContentDetailVoteMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"contentId" : @"id",
             @"title" : @"title",
             @"content" : @"content",
             @"type" : @"type",
             @"imageUrl" : @"imageUrl",
             @"startTime" : @"startTime",
             @"endTime" : @"endTime",
             @"peopleLimited" : @"peopleLimited",
             @"peopleInvolved" : @"peopleInvolved",
             @"voteItems" : @"voteItems",
             };
}

+ (NSValueTransformer *)voteItemsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[GFVoteItemMTL class]];
}

@end

@implementation GFContentDetailLinkMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"contentId" : @"id",
             @"title" : @"title",
             @"content" : @"content",
             @"type" : @"type",
             @"url" : @"url",
             @"urlTitle" : @"urlTitle",
             @"urlImageUrl" : @"urlImageUrl",
             @"urlContent" : @"urlContent",
             @"urlSummary" : @"urlSummary",
             @"domainName" : @"domainName",
             };
}

- (NSString *)urlTitle {
    return [_urlTitle stringByReplacingHTMLEntities];
}

- (NSString *)urlContent {
    return [_urlContent stringByReplacingHTMLEntities];
}

- (NSString *)urlSummary {
    return [_urlSummary stringByReplacingHTMLEntities];
}

@end