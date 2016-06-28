//
//  NTESSinaWeiboShareActivity.m
//  JiaoYou
//
//  Created by muhuaxin on 15-4-17.
//  Copyright (c) 2015年 NetEase.com, Inc. All rights reserved.
//

#import "NTESSinaWeiboShareActivity.h"
#import "NTESSinaWeiboManager.h"

@interface NTESSinaWeiboShareActivity()

@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) UIImage *thumbImage;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;

@end

@implementation NTESSinaWeiboShareActivity

- (instancetype)initWithURL:(NSString *)url
                      image:(UIImage *)originalImage
                 thumbImage:(UIImage*)thumbImage
                      title:(NSString*)title
                description:(NSString*)description
{
    self = [super init];
    if (self) {
        self.url = url;
        self.originalImage = originalImage;
        self.thumbImage = thumbImage;
        self.title = title;
        self.desc = description;
    }
    return self;
}

- (NTESActivityCategory)activityCategory
{
    return NTESActivityCategoryShare;
}

- (NSString *)activityType
{
    return @"WEIBO";
}

- (NSString *)activityTitle
{
    return @"新浪微博";
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"icon_sina"];
}

- (BOOL)canPerformWithActivityItem:(NSDictionary *)item
{
    return [NTESSinaWeiboManager isSinaWeiboShareSupported];
}

- (void)prepareWithActivityItem:(NSDictionary *)item
{
    
}

- (void)performActivity
{
    if (self.originalImage) {
        [NTESSinaWeiboManager shareImage:self.originalImage
                              thumbImage:self.thumbImage
                                   title:self.title
                             description:self.desc];
    } else if (self.url) {
        [NTESSinaWeiboManager shareURL:self.url
                            thumbImage:self.thumbImage
                                 title:self.title
                           description:self.desc];
    }
}

- (void)activityDidFinish:(BOOL)finished
{
    
}

@end
