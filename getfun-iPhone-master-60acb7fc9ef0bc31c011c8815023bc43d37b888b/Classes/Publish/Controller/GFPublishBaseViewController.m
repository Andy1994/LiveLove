//
//  GFPublishBaseViewController.m
//  GetFun
//
//  Created by zhouxz on 15/11/28.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFPublishBaseViewController.h"
#import "GFGroupSelectViewController.h"
#import "GFMapPoiSelectViewController.h"
#import "GFTakingPhotoViewController.h"
#import "GFAssetsPickerViewController.h"
#import "GFPublishArticleViewController.h"
#import "GFPublishPhotoViewController.h"
#import "GFPublishLinkViewController.h"
#import "GFPublishVoteViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "GFCacheUtil.h"
#import "GFPhotoUtil.h"

#define GF_PUBLISH_IMAGE_PERSISTENT_FOLDER @"publishImages"
static const NSInteger kMaxPhotoCount = 20; //可选图片最大数目

@interface GFPublishBaseViewController ()

@property (nonatomic, strong) GFPublishOptionView *publishOptionView;

@property (nonatomic, strong, readwrite) AMapPOI *currentPOI;
@property (nonatomic, strong, readwrite) GFGroupMTL *selectedGroup;
@property (nonatomic, strong, readwrite) GFTagMTL *tag;
@end

@implementation GFPublishBaseViewController
- (GFPublishOptionView *)publishOptionView {
    if (!_publishOptionView) {
        _publishOptionView = [GFPublishOptionView publishOptionView];
        _publishOptionView.y = self.view.height-_publishOptionView.height;
    }
    return _publishOptionView;
}

- (instancetype)initWithKeyFrom:(GFPublishKeyFrom)keyFrom {
    if (self = [super init]) {
        _keyFrom = keyFrom;
    }
    return self;
}

- (instancetype)initWithSelectedGroup:(GFGroupMTL *)group {
    if (self = [super init]) {
        _selectedGroup = group;
        _keyFrom = GFPublishKeyFromGroup;
    }
    return self;
}

- (instancetype)initWithTag:(GFTagMTL *)tag keyFrom:(GFPublishKeyFrom)keyFrom{
    if (self = [super init]) {
        _tag = tag;
        _keyFrom = keyFrom;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.backBarButtonItemStyle = GFBackBarButtonItemStyleCloseDark;
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem gf_barButtonItemWithImage:[UIImage imageNamed:@"nav_send"] target:self selector:@selector(sendBarButtonItemSelected)];
    
    [self.view addSubview:self.publishOptionView];
    if ([self isKindOfClass:[GFPublishLinkViewController class]] ||
        [self isKindOfClass:[GFPublishVoteViewController class]] ||
        [self isKindOfClass:[GFPublishPhotoViewController class]]) {
        self.publishOptionView.style ^= GFPublishOptionStylePhoto;
    }
    
    __weak typeof(self) weakSelf = self;
    self.publishOptionView.publishOptionHandler = ^(GFPublishOptionAction action) {
        [weakSelf.view endEditing:YES];
        [weakSelf handlePublishOptionAction:action];
    };
    
    BOOL autoLocatingForbidden = [GFUserDefaultsUtil boolForKey:GFUserDefaultsKeyForbiddenAutoLocatingWhenPublish];
    if (!autoLocatingForbidden) {
        [GFLocationManager startUpdateLocationSuccess:^(CLLocation *location, AMapLocationReGeocode *regeocode) {
            [GFLocationManager addressAroundLocation:location
                                             keyword:nil
                                             success:^(AMapPOISearchResponse *result) {
                                                 if ([result.pois count] > 0) {
                                                     AMapPOI *poi = [result.pois firstObject];
                                                     weakSelf.currentPOI = poi;
                                                     weakSelf.publishOptionView.address = poi.name;
                                                 }
                                             } failure:^{
                                                 //
                                             }];
        } failure:^(NSError *error) {
            
        }];
    }
}

- (void)dealloc {
    [_publishOptionView removeFromSuperview];
    _publishOptionView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.view bringSubviewToFront:self.publishOptionView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardFrameChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)setTitle:(NSString *)title {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = title;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:19];
    titleLabel.textColor = [UIColor textColorValue1];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
}

- (void)backBarButtonItemSelected {
    
    [self.view endEditing:YES];
    
    if ([self isKindOfClass:[GFPublishArticleViewController class]]) {
        [MobClick event:@"gf_fb_02_01_05_1"];
    } else if ([self isKindOfClass:[GFPublishLinkViewController class]]) {
        [MobClick event:@"gf_fb_01_01_05_1"];
    } else if ([self isKindOfClass:[GFPublishVoteViewController class]]) {
        [MobClick event:@"gf_fb_03_01_06_1"];
    }
    
    [super backBarButtonItemSelected];
}

