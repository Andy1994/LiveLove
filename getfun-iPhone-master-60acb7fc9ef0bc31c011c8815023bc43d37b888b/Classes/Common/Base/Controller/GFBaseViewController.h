//
//  GFBaseViewController.h
//  GetFun
//
//  Created by muhuaxin on 15/11/12.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, GFBackBarButtonItemStyle) {
    GFBackBarButtonItemStyleNone        = 0,
    GFBackBarButtonItemStyleBackDark    = 1,
    GFBackBarButtonItemStyleBackLight   = 2,
    GFBackBarButtonItemStyleCloseDark   = 3,
    GFBackBarButtonItemStyleCloseLight  = 4
};

@interface GFBaseViewController : UIViewController


@property (nonatomic, assign) BOOL gf_StatusBarHidden;
@property (nonatomic, assign) UIStatusBarStyle gf_StatusBarStyle;
/**
 *  设置返回按钮的样式. 如果不是返回按钮，需要在特定的viewcontroller里自行设置
 */
@property (nonatomic, assign) GFBackBarButtonItemStyle backBarButtonItemStyle;

- (void)hideFooterImageView:(BOOL)hide;
- (void)backBarButtonItemSelected;
- (void)gf_setNavBarBackgroundTransparent:(CGFloat)alpha;

- (void)gf_setNavBarShrink:(BOOL)shrink;

@end
