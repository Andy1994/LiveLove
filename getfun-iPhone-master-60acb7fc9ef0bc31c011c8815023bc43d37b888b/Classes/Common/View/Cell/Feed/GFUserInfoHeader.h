//
//  GFUserInfoHeader.h
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/17.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFUserMTL.h"
#import "GFTagMTL.h"


typedef NS_ENUM(NSInteger, GFUserInfoHeaderStyle) {
    GFUserInfoHeaderStyleDefault        = 0,
    GFUserInfoHeaderStyleTag            = 1,
    GFUserInfoHeaderStyleDate           = 2,
    GFUserInfoHeaderStyleDateAndDelete  = 3,
    GFUserInfoHeaderStyleDateAndFun     = 4
};

#define kUserInfoHeaderHeight 44.0f   // 顶部用户信息区域高度
@interface GFUserInfoHeader : UIView

@property (nonatomic, assign) GFUserInfoHeaderStyle style;

@property (nonatomic, copy) void (^avatarHandler)();
@property (nonatomic, copy) void (^deleteHandler)();
@property (nonatomic, copy) void (^tagHandler)();
@property (nonatomic, copy) void (^funHandler)();

- (void)setUserInfo:(GFUserMTL *)user;
- (void)setOriginPoster:(BOOL)isOriginPoster;
- (void)setTagInfo:(GFTagInfoMTL *)tagInfo;
- (void)setDate:(NSTimeInterval)timeInterval;
- (void)setFunned:(BOOL)funned count:(NSInteger)count;

- (void)setTopLineHidden:(BOOL)hidden;
- (void)setBottomLineHidden:(BOOL)hidden;

- (void)doFunAnimation;

@end
