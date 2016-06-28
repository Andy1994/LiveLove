//
//  GFGroupInfoViewController.h
//  GetFun
//
//  Created by Liu Peng on 15/12/1.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFBaseViewController.h"
#import "GFGroupMTL.h"

@interface GFGroupDetailViewController : GFBaseViewController

@property (nonatomic, copy) void(^quitGroupHandler)(GFGroupMTL *);
@property (nonatomic, copy) void(^updateSignInHandler)(void);

- (instancetype)initWithGroup:(GFGroupMTL *)group;

@end
