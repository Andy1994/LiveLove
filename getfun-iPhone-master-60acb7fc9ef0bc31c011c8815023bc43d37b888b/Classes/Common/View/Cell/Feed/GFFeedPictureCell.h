//
//  GFFeedPictureCell.h
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/22.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFFeedContentCell.h"

@interface GFFeedPictureCell : GFFeedContentCell

- (void)startLoadingImages;
@property (nonatomic, copy) void (^tapImageHandler)(GFFeedPictureCell *cell, NSUInteger iniImageIndex);

@end
