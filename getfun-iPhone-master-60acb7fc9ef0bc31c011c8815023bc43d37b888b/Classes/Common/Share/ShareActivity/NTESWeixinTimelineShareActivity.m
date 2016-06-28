//
//  NTESWeixinTimelineShareActivity.m
//  JiaoYou
//
//  Created by muhuaxin on 15-4-16.
//  Copyright (c) 2015年 NetEase.com, Inc. All rights reserved.
//

#import "NTESWeixinTimelineShareActivity.h"
#import "NTESWeixinManager.h"

@interface NTESWeixinTimelineShareActivity()

@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) UIImage *thumbImage;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@end

@implementation NTESWeixinTimelineShareActivity

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
    return @"CIRCLE";
}

- (NSString *)activityTitle
{
    return @"微信朋友圈";
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"icon_wechat_timeline"];
}

- (BOOL)canPerformWithActivityItem:(NSDictionary *)item
{
    return [NTESWeixinManager isWeixinShareSupported];
}

- (void)prepareWithActivityItem:(NSDictionary *)item
{
    
}

- (void)performActivity
{
    if (self.url) {
        [NTESWeixinManager shareToTimelineWithURL:self.url
                                       thumbImage:self.thumbImage
                                            title:self.title
                                      description:self.desc];
        return;
    } else if (self.originalImage) {
        [NTESWeixinManager shareToTimelineWithImage:self.originalImage
                                         thumbImage:self.thumbImage
                                              title:self.title
                                        description:self.desc];
        return;
    }
}

- (void)activityDidFinish:(BOOL)finished
{
    
}

@end
