//
//  GFGroupPublishCell.h
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/22.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFBaseCollectionViewCell.h"

@interface GFGroupPublishCell : GFBaseCollectionViewCell

@property (nonatomic, copy) void(^publishHandler)(GFContentType publishType);

@end
