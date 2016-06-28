//
//  GFPublishOptionView.h
//  GetFun
//
//  Created by zhouxz on 15/12/9.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFGroupMTL.h"

#define kPublishOptionViewHeight 52.0f

typedef NS_ENUM(NSInteger, GFPublishOptionAction) {
    GFPublishOptionActionAddress = 0,
    GFPublishOptionActionPhoto = 1
};

typedef NS_OPTIONS(NSInteger, GFPublishOptionStyle) {
    GFPublishOptionStyleAddress = 1 << 0,
    GFPublishOptionStylePhoto = 1 << 1,
    GFPublishOptionStyleAll = GFPublishOptionStyleAddress | GFPublishOptionStylePhoto
};

@interface GFPublishOptionView : UIView

@property (nonatomic, assign) GFPublishOptionStyle style;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) void(^publishOptionHandler)(GFPublishOptionAction action);

+ (instancetype)publishOptionView;

@end
