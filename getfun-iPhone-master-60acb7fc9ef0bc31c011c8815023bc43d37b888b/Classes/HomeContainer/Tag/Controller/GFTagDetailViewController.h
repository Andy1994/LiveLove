//
//  GFTagDetailViewController.h
//  GetFun
//
//  Created by liupeng on 15/11/29.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFBaseViewController.h"

@class GFTagMTL;

@interface GFTagDetailViewController : GFBaseViewController

- (instancetype)initWithTagId:(NSNumber *)tagId;

//关注和取消关注回调
@property (nonatomic, copy) void(^tagCollectHandler)(GFTagMTL *tagMTL);

@end
