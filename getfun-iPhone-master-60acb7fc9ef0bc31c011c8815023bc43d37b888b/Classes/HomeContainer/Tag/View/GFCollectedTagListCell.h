//
//  GFCollectedTagListCell.h
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/15.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFBaseCollectionViewCell.h"
#import "GFTagMTL.h"

#define kCollectedTagListCellHeight 129.0f

@interface GFCollectedTagListCell : GFBaseCollectionViewCell

@property (nonatomic, copy) void(^selectTagHandler)(GFTagMTL *tag);

@end
