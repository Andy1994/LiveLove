//
//  GFTagHeaderCell.h
//  GetFun
//
//  Created by 陈霄 on 16/3/15.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFBaseCollectionViewCell.h"

@interface GFTagCell : GFBaseCollectionViewCell

//自定义操作
@property (nonatomic, copy) void(^publishHandler)(GFContentType publishType);


- (void)bindWithModel:(id)model;

@end
