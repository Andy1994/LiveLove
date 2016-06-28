//
//  GFSwipeTableViewCell.h
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/5.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import <SWTableViewCell/SWTableViewCell.h>

@interface GFSwipeTableViewCell : SWTableViewCell

@property (nonatomic, strong) id model;

+ (CGFloat)heightWithModel:(id)model;

- (void)bindWithModel:(id)model;

@end
