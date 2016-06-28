//
//  GFGroupInfoViewController.h
//  GetFun
//
//  Created by Liu Peng on 15/12/5.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFBaseViewController.h"
#import "GFGroupMTL.h"

@interface GFGroupInfoViewController : GFBaseViewController

@property (nonatomic, copy) void(^joinGroupHandler)(GFGroupMTL *group);
@property (nonatomic, copy) void(^quitGroupHandler)(GFGroupMTL *group);
@property (nonatomic, copy) void(^updateSignInHandler)(GFGroupMTL *group);
- (instancetype)initWithGroup:(GFGroupMTL *)group;

  @end
