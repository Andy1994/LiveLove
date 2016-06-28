//
//  GFContentInfoFooter.h
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/17.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFContentMTL.h"

@interface GFContentInfoFooter : UIView

+ (CGFloat)heightWithContent:(GFContentMTL *)content;
- (void)updateWithContent:(GFContentMTL *)content;

@end
