//
//  GFGroupInfoCell.h
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/22.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFBaseCollectionViewCell.h"
#import "GFGroupMTL.h"

@interface GFGroupInfoCell : GFBaseCollectionViewCell

@property (nonatomic, copy) void(^memberAvatarListHandler)();
@property (nonatomic, strong) GFGroupMTL *group;

@end
