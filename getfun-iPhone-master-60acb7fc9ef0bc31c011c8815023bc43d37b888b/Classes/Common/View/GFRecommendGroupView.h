//
//  GFRecommendGroupView.h
//  GetFun
//
//  Created by Liu Peng on 15/12/1.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFGroupMTL.h"

@interface GFRecommendGroupView : UIView

@property (nonatomic, strong) GFGroupMTL *group;

@property (nonatomic, assign) BOOL distanceVisible;
@property (nonatomic, assign) BOOL locationVisible;
@property (nonatomic, assign) BOOL topBorderVisible;

+ (CGFloat)groupItemViewHeight;

@end
