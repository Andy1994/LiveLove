//
//  GFTagRelatedGroupViewController.h
//  GetFun
//
//  Created by Liu Peng on 16/1/6.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFBaseViewController.h"
#import "GFGroupMTL.h"

/**
 显示标签关联的Get帮列表
 */
@interface GFTagRelatedGroupViewController : GFBaseViewController

- (instancetype)initWithGroupList:(NSArray<GFGroupMTL *> *)groupList;

@end
