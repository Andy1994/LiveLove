//
//  GFImageGroupView.h
//  GetFun
//
//  Created by Liu Peng on 16/3/14.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFPictureMTL.h"

@protocol GFImageGroupDelegate <NSObject>
@optional
- (NSArray<UIView *> *)pictureViews;
@end


@interface GFImageGroupItem : NSObject
@property (nonatomic, strong) UIView *thumbView; ///< thumb image, used for animation position calculation
@property (nonatomic, assign) CGSize largeImageSize;
@property (nonatomic, strong) NSURL *largeImageURL;
@end


@interface GFImageGroupView : UIView
@property (nonatomic, readonly) NSArray<GFImageGroupItem *> *groupItems;
@property (nonatomic, readonly) NSInteger currentPage;
@property (nonatomic, assign) BOOL blurEffectBackground; ///< Default is YES
@property (nonatomic, weak) id<GFImageGroupDelegate> delegate;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithImages:(NSDictionary<NSString *, GFPictureMTL *> *)images orderKeys:(NSArray<NSString *> *)orderKeys initialKey:(NSString *)initialKey delegate:(id<GFImageGroupDelegate>)delegate;


- (void)presentToContainer:(UIView *)containerView animated:(BOOL)animated completion:(void (^)(void))completion;
- (void)dismissAnimated:(BOOL)animated completion:(void (^)(void))completion;
- (void)dismiss;

@end
