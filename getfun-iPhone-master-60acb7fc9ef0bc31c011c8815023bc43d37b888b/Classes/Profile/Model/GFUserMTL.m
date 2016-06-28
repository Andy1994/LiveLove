//
//  GFUserMTL.m
//  GetFun
//
//  Created by muhuaxin on 15/11/12.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFUserMTL.h"

@implementation GFUserMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    
    return @{
             @"userId" : @"id",
             @"mobile" : @"mobile",
             @"nickName" : @"nickName",
             @"age" : @"age",
             @"avatar" : @"avatar",
             @"birthday" : @"birthday",
             @"channelId" : @"channelId",
             @"provinceId" : @"provinceId",
             @"provinceName" : @"provinceName",
             @"cityId" : @"cityId",
             @"cityName" : @"cityName",
             @"collegeId" : @"collegeId",
             @"collegeName" : @"collegeName",
             @"departmentId" : @"departmentId",
             @"departmentName" : @"departmentName",
             @"enrollTime" : @"enrollTime",
             @"gender" : @"sex",
             @"shareLocation" : @"shareLocation",
             @"createTime" : @"createTime",
             @"color" : @"color",
             @"professions" : @"titles"
             };
}

- (NSString *)nickName {
    return [_nickName stringByReplacingHTMLEntities];
}

- (NSString *)provinceName {
    return [_provinceName stringByReplacingHTMLEntities];
}

- (NSString *)cityName {
    return [_cityName stringByReplacingHTMLEntities];
}

- (NSString *)collegeName {
    return [_collegeName stringByReplacingHTMLEntities];
}

- (NSString *)departmentName {
    return [_departmentName stringByReplacingHTMLEntities];
}


+ (NSValueTransformer *)genderJSONTransformer {    
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(id gender) {
        //String->GFUserGender
        return @(userGender(gender));
    } reverseBlock:^id(id gender) {
        //GFUserGender->String
        return userGenderKey([gender integerValue]);
        
    }];
}

+ (NSValueTransformer *)professionsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[GFProfessionMTL class]];
}

@end

@implementation GFProfessionUserInfoMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    
    return @{
             @"addTime" : @"addTime"
             };
}
@end

@implementation GFProfessionInfoMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    
    return @{
             @"name" : @"name",
             @"iconUrl" : @"iconUrl"
             };
}

- (NSString *)name {
    return [_name stringByReplacingHTMLEntities];
}
@end


@implementation GFProfessionMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    
    return @{
             @"info" : @"title",
             @"userInfo" : @"userTitle"
             };
}

+ (NSValueTransformer *)infoJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[GFProfessionInfoMTL class]];
}


+ (NSValueTransformer *)userInfoJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[GFProfessionUserInfoMTL class]];
}
@end
