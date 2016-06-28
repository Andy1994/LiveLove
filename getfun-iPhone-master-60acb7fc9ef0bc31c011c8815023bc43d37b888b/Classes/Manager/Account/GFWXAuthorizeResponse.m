//
//  GFWXAuthorizeResponse.m
//  GetFun
//
//  Created by zhouxz on 15/12/15.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFWXAuthorizeResponse.h"

@implementation GFWXAuthorizeResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey {

    return @{
             @"access_token" : @"access_token",
             @"expires_in" : @"expires_in",
             @"openid" : @"openid",
             @"refresh_token" : @"refresh_token",
             @"scope" : @"scope",
             @"unionid" : @"unionid"
             };
}

@end
