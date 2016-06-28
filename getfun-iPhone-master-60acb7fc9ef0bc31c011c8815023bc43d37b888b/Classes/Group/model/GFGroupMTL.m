//
//  GFGroupMTL.m
//  GetFun
//
//  Created by Liu Peng on 15/12/1.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFGroupMTL.h"

@implementation GFGroupInfoMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"groupId" : @"id",
             @"userId" : @"userId",
             @"name" : @"name",
             @"imgUrl":@"completeImgUrl",
             @"tagId":@"tagId",
             @"memberCount":@"memberCount",
             @"address":@"address",
             @"longitude":@"longitude",
             @"latitude":@"latitude",
             @"groupDescription":@"description",
             @"auditStatus":@"auditStatus"
             };
}

+ (NSValueTransformer *)auditStatusJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(id status) {
        return @(groupAuditStatus(status));
    } reverseBlock:^id(id status) {
        return groupAuditStatusKey([status integerValue]);
    }];
}

- (NSString *)name {
    return [_name stringByReplacingHTMLEntities];
}

- (NSString *)address {
    return [_address stringByReplacingHTMLEntities];
}

- (NSString *)groupDescription {
    return [_groupDescription stringByReplacingHTMLEntities];
}

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    if (!object || ![object isKindOfClass:[GFGroupInfoMTL class]]) return NO;
    
    GFGroupInfoMTL *groupInfo = (GFGroupInfoMTL *)object;
    return groupInfo.groupId && [self.groupId isEqualToNumber:groupInfo.groupId];
}

@end

@implementation GFGroupMTL
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"groupInfo" : @"interestGroup",
             @"user" : @"user",
             @"tagList":@"tagList",
             @"distance" : @"distance",
             @"memberList": @"memberList",
             @"joined" : @"loginUserJoined",
             @"checkedIn" : @"loginUserCheckin",
             @"created" : @"loginUserCreated"
             };
}

+ (NSValueTransformer *)groupInfoJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[GFGroupInfoMTL class]];
//    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[GFGroupInfoMTL class]];
}

+ (NSValueTransformer *)userJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[GFUserMTL class]];
//    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[GFUserMTL class]];
}

+ (NSValueTransformer *)memberListJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[GFUserMTL class]];
//    return [MTLJSONAdapter arrayTransformerWithModelClass:[GFUserMTL class]];
}

+ (NSValueTransformer *)tagListJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[GFTagInfoMTL class]];
//    return [MTLJSONAdapter arrayTransformerWithModelClass:[GFTagInfoMTL class]];
}

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    if (!object || ![object isKindOfClass:[GFGroupMTL class]]) return NO;
    GFGroupMTL *group = (GFGroupMTL *)object;
    return [group.groupInfo isEqual:self.groupInfo];
}
@end
