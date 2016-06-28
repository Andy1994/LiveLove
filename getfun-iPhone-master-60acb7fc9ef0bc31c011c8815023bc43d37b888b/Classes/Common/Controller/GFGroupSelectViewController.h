//
//  GFGroupSelectViewController.h
//  GetFun
//
//  Created by zhouxz on 15/12/30.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFBaseViewController.h"
#import "GFGroupMTL.h"

@interface GFGroupSelectViewController : GFBaseViewController

@property (nonatomic, copy) void (^groupSelectHandler)(GFGroupMTL * group);

@end
