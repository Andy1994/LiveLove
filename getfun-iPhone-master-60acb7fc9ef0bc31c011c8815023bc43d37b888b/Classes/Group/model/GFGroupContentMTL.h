//
//  GFGroupContentMTL.h
//  GetFun
//
//  Created by Liu Peng on 15/12/2.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "GFUserMTL.h"
#import "GFContentMTL.h"

@interface GFGroupContentMTL : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) GFUserMTL *user;
@property (nonatomic, strong) GFContentMTL *content;
@property (nonatomic, assign) GFUserAction action;

@end
