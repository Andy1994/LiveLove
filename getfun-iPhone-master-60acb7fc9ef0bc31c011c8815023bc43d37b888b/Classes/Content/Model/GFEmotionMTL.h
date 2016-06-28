//
//  GFEmotionMTL.h
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/23.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface GFEmotionMTL : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSNumber *emotionId;
@property (nonatomic, copy) NSString *emotionName;
@property (nonatomic, copy) NSString *emotionDesc;
@property (nonatomic, strong) NSNumber *packageId;
@property (nonatomic, copy) NSString *storeKey;
@property (nonatomic, copy) NSString *pictureKey;
@property (nonatomic, copy) NSString *imgUrl;

@end
