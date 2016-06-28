//
//  GFPublishOptionView.m
//  GetFun
//
//  Created by zhouxz on 15/12/9.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#define GFLocationChoseImage @"location2"

#import "GFPublishOptionView.h"
#import "GFGroupMTL.h"

@interface GFPublishOptionView ()

@property (nonatomic, strong) UIButton *addressButton;
@property (nonatomic, strong) UIButton *photoButton;

@end

@implementation GFPublishOptionView
- (void)setStyle:(GFPublishOptionStyle)style {
    _style = style;
    self.addressButton.hidden = !(style & GFPublishOptionStyleAddress);
    self.photoButton.hidden = !(style & GFPublishOptionStylePhoto);
}

- (void)setAddress:(NSString *)address {
    _address = address ? address : @"选择当前位置";
    [self.addressButton setTitle:_address forState:UIControlStateNormal];
    if (![self.address isEqualToString:@"不显示地理位置"] && ![self.address isEqualToString:@"选择当前位置"]) {
        [self.addressButton setImage:[UIImage imageNamed:GFLocationChoseImage] forState:UIControlStateNormal];
    } else {
        [self.addressButton setImage:[UIImage imageNamed:@"icon_location5"] forState:UIControlStateNormal];
    }
    [self.addressButton sizeToFit];
    self.addressButton.frame = CGRectMake(15, 0, _addressButton.width, self.height);
}

- (UIButton *)addressButton {
    if (!_addressButton) {
        _addressButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addressButton setImage:[UIImage imageNamed:@"icon_location5"] forState:UIControlStateNormal];
        [_addressButton setTitle:@"选择当前位置" forState:UIControlStateNormal];
        _addressButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [_addressButton setTitleColor:[UIColor textColorValue3] forState:UIControlStateNormal];
        [_addressButton sizeToFit];
        _addressButton.frame = CGRectMake(15, 0, _addressButton.width, self.height);
    }
    return _addressButton;
}

- (UIButton *)photoButton {
    if (!_photoButton) {
        _photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        const CGFloat height = 44.0f;
        _photoButton.frame = CGRectMake(self.width-15-height,
                                        self.height/2-height/2,
                                        height,
                                        height);
        UIImage *img = [UIImage imageNamed:@"input_camera"];
        _photoButton.contentMode = UIViewContentModeCenter;
        [_photoButton setImage:img forState:UIControlStateNormal];
        [_photoButton setImage:[img opacity:0.5f] forState:UIControlStateHighlighted];
    }
    return _photoButton;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self gf_AddTopBorderWithColor:[[UIColor gf_colorWithHex:@"cccccc"] colorWithAlphaComponent:0.5f] andWidth:0.5f];
        
        self.style = GFPublishOptionStyleAll;
        [self addSubview:self.addressButton];
        [self addSubview:self.photoButton];
        
        __weak typeof(self) weakSelf = self;
        [self.addressButton bk_addEventHandler:^(id sender) {
            if (weakSelf.publishOptionHandler) {
                weakSelf.publishOptionHandler(GFPublishOptionActionAddress);
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
        [self.photoButton bk_addEventHandler:^(id sender) {
            if (weakSelf.publishOptionHandler) {
                weakSelf.publishOptionHandler(GFPublishOptionActionPhoto);
            }
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

+ (instancetype)publishOptionView {
    GFPublishOptionView *publishOptionView = [[GFPublishOptionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kPublishOptionViewHeight)];
    return publishOptionView;
}

@end
