//
//  GFChangeNickNameViewController.h
//  GetFun
//
//  Created by zhouxz on 15/12/11.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFBaseViewController.h"
typedef void(^Completion)();


@interface GFChangeNickNameViewController : GFBaseViewController

@property (nonatomic, copy) void(^nickNameChangeHandler)(NSString *nickName, Completion completion);

@end
