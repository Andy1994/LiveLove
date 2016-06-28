//
//  GFTagHeaderView.h
//  GetFun
//
//  Created by w on 16/3/16.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GFTagHeaderView : UIView

//自定义操作
@property (nonatomic, copy) void(^publishHandler)(GFContentType publishType);

- (void)bindWithModel:(id)model;

@end
