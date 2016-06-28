//
//  GFGroupQRCodeViewController.m
//  GetFun
//
//  Created by Liu Peng on 15/12/9.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFGroupQRCodeViewController.h"
#import "GFNetworkManager+QRCode.h"
#import "GFAccountManager.h"
#import "GFGroupMTL.h"

@interface GFGroupQRCodeViewController ()

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIImageView *frameImageView;
@property (nonatomic, strong) UIImageView *QRCodeImageView;
@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) GFGroupMTL *group;
@property (nonatomic, strong) UIImage *avatarImage;

@end

@implementation GFGroupQRCodeViewController
- (UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _backgroundImageView.image = [self.avatarImage gaussianBlurWithBias:150.0f];
        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        _backgroundImageView.clipsToBounds = YES;
    }
    return _backgroundImageView;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:self.view.bounds];
        _maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    }
    return _maskView;
}

- (UIImageView *)frameImageView {
    if (!_frameImageView) {
        _frameImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.width - 281.0f)/2,
                                                                        100.0f,
                                                                        281.0f,
                                                                        355.0f)];
        UIImage *frameImage = [UIImage imageNamed:@"group_qr_frame"];
        _frameImageView.image = [frameImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 20, 150, 20) resizingMode:UIImageResizingModeStretch];
    }
    return _frameImageView;
}

- (UIImageView *)QRCodeImageView {
    if (!_QRCodeImageView) {
        const CGFloat size = 180.0f;
        _QRCodeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.width / 2 - size / 2,
                                                                         150,
                                                                         size,
                                                                         size)];
    }
    return _QRCodeImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.QRCodeImageView.bottom + 40.0f, self.view.width, 20)];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.text = self.group.groupInfo.name;
        _nameLabel.font = [UIFont systemFontOfSize:17.0f];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}

- (instancetype)initWithGroup:(GFGroupMTL *)group avatarImage:(UIImage *)image {
    if (self = [super init]) {
        self.group = group;
        self.avatarImage = image;
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.backBarButtonItemStyle = GFBackBarButtonItemStyleBackLight;
    self.gf_StatusBarStyle = UIStatusBarStyleLightContent;
    
    [self.view addSubview:self.backgroundImageView];
    [self.view addSubview:self.maskView];
    [self.view addSubview:self.frameImageView];
    [self.view addSubview:self.QRCodeImageView];
    [self.view addSubview:self.nameLabel];
    
    self.title = @"本帮二维码";
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];

    [self gf_setNavBarBackgroundTransparent:0.0f];
    
    //查询内容
    [self queryQRCodeImage];
}

- (void)backBarButtonItemSelected {
    [MobClick event:@"gf_gb_06_01_02_1"];
    [super backBarButtonItemSelected];
}

- (void)queryQRCodeImage {
    
    NSString *groupId = [NSString stringWithFormat:@"%@", self.group.groupInfo.groupId];
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager getQRCodeImageWithType:GFQRCodeTypeGroup
                                     content:groupId
                                     success:^(NSUInteger taskId, NSInteger code, NSString *imgUrl, NSString *errorMessage) {
                                         if (imgUrl && [imgUrl length] > 0) {
#warning 图片裁剪标准未确定
                                             NSString *url = [imgUrl gf_urlAppendWithHorizontalEdge:weakSelf.QRCodeImageView.width verticalEdge:weakSelf.QRCodeImageView.height mode:GFImageProcessModeMinWidthMinHeightCut];
                                             [weakSelf.QRCodeImageView setImageWithURL:[NSURL URLWithString:url] placeholder:nil];
                                             [weakSelf enableSaveButton];
                                         }
                                     } failure:^(NSUInteger taskId, NSError *error) {
                                         
                                     }];
}

- (void)enableSaveButton {
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    saveButton.frame = CGRectMake(0, 0, 34, 34);
    [saveButton setBackgroundImage:[UIImage imageNamed:@"group_qrcode_download"] forState:UIControlStateNormal];
    __weak typeof(self) weakSelf =self;
    [saveButton bk_addEventHandler:^(id sender) {

        [MobClick event:@"gf_gb_06_01_01_1"];
        UIImage *qrCodeImage = weakSelf.QRCodeImageView.image;
        if (qrCodeImage) {
            UIImageWriteToSavedPhotosAlbum(qrCodeImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }

    } forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    if (error) {
        [MBProgressHUD showHUDWithTitle:@"保存失败" duration:kCommonHudDuration inView:self.view];
    } else {
        [MBProgressHUD showHUDWithTitle:@"已保存" duration:kCommonHudDuration inView:self.view];
    }
}
@end
