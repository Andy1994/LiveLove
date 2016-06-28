//
//  GFMyGroupCell.h
//  GetFun
//
//  Created by Liu Peng on 15/12/15.
//  Copyright © 2015年 17GetFun. All rights reserved.
//


#import "GFBaseCollectionViewCell.h"
#import "GFGroupMTL.h"

typedef NS_ENUM(NSInteger, GFMyGroupCellStyle) {
    GFMyGroupCellStyleCheckIn   = 1,
    GFMyGroupCellStyleArrow     = 2
};

@interface GFMyGroupCell : GFBaseCollectionViewCell

@property (nonatomic, assign) GFMyGroupCellStyle style;
@property (nonatomic, copy) void(^checkInHandler)(GFGroupMTL *group);

- (void)updateCheckInState:(BOOL)checkedIn;
@end
