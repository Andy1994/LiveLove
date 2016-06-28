//
//  GFGroupUpdateViewController.h
//  GetFun
//
//  Created by Liu Peng on 15/12/14.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFBaseViewController.h"
#import "GFGroupMTL.h"
#import "GFTagMTL.h"

@interface GFGroupUpdateViewController : GFBaseViewController

// 更新get帮
- (instancetype)initWithGroup:(GFGroupMTL *)group;

// 创建get帮
- (instancetype)initWithTag:(GFTagInfoMTL *)tag;

// 完成创建或者更新后回调
@property (nonatomic, copy) void(^completionHandler)(NSMutableDictionary * parameters);


@end
