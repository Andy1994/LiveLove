//
//  GFContentDetailFunUsersView.h
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/22.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFBaseCollectionViewCell.h"
#import "GFUserMTL.h"
#import "GFContentMTL.h"

@interface GFContentDetailFunUsersView : GFBaseCollectionViewCell

@property (nonatomic, copy) void(^funUserAvatarHandler)(GFUserMTL *user);

@end
