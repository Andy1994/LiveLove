//
//  NTESQzoneShareActivity.h
//  JiaoYou
//
//  Created by muhuaxin on 15/4/19.
//  Copyright (c) 2015年 NetEase.com, Inc. All rights reserved.
//

#import "NTESActivity.h"

@interface NTESQzoneShareActivity : NTESActivity

- (instancetype)initWithURL:(NSString *)url
                      image:(UIImage *)originalImage
                 thumbImage:(UIImage*)thumbImage
                      title:(NSString*)title
                description:(NSString*)description;

@end
