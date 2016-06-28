//
//  NTESActivity.h
//  JiaoYou
//
//  Created by muhuaxin on 15-2-11.
//  Copyright (c) 2015年 NetEase.com, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, NTESActivityCategory) {
    NTESActivityCategoryAction,
    NTESActivityCategoryShare,
};

@class NTESActivityViewController;

//原理参考UIActivity
@interface NTESActivity : NSObject

- (NTESActivityCategory)activityCategory;

- (NSString *)activityType;

- (NSString *)activityTitle;

- (UIImage *)activityImage;

- (BOOL)canPerformWithActivityItem:(NSDictionary *)item;

- (void)prepareWithActivityItem:(NSDictionary *)item;

- (UIViewController *)activityViewController;

- (void)performActivity;

- (void)activityDidFinish:(BOOL)finished;

//private
- (void)_setActivityViewController:(NTESActivityViewController *)activityViewController;

@end
