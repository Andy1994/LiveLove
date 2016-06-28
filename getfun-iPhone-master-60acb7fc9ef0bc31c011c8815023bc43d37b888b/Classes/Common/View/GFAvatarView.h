//
//  GFAvatarView.h
//  GetFun
//
//  Created by zhouxz on 15/12/7.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFUserMTL.h"

/**
 *  头像类，注意：头像初始化时必须指定大小，否则下载图片切割圆角时会导致错误
 */
@interface GFAvatarView : UIView

- (void)updateWithUser:(GFUserMTL *)user;

@property (nonatomic, assign) BOOL isUserInterestColorShowed; //是否显示用户兴趣色
@property (nonatomic, assign) BOOL isShowedInFeedList; //是否在Feed流中显示, 用于决定获取网络图片规范类型

@end
