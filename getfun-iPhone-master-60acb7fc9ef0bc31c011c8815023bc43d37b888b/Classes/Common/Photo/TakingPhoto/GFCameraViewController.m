//
//  GFCameraViewController.m
//  GetFun
//
//  Created by zhouxz on 16/1/9.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFCameraViewController.h"
#import <FastttCamera.h>
#import "GFTakingPhotoViewController.h"
#import "GFCameraFunctionView.h"
#import "GFImageConfirmViewController.h"
#import "GFCroppingPhotoViewController.h"

@interface GFCameraViewController () <FastttCameraDelegate, GFCameraFunctionViewActionResponser,RSKImageCropViewControllerDelegate>

@property (nonatomic, strong) GFCameraFunctionView *cameraFunctionView;

@property (nonatomic, strong) FastttCamera *fastCamera;

@end

@implementation GFCameraViewController

- (GFCameraFunctionView *)cameraFunctionView {
    if (!_cameraFunctionView) {
        _cameraFunctionView = [[GFCameraFunctionView alloc] initWithFrame:self.view.bounds];
        _cameraFunctionView.delegate = self;
    }
    return _cameraFunctionView;
}

- (FastttCamera *)fastCamera {
    if (!_fastCamera) {
        _fastCamera = [[FastttCamera alloc] init];
        _fastCamera.delegate = self;
        _fastCamera.maxScaledDimension = 600.0f;
    }
    return _fastCamera;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    [self fastttAddChildViewController:self.fastCamera];
    self.fastCamera.view.backgroundColor = [UIColor blackColor];
    self.fastCamera.view.frame = CGRectMake(0, self.view.height == 480 ? 0 : 44, self.view.width, self.view.height == 480 ? self.view.height : ceilf(self.view.width / 3 * 4));
    
    [self.view addSubview:self.cameraFunctionView];
    [self.cameraFunctionView.photoButton addTarget:self.fastCamera action:@selector(takePicture) forControlEvents:UIControlEventTouchUpInside];
    self.cameraFunctionView.flashlightButton.hidden = [self.fastCamera isFlashAvailableForCurrentDevice];
    self.fastCamera.cameraFlashMode = FastttCameraFlashModeOff;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - IFTTTFastttCameraDelegate
- (void)cameraController:(id<FastttCameraInterface>)cameraController didFinishNormalizingCapturedImage:(FastttCapturedImage *)capturedImage {
    //  确定页面
    BOOL isCropAllowed = [(GFTakingPhotoViewController *)self.navigationController isCropAllowed];
    if (isCropAllowed) {
        GFCroppingPhotoViewController *croppingPhotoViewController = [[GFCroppingPhotoViewController alloc] initWithImage:capturedImage.fullImage cropMode:RSKImageCropModeSquare];
        croppingPhotoViewController.delegate = self;
        [self.navigationController pushViewController:croppingPhotoViewController animated:YES];
        
    } else {
        GFImageConfirmViewController *confirmViewController = [[GFImageConfirmViewController alloc] initWithImage:capturedImage.fullImage];
        [self.navigationController pushViewController:confirmViewController animated:YES];
    }
}

- (void)cameraController:(id<FastttCameraInterface>)cameraController didFinishCapturingImage:(FastttCapturedImage *)capturedImage {
    
}

#pragma mark - GFCameraFunctionViewActionResponser

- (void)cancelButtonTouched {
    
    GFTakingPhotoViewController *takingPhotoViewController = (GFTakingPhotoViewController *)self.navigationController;
    if (takingPhotoViewController.gf_didCancelTakingPhotoBlock) {
        takingPhotoViewController.gf_didCancelTakingPhotoBlock(takingPhotoViewController);
    }
    [takingPhotoViewController.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)flashlightButtonTouched {
    
    FastttCameraFlashMode flashMode;
    BOOL flashModeOn;
    switch (self.fastCamera.cameraFlashMode) {
        case FastttCameraFlashModeOn:
            flashMode = FastttCameraFlashModeOff;
            flashModeOn = NO;
            break;
        case FastttCameraFlashModeOff:
        default:
            flashMode = FastttCameraFlashModeOn;
            flashModeOn = YES;
            break;
    }
    if ([self.fastCamera isFlashAvailableForCurrentDevice]) {
        [self.fastCamera setCameraFlashMode:flashMode];
        [self.cameraFunctionView flashLightModeSwitched:flashModeOn];
    }
}

- (void)switchButtonTouched {
    
    FastttCameraDevice cameraDevice;
    switch (self.fastCamera.cameraDevice) {
        case FastttCameraDeviceFront: {
            cameraDevice = FastttCameraDeviceRear;
            break;
        }
        case FastttCameraDeviceRear:
        default:
            cameraDevice = FastttCameraDeviceFront;
            break;
    }
    if ([FastttCamera isCameraDeviceAvailable:cameraDevice]) {
        [self.fastCamera setCameraDevice:cameraDevice];
    }
}

#pragma mark - RSKImageCropViewControllerDelegate
- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage usingCropRect:(CGRect)cropRect {
    GFTakingPhotoViewController *nav = (GFTakingPhotoViewController *)self.navigationController;
    if (nav.gf_didFinishTakingPhotoBlock) {
        nav.gf_didFinishTakingPhotoBlock(nav, croppedImage);
    }
    if (nav.presentingViewController) {
        [nav.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    }
}

@end
