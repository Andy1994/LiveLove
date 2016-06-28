//
//  GFContentDetailTagContainerView.h
//  GetFun
//
//  Created by muhuaxin on 15/12/7.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GFContentMTL;
@class GFTagInfoMTL;

@interface GFContentDetailTagContainerView : UIView

@property (nonatomic, strong) GFContentMTL *content;
@property (nonatomic, strong) UILabel *firstLabel; //暴露第一个label，用于用户引导
@property (nonatomic, copy) void (^tagHandler)(GFTagInfoMTL *tag, NSInteger tagIndex);

+ (CGFloat)heightWithModel:(GFContentMTL *)content;

@end
