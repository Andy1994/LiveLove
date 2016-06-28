//
//  GFTakingPhotoViewController.m
//  GetFun
//
//  Created by zhouxz on 16/1/9.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFTakingPhotoViewController.h"
#import "GFCameraViewController.h"

@implementation GFTakingPhotoViewController

- (instancetype)init {
    GFCameraViewController *cameraViewController = [[GFCameraViewController alloc] init];
    if (self = [super initWithRootViewController:cameraViewController]) {
        [MobClick event:@"gf_tp_01_01_08_1"];
        _isCropAllowed = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

@end
