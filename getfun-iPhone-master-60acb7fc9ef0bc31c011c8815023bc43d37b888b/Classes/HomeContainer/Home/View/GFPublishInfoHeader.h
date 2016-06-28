//
//  GFPublishInfoHeader.h
//  GetFun
//
//  Created by zhouxiangzhong on 16/3/4.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GFPublishInfoHeader : UICollectionReusableView

@property (nonatomic, copy) void (^retryHandler)();
@property (nonatomic, copy) void (^deleteHandler)();
- (void)setInfoText:(NSString *)text;
- (void)showRetryAndDeleteButton:(BOOL)show;

@end
