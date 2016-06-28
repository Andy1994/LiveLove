//
//  GFRecommendGroupCell.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/17.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFRecommendGroupCell.h"
#import "GFGroupMTL.h"
#import "GFRecommendGroupView.h"

// 默认是"全部"按钮和箭头
@interface GFRecommendGroupHeader : UIView

- (void)setupHeaderViewIcon:(UIImage *)iconImage
                      title:(NSString *)title
                 rightTitle:(NSString *)rightTitle
             accessoryImage:(UIImage *)accessoryImage
             showRightTitle:(BOOL)showRightTitle
         rightSelectHandler:(void (^)(UIButton * button))handler;

@property (nonatomic, strong) UILabel *rightTitleLabel;

@end

@implementation GFRecommendGroupHeader
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self gf_AddBottomBorderWithColor:[UIColor themeColorValue15] andWidth:0.5f];
    }
    return self;
}

- (void)setupHeaderViewIcon:(UIImage *)iconImage
                      title:(NSString *)title
                 rightTitle:(NSString *)rightTitle
             accessoryImage:(UIImage *)accessoryImage
             showRightTitle:(BOOL)showRightTitle
         rightSelectHandler:(void (^)(UIButton * button))handler {
    
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIImageView *iconImageView = nil;
    UILabel *titleLabel = nil;
    UIImageView *accessoryImageView = nil;
    self.rightTitleLabel = nil;
    
    if (iconImage) {
        iconImageView = [[UIImageView alloc] initWithImage:iconImage];
        [iconImageView sizeToFit];
        iconImageView.center = CGPointMake(15 + iconImageView.width/2, self.height/2);
        [self addSubview:iconImageView];
    }
    
    if (title) {
        titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.textColor = [UIColor textColorValue1];
        titleLabel.font = [UIFont systemFontOfSize:17.0];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.text = title;
        [titleLabel sizeToFit];
        titleLabel.center = CGPointMake(iconImage? iconImageView.right+7+titleLabel.width/2 : 12+titleLabel.width/2, self.height/2);
        [self addSubview:titleLabel];
    }
    
    if (accessoryImage) {
        accessoryImageView = [[UIImageView alloc] initWithImage:accessoryImage];
        accessoryImageView.frame = CGRectMake(0, 0, 15, 15);
        accessoryImageView.center = CGPointMake(self.width-15-accessoryImageView.width/2, self.height/2);
        [self addSubview:accessoryImageView];
    }
    
    if (rightTitle) {
        self.rightTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.rightTitleLabel.text = rightTitle;
        self.rightTitleLabel.textColor = [UIColor themeColorValue10];
        self.rightTitleLabel.font = [UIFont systemFontOfSize:14.0];
        self.rightTitleLabel.textAlignment = NSTextAlignmentRight;
        [self.rightTitleLabel sizeToFit];
        self.rightTitleLabel.center = CGPointMake(accessoryImageView ? accessoryImageView.x-10-self.rightTitleLabel.width/2 : self.width-15-self.rightTitleLabel.width/2, self.height/2);
        [self addSubview:self.rightTitleLabel];
        self.rightTitleLabel.hidden = !showRightTitle;
    }
    
    
    if (handler) {
        UIButton *hiddenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        hiddenButton.frame = CGRectMake(self.width-120,
                                        0,
                                        120,
                                        self.height);
        [hiddenButton bk_addEventHandler:^(id sender) {
            handler(hiddenButton);
        } forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:hiddenButton];
    }
}

@end

@interface GFRecommendGroupCell ()

@property (nonatomic, strong) GFRecommendGroupHeader *headerView;
@property (nonatomic, strong) UIView *itemListView;

@end

@implementation GFRecommendGroupCell

- (GFRecommendGroupHeader *)headerView {
    if (!_headerView) {
        _headerView = [[GFRecommendGroupHeader alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
        _headerView.backgroundColor = [UIColor whiteColor];
    }
    return _headerView;
}

- (UIView *)itemListView {
    if (!_itemListView) {
        _itemListView = [[UIView alloc] initWithFrame:CGRectZero];
        _headerView.backgroundColor = [UIColor whiteColor];
    }
    return _itemListView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor themeColorValue13];
        [self.contentView addSubview:self.headerView];
        [self.contentView addSubview:self.itemListView];
        self.maxItemCount = 3;        
    }
    return self;
}

- (void)dealloc {
    [_headerView removeFromSuperview];
    _headerView = nil;
}

+ (CGFloat)heightWithModel:(id)model {
    return [self heightWithModel:model maxItemCount:NSUIntegerMax];
}

