//
//  GFContentDetailUserInfoView.h
//  GetFun
//
//  Created by muhuaxin on 15/11/21.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFContentMTL.h"
#import "GFUserMTL.h"

#define kContentDetailUserInfoViewHeight  54.0f

@interface GFContentDetailUserInfoView : UIView

- (void)bindModel:(GFContentMTL *)content;
@property (nonatomic, copy) void (^avatarTappedHandler)(GFUserMTL *user);

@end
