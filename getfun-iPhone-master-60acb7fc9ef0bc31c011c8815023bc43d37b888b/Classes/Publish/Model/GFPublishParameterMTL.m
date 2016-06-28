//
//  GFPublishParameterMTL.m
//  GetFun
//
//  Created by zhouxz on 15/12/1.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFPublishParameterMTL.h"

@implementation GFPublishMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"longitude" : @"longitude",
             @"latitude" : @"latitude",
             @"address" : @"address",
             @"topics" : @"topics",
             @"preview" : @"preview",
             @"state" : @"state",
             @"publishId" : @"publishId",
             @"groupId" : @"groupId",
             @"tagId" : @"tagId"
             };
}

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    if (!object || ![object isKindOfClass:[GFPublishMTL class]]) return NO;
    GFPublishMTL *publish = (GFPublishMTL *)object;
    return self.publishId && [publish.publishId isEqualToNumber:self.publishId];
}

@end

@implementation GFPublishArticleMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"title" : @"title",
             @"content" : @"content",
             @"summary" : @"summary",
             @"imageUrl" : @"imageUrl",
             @"longitude" : @"longitude",
             @"latitude" : @"latitude",
             @"address" : @"address",
             @"topics" : @"topics",
             @"preview" : @"preview",
             @"state" : @"state",
             @"publishId" : @"publishId",
             @"groupId" : @"groupId",
              @"tagId" : @"tagId"};
}

@end

@implementation GFPublishVoteMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"title" : @"title",
             @"imageTitle1" : @"imageTitle1",
             @"imageUrl1" : @"imageUrl1",
             @"imageTitle2" : @"imageTitle2",
             @"imageUrl2" : @"imageUrl2",
             @"longitude" : @"longitude",
             @"latitude" : @"latitude",
             @"address" : @"address",
             @"topics" : @"topics",
             @"preview" : @"preview",
             @"state" : @"state",
             @"publishId" : @"publishId",
             @"groupId" : @"groupId",
             @"tagId" : @"tagId"};
}

@end

@implementation GFPublishLinkMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"url" : @"url",
             @"title" : @"title",
             @"longitude" : @"longitude",
             @"latitude" : @"latitude",
             @"address" : @"address",
             @"topics" : @"topics",
             @"preview" : @"preview",
             @"state" : @"state",
             @"publishId" : @"publishId",
             @"groupId" : @"groupId",
             @"tagId" : @"tagId"};
}

@end

@implementation GFPublishPictureMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"content" : @"content",
             @"pictures" : @"images",
             @"longitude" : @"longitude",
             @"latitude" : @"latitude",
             @"address" : @"address",
             @"topics" : @"topics",
             @"preview" : @"preview",
             @"state" : @"state",
             @"publishId" : @"publishId",
             @"groupId" : @"groupId",
             @"tagId" : @"tagId"
             };
}

@end