//
//  NTESActivityViewController.h
//  JiaoYou
//
//  Created by muhuaxin on 15-2-10.
//  Copyright (c) 2015年 NetEase.com, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTESWeixinSessionShareActivity.h"
#import "NTESWeixinTimelineShareActivity.h"
#import "NTESQQSessionShareActivity.h"
#import "NTESQzoneShareActivity.h"
#import "NTESSinaWeiboShareActivity.h"

typedef void (^NTESActivityViewControllerCompletionHandler)(NSString *activityType, BOOL completed);


//原理参考UIActivityViewController
@interface NTESActivityViewController : UIViewController

@property (nonatomic, copy) NSArray *applicationActivities;//element type: NTESHTActivity


- (instancetype)initWithActivityItem:(NSDictionary *)activityItem applicationActivities:(NSArray *)applicationActivities;

- (void)showIn:(UIViewController *)parentViewController;
- (void)cancelAction;

+ (NSArray *)getDefaultShareActivitiesWithURL:(NSString *)url
                                        image:(UIImage *)image
                                   thumbImage:(UIImage *)thumbImage
                                        title:(NSString *)title
                                  description:(NSString *)description;

@property(nonatomic,copy) NTESActivityViewControllerCompletionHandler completionHandler;

@end