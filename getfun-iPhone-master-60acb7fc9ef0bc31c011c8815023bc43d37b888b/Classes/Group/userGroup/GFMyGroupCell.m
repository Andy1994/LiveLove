//
//  GFMyGroupCell.M
//  GetFun
//
//  Created by Liu Peng on 15/12/15.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFMyGroupCell.h"
#import "GFGroupMTL.h"
#import <UIImage+DTFoundation.h>

@interface GFMyGroupCell ()

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *checkinButton;
@property (nonatomic, strong) UIImageView *accessoryImageView;
@property (nonatomic, strong) CALayer *bottomBorder;

@end

@implementation GFMyGroupCell
- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _avatarImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.font = [UIFont systemFontOfSize:17];
        _nameLabel.textColor = [UIColor textColorValue1];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _nameLabel;
}

- (UIButton *)checkinButton {
    if (!_checkinButton) {
        _checkinButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_checkinButton setTitle:@"签到" forState:UIControlStateNormal];
        [_checkinButton setTitle:@"已签到" forState:UIControlStateSelected];
        
        UIImage *bgImageNormal = [UIImage imageWithSolidColor:[UIColor themeColorValue9] size:CGSizeMake(10, 10)];
        UIImage *bgImageSelected = [UIImage imageWithSolidColor:[[UIColor themeColorValue9] colorWithAlphaComponent:0.5f] size:CGSizeMake(10, 10)];
        [_checkinButton setBackgroundImage:bgImageNormal forState:UIControlStateNormal];
        [_checkinButton setBackgroundImage:bgImageSelected forState:UIControlStateSelected];
        
        _checkinButton.titleLabel.textColor = [UIColor textColorValue6];
        _checkinButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        _checkinButton.layer.masksToBounds = YES;
        _checkinButton.layer.cornerRadius = 4.0f;
    }
    return _checkinButton;
}

- (UIImageView *)accessoryImageView {
    if (!_accessoryImageView) {
        _accessoryImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory_arrow_dark"]];
        [_accessoryImageView sizeToFit];
        _accessoryImageView.hidden = YES;
    }
    return _accessoryImageView;
}

- (CALayer *)bottomBorder {
    if (!_bottomBorder) {
        _bottomBorder = [CALayer layer];
        _bottomBorder.backgroundColor = [UIColor themeColorValue12].CGColor;
    }
    return _bottomBorder;
}

- (void)setStyle:(GFMyGroupCellStyle)style {
    _style = style;
    
    self.checkinButton.hidden = style == GFMyGroupCellStyleArrow;
    self.accessoryImageView.hidden = style == GFMyGroupCellStyleCheckIn;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.avatarImageView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.checkinButton];
        [self.contentView addSubview:self.accessoryImageView];
        [self.layer addSublayer:self.bottomBorder];
        
        __weak typeof(self) weakSelf = self;
        [self.checkinButton bk_addEventHandler:^(id sender) {            
            if (!weakSelf.checkinButton.selected && weakSelf.checkInHandler) {
                weakSelf.checkinButton.selected = YES;
                weakSelf.checkInHandler(weakSelf.model);
            }
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

+ (CGFloat)heightWithModel:(id)model {
    return 60.0f;
}

- (void)bindWithModel:(id)model {
    [super bindWithModel:model];
    
    GFGroupMTL *group = model;
    
    NSString *url = group.groupInfo.imgUrl;

    [self.avatarImageView setImageWithURL:[NSURL URLWithString:[url gf_urlStandardizedWithType:GFImageStandardizedTypeAvatarGroup gifConverted:YES]] placeholder:[UIImage imageNamed:@"default_avatar_1"]];
    self.nameLabel.text = group.groupInfo.name;
    
    self.checkinButton.selected = group.checkedIn;
    
    [self setNeedsLayout];
}

- (void)updateCheckInState:(BOOL)checkedIn {
    self.checkinButton.selected = checkedIn;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.avatarImageView.frame = CGRectMake(15, self.contentView.height/2-25, 43, 43);
    self.avatarImageView.centerY = self.contentView.height/2;
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.width/2;
    self.avatarImageView.clipsToBounds = YES;
    
    self.checkinButton.frame = CGRectMake(self.contentView.width-15-54,
                                          self.contentView.height/2-25/2,
                                          54,
                                          25);
    self.nameLabel.frame = CGRectMake(self.avatarImageView.right+12,
                                      self.contentView.height/2-25/2,
                                      self.checkinButton.x - 12 -self.avatarImageView.right,
                                      25);
    self.bottomBorder.frame = CGRectMake(0, self.height - 0.5, self.width, 0.5);
}

@end
