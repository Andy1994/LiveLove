//
//  GFCopyUrlActionActivity.m
//  GetFun
//
//  Created by muhuaxin on 16/1/6.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFCopyUrlActionActivity.h"

@interface GFCopyUrlActionActivity ()

@property (nonatomic, copy) NSString *url;

@end

@implementation GFCopyUrlActionActivity

- (instancetype)initWithUrl:(NSString *)url {
    self = [super init];
    if (self) {
        self.url = url;
    }
    return self;
}

- (NTESActivityCategory)activityCategory
{
    return NTESActivityCategoryAction;
}

- (NSString *)activityType
{
    return nil;
}

- (NSString *)activityTitle
{
    return @"复制链接";
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"icon_copy_link"];
}

- (BOOL)canPerformWithActivityItem:(NSDictionary *)item
{
    return YES;
}

- (void)prepareWithActivityItem:(NSDictionary *)item
{
    
}

- (void)performActivity
{
    [UIPasteboard generalPasteboard].string = self.url;
}

- (void)activityDidFinish:(BOOL)finished
{
    
}

@end
