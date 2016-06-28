//
//  GFUnreadCountMTL.m
//  GetFun
//
//  Created by zhouxz on 16/1/26.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFUnreadCountMTL.h"

@implementation GFUnreadCountMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"participate" : @"PARTICIPATE_MSG",
             @"fun" : @"FUN_MSG",
             @"audit" : @"AUDIT_MSG",
             @"comment" : @"COMMENT_MSG"
             };
}

@end
