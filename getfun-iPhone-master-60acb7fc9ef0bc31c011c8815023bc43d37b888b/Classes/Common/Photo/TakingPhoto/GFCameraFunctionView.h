//
//  GFCameraFunctionView.h
//  GetFun
//
//  Created by Meng on 16/1/21.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GFCameraFunctionViewActionResponser <NSObject>

- (void)cancelButtonTouched;
- (void)flashlightButtonTouched;
- (void)switchButtonTouched;

@end

@interface GFCameraFunctionView : UIView

@property (nonatomic, assign) id<GFCameraFunctionViewActionResponser> delegate;

@property (nonatomic, strong) UIButton *photoButton;
@property (nonatomic, strong) UIButton *flashlightButton;

- (void)flashLightModeSwitched:(BOOL)flashModeOn;

@end
