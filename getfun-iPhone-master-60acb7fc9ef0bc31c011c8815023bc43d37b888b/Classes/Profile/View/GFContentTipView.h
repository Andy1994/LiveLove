//
//  GFContentTipView.h
//  GetFun
//
//  Created by Liu Peng on 16/1/26.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  区分内容提示类型
 */
typedef NS_ENUM(NSUInteger, GFContentTipType) {
    /**
     *  获取内容条数为0
     */
    GFContentTipTypeNoContent,
    /**
     *  网络失败导致无法获取内容
     */
    GFContentTipTypeNetworkError,
};

@interface GFContentTipView : UIView

@property (nonatomic, copy) void(^retryHandler)();

+(instancetype)contentTipViewForType:(GFContentTipType)tipType;

- (void)setTipText:(NSString *)text;
- (void)setTipImage:(UIImage *)image;

@end
