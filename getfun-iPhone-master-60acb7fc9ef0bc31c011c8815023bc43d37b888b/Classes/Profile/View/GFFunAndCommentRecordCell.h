//
//  GFFunAndCommentRecordCell.h
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/22.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFBaseCollectionViewCell.h"
#import "GFUserInfoHeader.h"
#import "GFContentSummaryView.h"

@interface GFFunAndCommentRecordCell : GFBaseCollectionViewCell

@property (nonatomic, strong) GFUserInfoHeader *userInfoHeader;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) GFContentSummaryView *contentSummaryView;

- (void)bindWithModel:(id)model user:(GFUserMTL *)user;

@end
