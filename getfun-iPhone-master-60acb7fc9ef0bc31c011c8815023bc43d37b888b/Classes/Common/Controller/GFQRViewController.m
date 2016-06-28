//
//  GFQRViewController.m
//  GetFun
//
//  Created by zhouxz on 15/11/28.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFQRViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "BlocksKit+UIKit.h"
#import <DTCoreText/DTCoreText.h>
#import "AppDelegate.h"

#define GF_PUBLISH_ADVANCE_SCANNER_SIZE 240.0f
#define GF_SCANNER_FRAME CGRectMake((SCREEN_WIDTH-GF_PUBLISH_ADVANCE_SCANNER_SIZE)/2,\
                                    (SCREEN_HEIGHT-GF_PUBLISH_ADVANCE_SCANNER_SIZE)/2-44,\
                                    GF_PUBLISH_ADVANCE_SCANNER_SIZE,\
                                    GF_PUBLISH_ADVANCE_SCANNER_SIZE)

@interface GFQRViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preview;

@end


@implementation GFQRViewController

- (AVCaptureDevice *)device {
    if (!_device) {
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return _device;
}

- (AVCaptureDeviceInput *)input {
    if (!_input) {
        _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    }
    return _input;
}

- (AVCaptureMetadataOutput *)output {
    if (!_output) {
        _output = [[AVCaptureMetadataOutput alloc] init];
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];

    }
    return _output;
}

- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
        
        if ([_session canAddInput:self.input]) {
            [_session addInput:self.input];
        }
        
        if ([_session canAddOutput:self.output]) {
            [_session addOutput:self.output];
        }
        self.output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
    }
    return _session;
}

- (AVCaptureVideoPreviewLayer *)preview {
    if (!_preview) {
        _preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _preview.frame = self.view.bounds;
    }
    return _preview;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.backBarButtonItemStyle = GFBackBarButtonItemStyleCloseLight;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = @"扫一扫";
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    self.navigationItem.titleView = label;
    
    [self.view.layer insertSublayer:self.preview atIndex:0];
    
    self.gf_StatusBarStyle = UIStatusBarStyleLightContent;
    [self setupOverlayView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self gf_setNavBarBackgroundTransparent:0.0f];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.session startRunning];
}

- (void)setupOverlayView {
    UIView *topOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, CGRectGetMinY(GF_SCANNER_FRAME))];
    topOverlay.backgroundColor = [UIColor blackColor];
    topOverlay.alpha = 0.6f;
    [self.view addSubview:topOverlay];
    
    UIView *bottomOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(GF_SCANNER_FRAME), self.view.width, self.view.height-CGRectGetMaxY(GF_SCANNER_FRAME))];
    bottomOverlay.backgroundColor = [UIColor blackColor];
    bottomOverlay.alpha = 0.6f;
    [self.view addSubview:bottomOverlay];
    
    UIView *leftOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(GF_SCANNER_FRAME), CGRectGetMinX(GF_SCANNER_FRAME), CGRectGetHeight(GF_SCANNER_FRAME))];
    leftOverlay.backgroundColor = [UIColor blackColor];
    leftOverlay.alpha = 0.6f;
    [self.view addSubview:leftOverlay];
    
    UIView *rightOverlay = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(GF_SCANNER_FRAME), CGRectGetMinY(GF_SCANNER_FRAME), self.view.width - CGRectGetMaxX(GF_SCANNER_FRAME), CGRectGetHeight(GF_SCANNER_FRAME))];
    rightOverlay.backgroundColor = [UIColor blackColor];
    rightOverlay.alpha = 0.6f;
    [self.view addSubview:rightOverlay];
    
    UIImageView *topLeftImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qr_scanner_topleft"]];
    [topLeftImageView sizeToFit];
    topLeftImageView.x = CGRectGetMinX(GF_SCANNER_FRAME) - 2.0f;
    topLeftImageView.y = CGRectGetMinY(GF_SCANNER_FRAME) - 2.0f;
    [self.view addSubview:topLeftImageView];
    
    UIImageView *topRightImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qr_scanner_topright"]];
    [topRightImageView sizeToFit];
    topRightImageView.right = CGRectGetMaxX(GF_SCANNER_FRAME) + 2.0f;
    topRightImageView.y = CGRectGetMinY(GF_SCANNER_FRAME) - 2.0f;
    [self.view addSubview:topRightImageView];
    
    UIImageView *bottomLeftImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qr_scanner_bottomleft"]];
    [bottomLeftImageView sizeToFit];
    bottomLeftImageView.x = CGRectGetMinX(GF_SCANNER_FRAME) - 2.0f;
    bottomLeftImageView.bottom = CGRectGetMaxY(GF_SCANNER_FRAME) + 2.0f;
    [self.view addSubview:bottomLeftImageView];
    
    UIImageView *bottomRightImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qr_scanner_bottomright"]];
    [bottomRightImageView sizeToFit];
    bottomRightImageView.right = CGRectGetMaxX(GF_SCANNER_FRAME) + 2.0f;
    bottomRightImageView.bottom = CGRectGetMaxY(GF_SCANNER_FRAME) + 2.0f;
    [self.view addSubview:bottomRightImageView];
    
    UIImageView *tipImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qr_tips"]];
    [tipImageView sizeToFit];
    tipImageView.y = CGRectGetMaxY(GF_SCANNER_FRAME) + 20.0f;
    tipImageView.centerX = CGRectGetMidX(GF_SCANNER_FRAME);
    [self.view addSubview:tipImageView];
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    if ([metadataObjects count] >0) {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
            NSString *stringValue = metadataObject.stringValue;
        [self.session stopRunning];
        [self dismissViewControllerAnimated:YES completion:^{
            [[AppDelegate appDelegate] handleGetfunLinkUrl:stringValue];
        }];
    }
}

@end
