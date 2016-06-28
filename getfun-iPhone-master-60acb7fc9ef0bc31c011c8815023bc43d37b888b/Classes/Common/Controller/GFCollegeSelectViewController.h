//
//  GFCollegeSelectViewController.h
//  GetFun
//
//  Created by zhouxz on 15/12/12.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFBaseViewController.h"
#import "GFCollegeMTL.h"

@interface GFCollegeSelectViewController : GFBaseViewController

/**
 *  如果为null，则自动获取用户设置
 */
@property (nonatomic, strong) NSNumber *provinceId;

@property (nonatomic, copy) void(^collegeSelectHandler)(GFCollegeMTL * college);

@end