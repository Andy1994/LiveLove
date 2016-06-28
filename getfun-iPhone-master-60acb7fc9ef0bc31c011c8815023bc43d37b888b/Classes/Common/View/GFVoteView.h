//
//  GFVoteView.h
//  GetFun
//
//  Created by muhuaxin on 15/11/30.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GFContentMTL;
@class GFVoteItemMTL;
@class GFUserMTL;

@interface GFVoteView : UIView

@property (nonatomic, copy) void (^voteItemHandler)(GFVoteItemMTL *vote);
@property (nonatomic, strong, readonly) UILabel *titleLabel;
- (void)updateContent:(GFContentMTL *)content animate:(BOOL)animate;
+ (CGFloat)viewHeightWithContent:(GFContentMTL *)content;

@end
