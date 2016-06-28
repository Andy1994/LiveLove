//
//  GFVoteItemMTL.h
//  GetFun
//
//  Created by zhouxz on 15/11/16.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface GFVoteItemMTL : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSNumber *contentId;
@property (nonatomic, strong) NSNumber *voteItemId;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, strong) NSNumber *supportCount;
@property (nonatomic, copy) NSString *title;

@end
