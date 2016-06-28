//
//  GFReviewManager.h
//  GetFun
//
//  Created by zhouxiangzhong on 16/3/23.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle.h>

@interface GFReviewMTL : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign) NSInteger launchCount;
@property (nonatomic, assign) NSInteger notifyCount;
@property (nonatomic, assign) NSTimeInterval nextNotifyTime;

@end

@interface GFReviewManager : NSObject

+ (void)review;

@end
