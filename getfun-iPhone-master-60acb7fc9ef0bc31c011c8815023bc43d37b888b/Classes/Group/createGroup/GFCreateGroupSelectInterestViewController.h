//
//  GFCreateGroupSelectInterestViewController.h
//  GetFun
//
//  Created by Liu Peng on 15/12/9.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFBaseViewController.h"
#import "GFTagMTL.h"

@interface GFCreateGroupSelectInterestViewController : GFBaseViewController

@property (nonatomic, copy) void (^interestSelectHandler)(GFTagInfoMTL *tag);
@end