- (void)sendBarButtonItemSelected {
    
    if ([self isKindOfClass:[GFPublishArticleViewController class]]) {
        [MobClick event:@"gf_fb_02_01_06_1"];
    } else if ([self isKindOfClass:[GFPublishLinkViewController class]]) {
        [MobClick event:@"gf_fb_01_01_06_1"];
    } else if ([self isKindOfClass:[GFPublishVoteViewController class]]) {
        [MobClick event:@"gf_fb_03_01_07_1"];
    }
    
    [self.view endEditing:YES];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)handlePublishOptionAction:(GFPublishOptionAction)action {
    __weak typeof(self) weakSelf = self;
    switch (action) {
        case GFPublishOptionActionAddress: {
            
            if ([self isKindOfClass:[GFPublishArticleViewController class]]) {
                [MobClick event:@"gf_fb_02_01_04_1"];
            } else if ([self isKindOfClass:[GFPublishLinkViewController class]]) {
                [MobClick event:@"gf_fb_01_01_04_1"];
            } else if ([self isKindOfClass:[GFPublishVoteViewController class]]) {
                
            }else if([self isKindOfClass:[GFPublishPhotoViewController class]]) {
                switch (self.keyFrom) {
                    case GFPublishKeyFromHome: {
                        [MobClick event:@"gf_fb_06_01_02_1"];
                        break;
                    }
                    case GFPublishKeyFromTagTopic: {
                        [MobClick event:@"gf_bq_02_05_03_1"];
                        break;
                    }
                    case GFPublishKeyFromTagNoTopic: {
                        [MobClick event:@"gf_bq_02_06_02_1"];
                        break;
                    }
                    case GFPublishKeyFromGroup: {
                        break;
                    }
                }
            }
            
            GFMapPoiSelectViewController *map = [[GFMapPoiSelectViewController alloc] init];
            map.mapPoiSelectHandler = ^(AMapPOI *poi) {
                weakSelf.currentPOI = poi;
                if (poi) {
                    weakSelf.publishOptionView.address = poi.name;
                } else {
                    weakSelf.publishOptionView.address = @"不显示地理位置";
                }
            };
            [self.navigationController pushViewController:map animated:YES];
            break;
        }
        case GFPublishOptionActionPhoto: {
            
            if ([self isKindOfClass:[GFPublishArticleViewController class]]) {
                [MobClick event:@"gf_fb_02_01_07_1"];
            } else if ([self isKindOfClass:[GFPublishLinkViewController class]]) {
                
            } else if ([self isKindOfClass:[GFPublishVoteViewController class]]) {
                
            }else if([self isKindOfClass:[GFPublishPhotoViewController class]]) {
                switch (self.keyFrom) {
                    case GFPublishKeyFromHome: {
                        [MobClick event:@"gf_fb_06_01_05_1"];
                        break;
                    }
                    case GFPublishKeyFromTagTopic: {
                        [MobClick event:@"gf_bq_02_05_06_1"];
                        break;
                    }
                    case GFPublishKeyFromTagNoTopic: {
                        [MobClick event:@"gf_bq_02_06_05_1"];
                        break;
                    }
                    case GFPublishKeyFromGroup: {
                        break;
                    }
                }
            }
            
            [weakSelf showImagePickerViewController];
            
            break;
        }
    }
}

- (NSString *)fixSandboxFilePath:(NSString *)fakeSandBoxPath {
    
    //    /var/mobile/Containers/Data/Application/33929570-8805-4CC4-8B8F-381519FFE0E8/Library/Caches/com.getfun.GetFun/publishImages/68ab278cd0bf97450dd7c12938c61d6d
    NSArray *components = [fakeSandBoxPath componentsSeparatedByString:@"com.getfun.GetFun"];
    NSString *lastPartPath = [components lastObject];
    NSString *fixPath = [[GFCacheUtil gf_persistentPath] stringByAppendingPathComponent:lastPartPath];
    return fixPath;
}

