//
//  GFFollowerMTL.m
//  GetFun
//
//  Created by Liu Peng on 16/3/14.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFFollowerMTL.h"

@implementation GFFollowerMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    
    return @{
             @"user" : @"user",
             @"contentUnreadCount" : @"contentUnreadCount",
             @"loginUserFollowUser" : @"loginUserFollowUser",
             @"userFollowLoginUser" : @"userFollowLoginUser"
             };
}

+ (NSValueTransformer *)userJSONTransformer {
    return [MTLValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[GFUserMTL class]];
}

- (GFFollowState)followState {
    GFFollowState followState = 0;
    if(!self.loginUserFollowUser){ //不关注Ta
        followState = GFFollowStateNo;
    } else if(self.loginUserFollowUser && !self.userFollowLoginUser) { //关注Ta但Ta不关注我
        followState = GFFollowStateFollowing;
    } else if(self.loginUserFollowUser && self.userFollowLoginUser) {//和Ta互相关注
        followState = GFFollowStateFollowingEachOther;
    }
    return followState;
}

@end
