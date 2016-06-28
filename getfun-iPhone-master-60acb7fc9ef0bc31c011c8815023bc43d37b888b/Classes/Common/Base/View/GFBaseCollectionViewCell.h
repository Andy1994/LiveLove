//
//  GFBaseCollectionViewCell.h
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/15.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GFBaseCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong, readonly) id model;

+ (CGFloat)heightWithModel:(id)model;
- (void)bindWithModel:(id)model;

@end
