//
//  GFGroupMemberMTL.h
//  GetFun
//
//  Created by Liu Peng on 15/12/5.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "GFUserMTL.h"

@interface GFGroupMemberStateMTL : MTLModel <MTLJSONSerializing>
@property (nonatomic, strong) NSNumber *groupId;
@property (nonatomic, strong) NSNumber *userId;
@property (nonatomic, strong) NSNumber *checkinTime;
@end

@interface GFGroupMemberMTL : MTLModel <MTLJSONSerializing>
@property (nonatomic, strong) GFGroupMemberStateMTL *state;
@property (nonatomic, strong) GFUserMTL *user;
@end
