//
//  NTESWeixinTimelineShareActivity.h
//  JiaoYou
//
//  Created by muhuaxin on 15-4-16.
//  Copyright (c) 2015年 NetEase.com, Inc. All rights reserved.
//

#import "NTESActivity.h"

@interface NTESWeixinTimelineShareActivity : NTESActivity

/**
 * url和originalImage 有且只有一个必须为空
 * 当url不为空时，表示分享一个网页
 * 当originalImage不为空时，表示分享一个图片
 */
- (instancetype)initWithURL:(NSString *)url
                      image:(UIImage *)originalImage
                 thumbImage:(UIImage*)thumbImage
                      title:(NSString*)title
                description:(NSString*)description;

@end
