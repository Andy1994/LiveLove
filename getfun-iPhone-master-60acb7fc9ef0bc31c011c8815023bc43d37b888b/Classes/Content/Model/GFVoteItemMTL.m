//
//  GFVoteItemMTL.m
//  GetFun
//
//  Created by zhouxz on 15/11/16.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFVoteItemMTL.h"

@implementation GFVoteItemMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"contentId" : @"contentId",
             @"voteItemId" : @"id",
             @"imageUrl" : @"imageUrl",
             @"supportCount" : @"supportCount",
             @"title" : @"title"
             };
}

- (NSString *)title {
    return [_title stringByReplacingHTMLEntities];
}

@end
