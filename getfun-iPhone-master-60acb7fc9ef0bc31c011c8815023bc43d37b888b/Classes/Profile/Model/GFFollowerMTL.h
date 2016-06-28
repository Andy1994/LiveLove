//
//  GFFollowerMTL.h
//  GetFun
//
//  Created by Liu Peng on 16/3/14.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "GFUserMTL.h"

@interface GFFollowerMTL : MTLModel<MTLJSONSerializing>

@property (nonatomic, strong) GFUserMTL *user;
@property (nonatomic, strong) NSNumber *contentUnreadCount; //当前用户未看过的被关注者的新内容数
@property (nonatomic, assign) BOOL loginUserFollowUser; //当前登录用户是否关注了user
@property (nonatomic, assign) BOOL userFollowLoginUser; //user是否关注了当前登录用户

- (GFFollowState)followState;

@end
