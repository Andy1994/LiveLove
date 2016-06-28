//
//  GFPublishBaseViewController.h
//  GetFun
//
//  Created by zhouxz on 15/11/28.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFBaseViewController.h"
#import "GFPublishOptionView.h"
#import "GFLocationManager.h"
#import <DTRichTextEditor/DTRichTextEditor.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "GFGroupMTL.h"

//记录从哪个视图唤起的发布操作，便于统计
typedef NS_ENUM(NSUInteger, GFPublishKeyFrom) {
    GFPublishKeyFromHome, //首页发布发布
    GFPublishKeyFromTagTopic, //标签详情页发布，有话头
    GFPublishKeyFromTagNoTopic, //标签详情页发布，无话头
    GFPublishKeyFromGroup, //get帮详情页发布
};

@interface GFPublishBaseViewController : GFBaseViewController

@property (nonatomic, strong, readonly) GFPublishOptionView *publishOptionView;
@property (nonatomic, strong, readonly) AMapPOI *currentPOI;
@property (nonatomic, strong, readonly) GFGroupMTL *selectedGroup;
@property (nonatomic, strong, readonly) GFTagMTL *tag;
@property (nonatomic, assign) GFPublishKeyFrom keyFrom;
@property (nonatomic, assign) NSUInteger currentSelectedPhotoCount;

- (instancetype)initWithSelectedGroup:(GFGroupMTL *)group;
- (instancetype)initWithTag:(GFTagMTL *)tag keyFrom:(GFPublishKeyFrom)keyFrom;
- (instancetype)initWithKeyFrom:(GFPublishKeyFrom)keyFrom;

- (NSString *)fixSandboxFilePath:(NSString *)fakeSandBoxPath;
- (void)showImagePickerViewController;
- (void)sendBarButtonItemSelected;

- (void)handleSelectImage:(UIImage *)image path:(NSString *)path;
- (void)handleSelectAssets:(NSArray *)assets thumbnails:(NSArray *)thumbnails;
- (void)handleCancelSelectImage;

@end
