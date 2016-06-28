//
//  GFProfileViewController.h
//  GetFun
//
//  Created by zhouxz on 15/12/7.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFBaseViewController.h"

@interface GFProfileViewController : GFBaseViewController

- (instancetype)initWithUserID:(NSNumber *)userID;

@property (nonatomic, strong, readonly) NSNumber *iniUserID;

@end
