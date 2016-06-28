//
//  GFSelectInterestViewCell.h
//  GetFun
//
//  Created by Liu Peng on 15/12/9.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, GFSelectInterestViewCellStyle) {
    GFSelectInterestViewCellUserGuide = 1,
    GFSelectInterestViewCellCreateGroup = 2,
    GFSelectInterestViewCellCreateGroupAll = 3,
};

@interface GFSelectInterestViewCell : UICollectionViewCell

@property (strong, nonatomic, readonly) id model;

- (void)bindWithModel:(id)model withStyle:(GFSelectInterestViewCellStyle)style;
@end
