//
//  GFLoginRegisterUpperView.h
//  GetFun
//
//  Created by liupeng on 15/11/14.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <UIKit/UIKit.h>


#define GF_LOGIN_HEIGHT_UPPERVIEW ((SCREEN_HEIGHT < 500.0f) ? 200 : (SCREEN_WIDTH * 300.0f / 375.0f))

@interface GFLoginRegisterUpperView : UIView

@property (nonatomic, strong) UIImageView *sloganImgView; //前景图

@end
