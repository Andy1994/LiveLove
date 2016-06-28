//
//  GFProfileMTL.m
//  GetFun
//
//  Created by Liu Peng on 16/3/14.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFProfileMTL.h"

@implementation GFProfileMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    
    return @{
             @"user" : @"user",
             @"funCount" : @"funCount",
             @"publishCount" : @"contentCount",
             @"commentCount" : @"commentCount",
             @"participationCount" : @"participationCount",
             @"interestGroupCount" : @"interestGroupCount",
             @"followerCount" : @"followerCount",
             @"followeeCount" : @"followeeCount",
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
