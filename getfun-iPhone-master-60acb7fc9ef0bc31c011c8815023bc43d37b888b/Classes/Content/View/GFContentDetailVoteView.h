//
//  GFContentDetailVoteView.h
//  GetFun
//
//  Created by muhuaxin on 15/11/26.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFContentDetailUserInfoView.h"
#import "GFContentDetailTagContainerView.h"
#import "GFVoteView.h"

#import "GFContentMTL.h"

@interface GFContentDetailVoteView : UIView

@property (nonatomic, strong, readonly) GFContentDetailUserInfoView *userInfoView;
@property (nonatomic, strong, readonly) GFContentDetailTagContainerView *tagContainer;
@property (nonatomic, strong, readonly) GFVoteView *voteView;

+ (CGFloat)viewHeightWithContent:(GFContentMTL *)content;
- (void)updateContent:(GFContentMTL *)content animate:(BOOL)animate;

@end