+ (CGFloat)heightWithModel:(id)model maxItemCount:(NSUInteger)maxItemCount{
    
    CGFloat height = 50.0f;
    
    NSArray<GFGroupMTL *> *groupList = model;
    return height + [GFRecommendGroupView groupItemViewHeight] * MIN(maxItemCount, [groupList count]);
}

- (void)bindWithModel:(id)model style:(GFRecommendGroupCellStyle)style showRightTitle:(BOOL)showRightTitle{
    
    [super bindWithModel:model];
    _style = style;
    
    __weak typeof(self) weakSelf = self;
    NSArray<GFGroupMTL *> *groupList = model;
    switch (style) {
        case GFRecommendGroupCellStyle_Home: {
            [self.headerView setupHeaderViewIcon:[UIImage imageNamed:@"group_recommend_icon"]
                                           title:@"推荐给我的Get帮"
                                      rightTitle:@"全部"
                                  accessoryImage:[UIImage imageNamed:@"accessory_arrow_dark"]
                                  showRightTitle:showRightTitle
                              rightSelectHandler:^(UIButton *button){
                                  if (weakSelf.righButtonHandler) {
                                      weakSelf.righButtonHandler(weakSelf);
                                  }
                              }];
            break;
        }
        case GFRecommendGroupCellStyle_ProfileByInterest: {
            [self.headerView setupHeaderViewIcon:nil
                                           title:@"你可能感兴趣的帮"
                                      rightTitle:@"换一换"
                                  accessoryImage:nil
                                  showRightTitle:showRightTitle
                              rightSelectHandler:^(UIButton *button){
                                  if (weakSelf.righButtonHandler) {
                                      weakSelf.righButtonHandler(weakSelf);
                                  }
                              }];
            break;
        }
        case GFRecommendGroupCellStyle_ProfileByDistance: {
            [self.headerView setupHeaderViewIcon:nil
                                           title:@"离你最近"
                                      rightTitle:@"换一换"
                                  accessoryImage:nil
                                  showRightTitle:showRightTitle
                              rightSelectHandler:^(UIButton *button){
                                  if (weakSelf.righButtonHandler) {
                                      weakSelf.righButtonHandler(weakSelf);
                                  }
                              }];
            break;
        }
        case GFRecommendGroupCellStyle_Tag: {
            [self.headerView setupHeaderViewIcon:nil
                                           title:@"相关Get帮"
                                      rightTitle:[NSString stringWithFormat:@"全部%@个", @(groupList.count)]
                                  accessoryImage:[UIImage imageNamed:@"accessory_arrow_dark"]
                                  showRightTitle:showRightTitle
                              rightSelectHandler:^(UIButton *button){
                                  if (weakSelf.righButtonHandler) {
                                      weakSelf.righButtonHandler(weakSelf);
                                  }
                              }];
            self.headerView.rightTitleLabel.textColor = [UIColor textColorValue4];
            break;
        }
    }
    
    [[self.itemListView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSUInteger index = 0;
    for (GFGroupMTL *interestGroup in groupList) {
        
        if (index >= self.maxItemCount) {
            break;
        }
        
        GFRecommendGroupView *itemView = [[GFRecommendGroupView alloc] initWithFrame:CGRectZero];
        itemView.tag = index;
        itemView.group = interestGroup;
        __weak typeof(self) weakSelf = self;
        [itemView bk_whenTapped:^{
            if (weakSelf.groupSelectHandler) {
                weakSelf.groupSelectHandler(weakSelf, itemView);
            }
        }];
        
        itemView.distanceVisible = (style == GFRecommendGroupCellStyle_ProfileByDistance) || (style == GFRecommendGroupCellStyle_Home);
        itemView.locationVisible = (style != GFRecommendGroupCellStyle_ProfileByInterest);
        
        [self.itemListView addSubview:itemView];
        
        //添加分隔线，注意其数目比itemView数目少一个
        if (index>=1) {
            itemView.topBorderVisible = YES;
        }
        index++;
    }
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    const CGFloat itemHeight = [GFRecommendGroupView groupItemViewHeight];
    self.itemListView.frame = CGRectMake(0, self.headerView.bottom, self.contentView.width, itemHeight * [self.itemListView.subviews count]);
    
    for (GFRecommendGroupView *itemView in [self.itemListView subviews]) {
        NSUInteger index = [[self.itemListView subviews] indexOfObject:itemView];
        itemView.frame = CGRectMake(0, itemHeight * index, self.contentView.width, itemHeight);
    }
}

@end
