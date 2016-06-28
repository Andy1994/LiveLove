//
//  NTESActivity.m
//  JiaoYou
//
//  Created by muhuaxin on 15-2-11.
//  Copyright (c) 2015年 NetEase.com, Inc. All rights reserved.
//

#import "NTESActivity.h"
#import "NTESActivityViewController.h"

@interface NTESActivity()

@property (nonatomic, weak) NTESActivityViewController *_activityViewController;

@end

@implementation NTESActivity

- (void)_setActivityViewController:(NTESActivityViewController *)activityViewController
{
    self._activityViewController = activityViewController;
}


- (NTESActivityCategory)activityCategory
{
    return NTESActivityCategoryShare;
}

- (NSString *)activityType
{
    return nil;
}

- (NSString *)activityTitle
{
    return @"";
}

- (UIImage *)activityImage
{
    return nil;
}

- (BOOL)canPerformWithActivityItem:(NSDictionary *)item
{
    return YES;
}

- (void)prepareWithActivityItem:(NSDictionary *)item
{
    
}

- (UIViewController *)activityViewController
{
    return self._activityViewController;
}

- (void)performActivity
{
    
}

- (void)activityDidFinish:(BOOL)finished
{
    
}

@end
