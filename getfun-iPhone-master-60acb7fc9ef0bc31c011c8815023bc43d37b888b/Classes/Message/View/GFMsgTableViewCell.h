//
//  GFMsgTableViewCell.h
//  GetFun
//
//  Created by zhouxz on 16/1/28.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFSwipeTableViewCell.h"

@interface GFMsgTableViewCell : GFSwipeTableViewCell

@property (nonatomic, copy) void (^msgAvatarHandler)(GFMsgTableViewCell *cell);
@property (nonatomic, assign) BOOL enableDelete;

@end
