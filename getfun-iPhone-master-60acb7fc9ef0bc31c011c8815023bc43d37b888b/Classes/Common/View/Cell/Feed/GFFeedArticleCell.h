//
//  GFFeedArticleCell.h
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/17.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFFeedContentCell.h"

@interface GFFeedArticleCell : GFFeedContentCell

- (void)startLoadingImages;
@property (nonatomic, copy) void (^tapImageHandler)(GFFeedArticleCell *cell, NSUInteger iniImageIndex);

@end
