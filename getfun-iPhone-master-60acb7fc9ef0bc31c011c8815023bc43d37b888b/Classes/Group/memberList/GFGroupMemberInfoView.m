//
//  GFGroupMemberInfoView.m
//  GetFun
//
//  Created by liupeng on 15/12/3.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFGroupMemberInfoView.h"

#define GF_GROUP_MEMEBER_INFO_NAME_HEIGHT 20.0f
#define GF_GROUP_MEMEBER_INFO_AGE_HEIGHT 16.0f

@interface GFGroupMemberInfoView ()

@property(nonatomic, strong) UILabel *nickNameLabel;
@property(nonatomic, strong) UILabel *genderLabel;
@property(nonatomic, strong) UILabel *ageLabel;
@property(nonatomic, strong) UILabel *locationLabel;
@property(nonatomic, strong) UIView *seperatorView1;
@property(nonatomic, strong) UIView *seperatorView2;

@end

@implementation GFGroupMemberInfoView

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self addSubview:self.nickNameLabel];
    [self addSubview:self.genderLabel];
    [self addSubview:self.ageLabel];
    [self addSubview:self.locationLabel];
    [self addSubview:self.seperatorView1];
    [self addSubview:self.seperatorView2];
  }
  return self;
}

- (UILabel *)nickNameLabel {
  if (!_nickNameLabel) {
      _nickNameLabel = [GFGroupMemberInfoView nickNameLabel];
  }
  return _nickNameLabel;
}


+ (UILabel *)nickNameLabel {
    UILabel *nickNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    nickNameLabel.font = [UIFont systemFontOfSize:17.0f];
    nickNameLabel.textColor = [UIColor textColorValue1];
    nickNameLabel.textAlignment = NSTextAlignmentLeft;
    nickNameLabel.numberOfLines = 1;
    return nickNameLabel;
}

- (UILabel *)genderLabel {
  if (!_genderLabel) {
      _genderLabel = [GFGroupMemberInfoView genderLabel];
  }
  return _genderLabel;
}

+ (UILabel *)genderLabel {
    UILabel *genderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    genderLabel.font = [UIFont systemFontOfSize:14.0f];
    genderLabel.textColor = [UIColor textColorValue1];
    genderLabel.textAlignment = NSTextAlignmentLeft;
    return genderLabel;
}

- (UILabel *)ageLabel {
  if (!_ageLabel) {
      _ageLabel = [GFGroupMemberInfoView ageLabel];
  }
  return _ageLabel;
}

+ (UILabel *)ageLabel {
    UILabel *ageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    ageLabel.font = [UIFont systemFontOfSize:14.0f];
    ageLabel.textColor = [UIColor textColorValue1];
    ageLabel.textAlignment = NSTextAlignmentLeft;
    return ageLabel;
}

- (UILabel *)locationLabel {
  if (!_locationLabel) {
    _locationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _locationLabel.font = [UIFont systemFontOfSize:14.0f];
    _locationLabel.textColor = [UIColor textColorValue1];
    _locationLabel.textAlignment = NSTextAlignmentLeft;
  }
  return _locationLabel;
}

+ (UILabel *)locationLabel {
    UILabel * locationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    locationLabel.font = [UIFont systemFontOfSize:14.0f];
    locationLabel.textColor = [UIColor textColorValue1];
    locationLabel.textAlignment = NSTextAlignmentLeft;
    return locationLabel;
}

- (UIView *)seperatorView1 {
  if (!_seperatorView1) {
    _seperatorView1 = [[UIView alloc] initWithFrame:CGRectZero];
    _seperatorView1.backgroundColor = [UIColor themeColorValue15];
  }
  return _seperatorView1;
}

- (UIView *)seperatorView2 {
  if (!_seperatorView2) {
    _seperatorView2 = [[UIView alloc] initWithFrame:CGRectZero];
    _seperatorView2.backgroundColor = [UIColor themeColorValue15];
  }
  return _seperatorView2;
}

- (void)updateWithUser:(GFUserMTL *)user {

  self.nickNameLabel.text = user.nickName;

  switch (user.gender) {
  case GFUserGenderUnknown: {
    self.genderLabel.text = @"未知";
    break;
  }
  case GFUserGenderMale: {
    self.genderLabel.text = @"男";
    break;
  }
  case GFUserGenderFemale: {
    self.genderLabel.text = @"女";
    break;
  }
  default: { break; }
  }
    
    NSDate *birthday = [NSDate dateWithTimeIntervalSince1970:[user.birthday longLongValue] / 1000];
    NSTimeInterval dateDiff = [birthday timeIntervalSinceNow];
    NSInteger age=trunc(dateDiff/(60*60*24))/365;
    self.ageLabel.text = [NSString stringWithFormat:@"%@岁", @(-age)];
    
    NSString *address = [user.provinceName stringByAppendingString:user.cityName];
    self.seperatorView2.hidden = [address isEqualToString:@""];
    self.locationLabel.text = address;
    [self setNeedsLayout];
}


+ (CGFloat)heightWithModel:(id)model {
    return GF_GROUP_MEMEBER_INFO_NAME_HEIGHT + 4 + GF_GROUP_MEMEBER_INFO_AGE_HEIGHT;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.nickNameLabel.frame =
      CGRectMake(0, 0, self.width, GF_GROUP_MEMEBER_INFO_NAME_HEIGHT);
    
    [self.genderLabel sizeToFit];
    self.genderLabel.origin = CGPointMake(0, self.nickNameLabel.bottom + 4);
    
    self.seperatorView1.frame =
      CGRectMake(self.genderLabel.right + 7, self.nickNameLabel.bottom + 6, 2,
                 self.genderLabel.height - 4);
    
    [self.ageLabel sizeToFit];
    self.ageLabel.origin = CGPointMake(self.seperatorView1.right + 7, self.nickNameLabel.bottom + 4);
    
    self.seperatorView2.frame =
      CGRectMake(self.ageLabel.right + 7, self.nickNameLabel.bottom + 6, 2,
                 self.genderLabel.height - 4);
    self.locationLabel.frame = ({
        CGSize size = [self.locationLabel sizeThatFits:CGSizeMake(self.width - self.genderLabel.width - self.ageLabel.width  - 7 * 4 - 2 * 2, MAXFLOAT)];
        CGRect rect = CGRectMake(self.seperatorView2.right + 7, self.nickNameLabel.bottom + 4, size.width, size.height);
        rect;
    });
}
@end
