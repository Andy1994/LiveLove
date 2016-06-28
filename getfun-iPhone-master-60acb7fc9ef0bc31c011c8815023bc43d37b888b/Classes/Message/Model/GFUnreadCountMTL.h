//
//  GFUnreadCountMTL.h
//  GetFun
//
//  Created by zhouxz on 16/1/26.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface GFUnreadCountMTL : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign) NSUInteger participate;
@property (nonatomic, assign) NSUInteger fun;
@property (nonatomic, assign) NSUInteger audit;
@property (nonatomic, assign) NSUInteger comment;

@end