- (void)showImagePickerViewController {
    UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:@"选择图片"];
    // 拍照
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        GFTakingPhotoViewController *takingPhotoViewController = [[GFTakingPhotoViewController alloc] init];
        takingPhotoViewController.isCropAllowed = ([self isKindOfClass:[GFPublishVoteViewController class]]);
        takingPhotoViewController.gf_didFinishTakingPhotoBlock = ^(GFTakingPhotoViewController *controller, UIImage *image) {
            NSString *path = [self cacheImage:image];
            [self handleSelectImage:image path:path];
        };
        takingPhotoViewController.gf_didCancelTakingPhotoBlock = ^(GFTakingPhotoViewController *controller) {
            [self handleCancelSelectImage];
        };
        
        [actionSheet bk_addButtonWithTitle:@"拍照" handler:^{
            [self presentViewController:takingPhotoViewController animated:YES completion:NULL];
        }];
    }
    
    // 相册上传
    [actionSheet bk_addButtonWithTitle:@"从相册上传" handler:^{
        
        [GFPhotoUtil checkAuthorizationCompletion:^(BOOL authorized) {
            if (authorized) {
                GFAssetsPickerViewController *assetsPickerViewController = [[GFAssetsPickerViewController alloc] init];
                if ([self isKindOfClass:[GFPublishPhotoViewController class]]) {
                    assetsPickerViewController.maxSelectNumber = kMaxPhotoCount - self.currentSelectedPhotoCount;
                } if ([self isKindOfClass:[GFPublishArticleViewController class]]) {
                    assetsPickerViewController.maxSelectNumber = kMaxPhotoCount;
                }
                
                if ([self isKindOfClass:[GFPublishVoteViewController class]]) {
                    //PK帖需要图片裁剪，需要进行判断
                    assetsPickerViewController.isCropAllowed = YES;
                }

                assetsPickerViewController.gf_didFinishPickingImageBlock = ^(GFAssetsPickerViewController *picker, UIImage *image, UIImage *thumbnail) {
                    if ([self isKindOfClass:[GFPublishVoteViewController class]]) {
                        image = [image gf_imageByScalingAndCroppingForSize:CGSizeMake(320, 320)];
                    } else {
                        image = [image gf_imageByScalingAndCroppingForSize:CGSizeMake(640, image.size.height/image.size.width * 640)];
                    }

                    NSString *path = [self cacheImage:image];
                    [self handleSelectImage:thumbnail path:path];
                };
                assetsPickerViewController.gf_didFinishPickingAssetsBlock = ^(GFAssetsPickerViewController *picker, NSArray *assets, NSArray *thumbnails) {
                    [self handleSelectAssets:assets thumbnails:thumbnails];
                };
                
                assetsPickerViewController.gf_didCancelPickingAssetsBlock = ^(GFAssetsPickerViewController *picker) {
                    [self handleCancelSelectImage];
                };
                
                [self presentViewController:assetsPickerViewController animated:YES completion:NULL];
            }
        }];
    }];
    
    [actionSheet bk_setCancelButtonWithTitle:@"取消" handler:^{
        
    }];
    
    [actionSheet showInView:self.view];
}

- (NSString *)cacheImage:(UIImage *)image {
    
    NSString *path = [GFCacheUtil gf_persistentPath];
    path = [path stringByAppendingPathComponent:GF_PUBLISH_IMAGE_PERSISTENT_FOLDER];

    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSData *data = UIImageJPEGRepresentation(image, 1.0f);
    NSString *file = [data md5String];
    path = [path stringByAppendingPathComponent:file];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [data writeToFile:path options:NSDataWritingWithoutOverwriting error:nil];
    });

    return path;
}

- (void)handleSelectImage:(UIImage *)image path:(NSString *)path {

}

- (void)handleSelectAssets:(NSArray *)assets thumbnails:(NSArray *)thumbnails {
    [self handleAssetAtIndex:0 assets:assets thumbnails:thumbnails];
}

- (void)handleAssetAtIndex:(NSInteger)index assets:(NSArray *)assets thumbnails:(NSArray *)thumbnails {
    
    if (index >= [assets count]) return;
    
    id asset = [assets objectAtIndex:index];
    UIImage *thumbnail = [thumbnails objectAtIndex:index];
    [GFPhotoUtil originalPhotoWithAsset:asset completion:^(UIImage *photo, NSDictionary *info) {

        NSString *path = [self cacheImage:photo];
        [self handleSelectImage:thumbnail path:path];
        [self handleAssetAtIndex:index + 1 assets:assets thumbnails:thumbnails];
    }];
}

- (void)handleCancelSelectImage {

}

#pragma mark - KeyboardNotification
- (void)onKeyboardFrameChange:(NSNotification *)notification {
    NSValue *endFrameValue = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect endFrame = [endFrameValue CGRectValue];
    CGFloat endY = endFrame.origin.y;
    
    [UIView animateWithDuration:.5 animations:^{
        self.publishOptionView.bottom = endY;
    }];
}
@end
