//
//  GFProfileMTL.h
//  GetFun
//
//  Created by Liu Peng on 16/3/14.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "GFUserMTL.h"

@interface GFProfileMTL : MTLModel<MTLJSONSerializing>

@property (nonatomic, strong) GFUserMTL *user;
@property (nonatomic, strong) NSNumber *funCount;  //fun数
@property (nonatomic, strong) NSNumber *publishCount; //发布数
@property (nonatomic, strong) NSNumber *commentCount;  //评论数
@property (nonatomic, strong) NSNumber *participationCount;  //参与数
@property (nonatomic, strong) NSNumber *interestGroupCount;  //创建、加入的get帮数
@property (nonatomic, strong) NSNumber *followerCount;  //关注“我”的用户数
@property (nonatomic, strong) NSNumber *followeeCount; //“我”关注的用户数

@property (nonatomic, assign) BOOL loginUserFollowUser; //当前登录用户是否关注了user
@property (nonatomic, assign) BOOL userFollowLoginUser; //user是否关注了当前登录用户

- (GFFollowState)followState;

@end
