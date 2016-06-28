//
//  GFGroupMTL.h
//  GetFun
//
//  Created by Liu Peng on 15/12/1.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "GFUserMTL.h"
#import "GFTagMTL.h"

@interface GFGroupInfoMTL : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSNumber *groupId;
@property (nonatomic, strong) NSNumber *userId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *imgUrl;
@property (nonatomic, strong) NSNumber *tagId;
@property (nonatomic, strong) NSNumber *memberCount;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, copy) NSString *groupDescription;
@property (nonatomic, assign) GFGroupAuditStatus auditStatus;

@end

@interface GFGroupMTL : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) GFGroupInfoMTL *groupInfo;
@property (nonatomic, strong) NSArray<GFTagInfoMTL *> *tagList;
@property (nonatomic, strong) GFUserMTL *user;
@property (nonatomic, strong) NSNumber *distance;
@property (nonatomic, strong) NSArray<GFUserMTL *> *memberList;
@property (nonatomic, assign) BOOL joined;
@property (nonatomic, assign) BOOL checkedIn;
@property (nonatomic, assign) BOOL created;

@end