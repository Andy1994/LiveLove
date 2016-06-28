//
//  GFGroupMemberMTL.m
//  GetFun
//
//  Created by Liu Peng on 15/12/5.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFGroupMemberMTL.h"

@implementation GFGroupMemberStateMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    
    return @{
             @"groupId" : @"groupId",
             @"userId" : @"userId",
             @"checkinTime":@"checkinTime"
             };
}

@end

@implementation GFGroupMemberMTL
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    
    return @{
             @"state" : @"groupMember",
             @"user" : @"user"
             };
}


+ (NSValueTransformer *)userJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[GFUserMTL class]];
}

+ (NSValueTransformer *)stateJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[GFGroupMemberStateMTL class]];
}



@end
