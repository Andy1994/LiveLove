//
//  NTESQQSessionShareActivity.m
//  JiaoYou
//
//  Created by muhuaxin on 15/4/19.
//  Copyright (c) 2015年 NetEase.com, Inc. All rights reserved.
//

#import "NTESQQSessionShareActivity.h"
#import "NTESQQManager.h"

@interface NTESQQSessionShareActivity()

@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) UIImage *thumbImage;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@end

@implementation NTESQQSessionShareActivity

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
    return @"QQ";
}

- (NSString *)activityTitle
{
    return @"QQ好友";
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"icon_qq"];
}

- (BOOL)canPerformWithActivityItem:(NSDictionary *)item
{
    return [NTESQQManager isQQShareSupported];
}

- (void)prepareWithActivityItem:(NSDictionary *)item
{
    
}

- (void)performActivity
{
//    if (self.url) {
        [NTESQQManager shareToSessionWithURL:self.url
                                  thumbImage:self.thumbImage
                                       title:self.title
                                 description:self.desc];
        return;
//    } else if (self.originalImage) {
//        [NTESHTQQManager shareToSessionWithImage:self.originalImage thumbImage:self.thumbImage title:self.title description:self.desc staticsType:self.staticsType];
//        return;
//    }
}

- (void)activityDidFinish:(BOOL)finished
{
    
}

@end