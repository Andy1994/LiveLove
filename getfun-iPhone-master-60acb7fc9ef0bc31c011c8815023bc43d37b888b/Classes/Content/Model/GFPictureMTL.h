//
//  GFPictureMTL.h
//  GetFun
//
//  Created by zhouxz on 15/11/14.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface GFPictureMTL : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *storeKey;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) GFPictureFormat format;

@end
