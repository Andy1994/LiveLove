//
//  GFFollowTableViewCell.h
//  GetFun
//
//  Created by Liu Peng on 16/3/14.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFBaseTableViewCell.h"

typedef NS_ENUM(NSInteger, GFFollowTableViewCellStyle) {
    GFFollowTableViewCellStyleMyFollower = 1,
    GFFollowTableViewCellStyleMyFollowee = 2,
    GFFollowTableViewCellStyleOtherFollower = 3,
    GFFollowTableViewCellStyleOtherFollowee = 4,
};

@class GFFollowTableViewCell;

@protocol GFFollowTableViewCellDelegate <NSObject>

- (void)followActionWithButton:(UIButton *)button InCell:(GFFollowTableViewCell *)cell;

@end

@interface GFFollowTableViewCell : GFBaseTableViewCell

@property (nonatomic, assign) GFFollowTableViewCellStyle style;
@property (nonatomic, weak) id<GFFollowTableViewCellDelegate> delegate;
@end
