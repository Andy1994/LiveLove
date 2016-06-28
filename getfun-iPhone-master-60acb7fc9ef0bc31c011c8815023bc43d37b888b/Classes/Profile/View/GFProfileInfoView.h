//
//  GFProfileInfoView.h
//  GetFun
//
//  Created by zhouxz on 15/12/7.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFBaseCollectionViewCell.h"
#import "GFProfileMTL.h"
#import "GFGroupMTL.h"

@interface GFProfileInfoView : UICollectionReusableView

+ (CGFloat)heightWithModel:(GFProfileMTL *)profileMTL;
- (void)updateWithProfile:(GFProfileMTL *)profileMTL;

@property (nonatomic, strong, readonly) HMSegmentedControl *segmentedControl;
@property (nonatomic, strong, readonly) UIButton *followButton; //1.3版本新手引导提示，需要暴露该按钮

@property (nonatomic, copy) void (^detailInfoButtonHandler)();
@property (nonatomic, copy) void (^followButtonHandler)(GFProfileInfoView *profileInfoView, GFFollowState state);
@property (nonatomic, copy) void (^followerTapHandler)();
@property (nonatomic, copy) void (^followeeTapHandler)();
@property (nonatomic, copy) void (^groupTapHandler)();
@property (nonatomic, copy) void (^segmentedControlHandler)(NSInteger index);
@property (nonatomic, copy) HMTitleFormatterBlock segmentControlTitleFormatter;
@property (nonatomic, assign) NSInteger currentSegmentedIndex;
@end
