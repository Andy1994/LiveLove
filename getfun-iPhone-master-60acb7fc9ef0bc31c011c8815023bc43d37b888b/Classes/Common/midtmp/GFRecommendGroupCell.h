//
//  GFRecommendGroupCell.h
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/17.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFBaseCollectionViewCell.h"
#import "GFRecommendGroupView.h"

typedef NS_ENUM(NSUInteger, GFRecommendGroupCellStyle) {
    GFRecommendGroupCellStyle_Home,                // 首页推荐get帮
    GFRecommendGroupCellStyle_ProfileByInterest,   // 个人页按兴趣推荐get帮
    GFRecommendGroupCellStyle_ProfileByDistance,   // 个人页按距离推荐get帮
    GFRecommendGroupCellStyle_Tag               // 热门标签详情页推荐相关get帮
};

// GFRecommendGroupCell是一个大的cell容器，内部包含多个GFRecommendGroupView
@interface GFRecommendGroupCell : GFBaseCollectionViewCell

@property (nonatomic, copy) void(^groupSelectHandler)(GFRecommendGroupCell *cell, GFRecommendGroupView *itemView);
@property (nonatomic, copy) void(^righButtonHandler)(GFRecommendGroupCell *cell);

@property (nonatomic, assign, readonly) GFRecommendGroupCellStyle style;
@property (nonatomic, assign) NSInteger maxItemCount;

- (void)bindWithModel:(id)model style:(GFRecommendGroupCellStyle)style showRightTitle:(BOOL)showRightTitle;
+ (CGFloat)heightWithModel:(id)model maxItemCount:(NSUInteger)maxItemCount;

@end
