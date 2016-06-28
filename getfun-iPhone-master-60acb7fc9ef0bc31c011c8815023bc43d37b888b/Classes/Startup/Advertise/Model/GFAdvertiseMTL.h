//
//  GFAdvertiseMTL.h
//  GetFun
//
//  Created by zhouxz on 16/1/6.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface GFAdImageMTL : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSNumber *adId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *adType;

@property (nonatomic, copy) NSString *channelId;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *linkUrl;

@end

@interface GFAdFeedMTL : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSNumber *adId;
@property (nonatomic, strong) NSNumber *adLocationId;
@property (nonatomic, copy) NSString *adTitle;
@property (nonatomic, copy) NSString *adDescription;
@property (nonatomic, copy) NSString *adImageUrl;
@property (nonatomic, copy) NSString *adRedirectUrl;
@property (nonatomic, strong) NSNumber *adCreateTime;

@end
