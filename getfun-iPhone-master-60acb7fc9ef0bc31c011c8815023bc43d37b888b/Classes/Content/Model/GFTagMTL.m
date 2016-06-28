//
//  GFTagMTL.m
//  GetFun
//
//  Created by zhouxz on 15/11/14.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFTagMTL.h"
#import "GFContentMTL.h"

@implementation GFTagInfoMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"tagId" : @"id",
             @"tagName" : @"name",
             @"tagHexColor" : @"color",
             @"thumbnail" : @"thumbnail",
             @"frontImageUrl" : @"frontImage",
             @"tagDescription" : @"description",
             @"contentCount" : @"contentCount",
             @"userCount" : @"collectedUserCount",
             @"children" : @"children"
             };
}

+ (NSValueTransformer *)childrenJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[GFTagInfoMTL class]];
}

- (NSString *)tagName {
    return [_tagName stringByReplacingHTMLEntities];
}

- (NSString *)tagDescription {
    return [_tagDescription stringByReplacingHTMLEntities];
}

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    if (!object || ![object isKindOfClass:[GFTagMTL class]]) return NO;
    GFTagInfoMTL *tagInfo = (GFTagInfoMTL *)object;
    return self.tagId && [tagInfo.tagId isEqualToNumber:self.tagId];
}

@end

@implementation GFTagExMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"interestImageUrl" : @"imageUrl"
             };
}

@end

@implementation GFTagMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"tagInfo" : @"tag",
             @"pictures" : @"pictures",
             @"updateCount" : @"newContentCount",
             @"collected" : @"isCollected",
             @"interestTagEx" : @"interestTag",
             @"contents" : @"contents",
             @"addTime" : @"addTime",
             @"prologues" : @"prologues"  //add proglogues
             };
}

+ (NSValueTransformer *)tagInfoJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[GFTagInfoMTL class]];
}

+ (NSValueTransformer *)picturesJSONTransformer {
    
    return [MTLValueTransformer transformerWithBlock:^id(id value) {

        NSDictionary *jsonDict = value;
        NSMutableDictionary *picturesDict = [[NSMutableDictionary alloc] initWithCapacity:[jsonDict count]];

        [jsonDict bk_each:^(id key, id obj) {

            GFPictureMTL *picture = [MTLJSONAdapter modelOfClass:[GFPictureMTL class] fromJSONDictionary:obj error:nil];
            [picturesDict setObject:picture forKey:key];
        }];
        
        return picturesDict;
    }];
}

+ (NSValueTransformer *)interestTagExJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[GFTagExMTL class]];
}

+ (NSValueTransformer *)contentsJSONTransformer {
    return [MTLValueTransformer transformerWithBlock:^id(id value) {

        NSMutableArray *contents = [[NSMutableArray alloc] initWithCapacity:2];

        if ([value isKindOfClass:[NSArray class]]) {
            NSArray *tmpContentList = value;
            for (NSDictionary *dict in tmpContentList) {
                GFContentMTL *tmpContent = [MTLJSONAdapter modelOfClass:[GFContentMTL class] fromJSONDictionary:dict error:nil];
                if (tmpContent && tmpContent.contentInfo.type != GFContentTypeUnknown) {
                    [contents addObject:tmpContent];
                    
                    if ([contents count] == 2) break;
                }
            }
        }
        
        return contents;
    }];
}

/**
 *  Prologues
 */
+ (NSValueTransformer *)prologuesJSONTransformer {
    return [MTLValueTransformer transformerWithBlock:^id(id value) {
        
        if ([value isKindOfClass:[NSArray class]]) {
            return [MTLJSONAdapter modelsOfClass:[GFTagPrologueMTL class] fromJSONArray:value error:nil];
        }
        return nil;
    }];
}

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    if (!object || ![object isKindOfClass:[GFTagMTL class]]) return NO;
    GFTagMTL *tagMTL = (GFTagMTL *)object;
    return [self.tagInfo.tagId integerValue] == [tagMTL.tagInfo.tagId integerValue];
}

@end

//Prologue解析
@implementation GFTagPrologueMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"tagId" : @"tagId",
             @"prologue" : @"prologue"
             };
}

- (NSString *)prologue {
    return [_prologue stringByReplacingHTMLEntities];
}

@end