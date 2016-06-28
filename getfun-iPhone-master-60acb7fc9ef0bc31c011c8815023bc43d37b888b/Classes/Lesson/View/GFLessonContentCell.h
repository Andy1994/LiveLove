//
//  GFLessonContentCell.h
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/25.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFBaseCollectionViewCell.h"
#import "GFUserInfoHeader.h"
#import "GFUserMTL.h"

@interface GFLessonContentCell : GFBaseCollectionViewCell

@property (nonatomic, strong, readonly) GFUserInfoHeader *userInfoHeader;

@property (nonatomic, copy) void (^showAllButtonHandler)();

- (void)bindWithModel:(id)model userInfo:(GFUserMTL *)user;

@end
