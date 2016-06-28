//
//  GFGroupMemberInfoView.h
//  GetFun
//
//  Created by liupeng on 15/12/3.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFUserMTL.h"
#import <UIKit/UIKit.h>

@interface GFGroupMemberInfoView : UIView
/**
 *  根据用户信息进行更新
 *
 *  @param user 用户
 */
- (void)updateWithUser:(GFUserMTL *)user;


/**
 *  计算高度
 *
 *  @param model
 *
 *  @return 
 */
+ (CGFloat)heightWithModel:(id)model;

@end
