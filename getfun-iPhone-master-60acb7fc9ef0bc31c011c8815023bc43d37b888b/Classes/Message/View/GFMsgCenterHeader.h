//
//  GFMsgCenterHeader.h
//  GetFun
//
//  Created by zhouxz on 16/1/28.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFUnreadCountMTL.h"

@interface GFMsgCenterHeader : UIView

@property (nonatomic, copy) void (^msgCenterHeaderHandler)(GFBasicMessageType type);

- (void)updateUnreadBadge:(GFUnreadCountMTL *)unreadCount;

@end
