//
//  GFRecommendGroupView.m
//  GetFun
//
//  Created by Liu Peng on 15/12/1.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFRecommendGroupView.h"
#import "GFGroupMTL.h"



@interface GFRecommendGroupView ()

@property (nonatomic, strong) UIImageView *groupAvatar;

@property (nonatomic, strong) UILabel *distanceLabel;

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;

@property (nonatomic, strong) UIImageView *memberCountImageView;
@property (nonatomic, strong) UILabel *memberCountLabel;
@property (nonatomic, strong) UIImageView *locationImageView;
@property (nonatomic, strong) UILabel *locationLabel;

@property (nonatomic, strong) CALayer *topBorderLayer;

@end

@implementation GFRecommendGroupView
- (UIImageView *)groupAvatar {
    if (!_groupAvatar) {
        _groupAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 67.0f, 67.0f)];
        _groupAvatar.layer.masksToBounds = YES;
        _groupAvatar.layer.cornerRadius = 33.5f;
    }
    return _groupAvatar;
}

- (UILabel *)distanceLabel {
    if (!_distanceLabel) {
        _distanceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _distanceLabel.font = [UIFont systemFontOfSize:13.0f];
        _distanceLabel.textAlignment = NSTextAlignmentRight;
        _distanceLabel.numberOfLines = 1;
        _distanceLabel.textColor = [UIColor textColorValue4];
    }
    return _distanceLabel;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.font = [UIFont systemFontOfSize:16.0f];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.numberOfLines = 1;
        _nameLabel.textColor = [UIColor textColorValue1];
    }
    return _nameLabel;
}

- (UILabel *)descriptionLabel {
    if (!_descriptionLabel) {
        _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _descriptionLabel.font = [UIFont systemFontOfSize:14.0f];
        _descriptionLabel.textAlignment = NSTextAlignmentLeft;
        _descriptionLabel.numberOfLines = 1;
        _descriptionLabel.textColor = [UIColor textColorValue3];
    }
    return _descriptionLabel;
}

- (UIImageView *)memberCountImageView {
    if (!_memberCountImageView) {
        _memberCountImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_person"]];
        _memberCountImageView.frame = CGRectMake(0, 0, 11, 11);
    }
    return _memberCountImageView;
}

- (UILabel *)memberCountLabel {
    if (!_memberCountLabel) {
        _memberCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _memberCountLabel.font =  [UIFont systemFontOfSize:13];
        _memberCountLabel.textColor = [UIColor textColorValue4];
    }
    return _memberCountLabel;
}

- (UIImageView *)locationImageView {
    if (!_locationImageView) {
        _locationImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_location3"]];
        _locationImageView.frame = CGRectMake(0, 0, 11, 11);
    }
    return _locationImageView;
}

- (UILabel *)locationLabel {
    if (!_locationLabel) {
        _locationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _locationLabel.font = [UIFont systemFontOfSize:13];
        _locationLabel.textColor = [UIColor textColorValue4];
        _locationLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _locationLabel;
}

- (CALayer *)topBorderLayer {
    if (!_topBorderLayer) {
        _topBorderLayer = [CALayer layer];
        _topBorderLayer.frame = CGRectZero;
        _topBorderLayer.backgroundColor = [UIColor themeColorValue15].CGColor;
    }
    return _topBorderLayer;
}

+ (CGFloat)groupItemViewHeight {
    return 83.0f;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.groupAvatar];
        [self addSubview:self.nameLabel];
        [self addSubview:self.distanceLabel];
        [self addSubview:self.descriptionLabel];
        [self addSubview:self.memberCountImageView];
        [self addSubview:self.memberCountLabel];
        [self addSubview:self.locationImageView];
        [self addSubview:self.locationLabel];
        
        [self.layer addSublayer:self.topBorderLayer];
    }
    return self;
}

- (void)setGroup:(GFGroupMTL *)group {
    
    _group = group;
    
    NSURL *url = [NSURL URLWithString:[group.groupInfo.imgUrl gf_urlStandardizedWithType:GFImageStandardizedTypeAvatarGroup gifConverted:YES]];
    [self.groupAvatar setImageWithURL:url placeholder:[UIImage imageNamed:@"default_avatar_1"]];
    
    self.nameLabel.text = group.groupInfo.name;
    self.descriptionLabel.text = group.groupInfo.groupDescription;
    
    if ([group.distance floatValue] >= 999 * 1000) {
        [self.distanceLabel setText:@"在远方"];
    } else {
        NSString *distanceString = [NSString stringWithFormat:@"%@km", @([group.distance floatValue]/1000.0f)];
        if ([distanceString length] >= 4) {
            distanceString = [[distanceString substringToIndex:4] stringByAppendingString:@"km"];
        }
        [self.distanceLabel setText:distanceString];
    }
    
    self.memberCountLabel.text = [NSString stringWithFormat:@"%@人", group.groupInfo.memberCount];
    self.locationLabel.text = [NSString stringWithFormat:@"%@", group.groupInfo.address];
}

- (void)setDistanceVisible:(BOOL)distanceVisible {
    _distanceVisible = distanceVisible;
    self.distanceLabel.hidden = !distanceVisible;
    [self setNeedsLayout];
}

- (void)setLocationVisible:(BOOL)locationVisible {
    _locationVisible = locationVisible;
    self.locationImageView.hidden = self.locationLabel.hidden = !locationVisible;
    [self setNeedsLayout];
}

- (void)setTopBorderVisible:(BOOL)topBorderVisible {
    _topBorderVisible = topBorderVisible;
    self.topBorderLayer.hidden = !topBorderVisible;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.groupAvatar.frame = CGRectMake(15.0f, self.height/2-self.groupAvatar.width/2, self.groupAvatar.width, self.groupAvatar.height);
    
    [self.nameLabel sizeToFit];
    [self.distanceLabel sizeToFit];
    
    self.nameLabel.frame = CGRectMake(self.groupAvatar.right+13.0f,
                                      self.groupAvatar.y + 3,
                                      self.distanceLabel.x - 10.0f - self.groupAvatar.right - 13.0f,
                                      self.nameLabel.height);
    self.distanceLabel.frame = CGRectMake(self.width - 15 - self.distanceLabel.width,
                                          self.nameLabel.y,
                                          self.distanceLabel.width,
                                          self.distanceLabel.height);
    
    [self.descriptionLabel sizeToFit];
    self.descriptionLabel.frame = CGRectMake(self.nameLabel.x,
                                             self.nameLabel.bottom + 5,
                                             self.width - 15 - self.nameLabel.x,
                                             self.descriptionLabel.height);
    
    // 人数、位置部分的整体高度按照18进行计算
    CGFloat footerHeight = 18.0f;
    
    self.memberCountImageView.frame = CGRectMake(self.descriptionLabel.x,
                                                 self.groupAvatar.bottom-footerHeight/2-self.memberCountImageView.height/2 - 3,
                                                 self.memberCountImageView.width,
                                                 self.memberCountImageView.height);
    
    UILabel *tmpLabel = [[UILabel alloc] init];
    tmpLabel.font = [UIFont systemFontOfSize:13];
    tmpLabel.text = @"999+人";
    [tmpLabel sizeToFit];
    self.memberCountLabel.frame = CGRectMake(self.memberCountImageView.right + 5,
                                             self.groupAvatar.bottom - footerHeight -3,
                                             tmpLabel.width,
                                             footerHeight);
    
    
    self.locationImageView.frame = CGRectMake(self.memberCountLabel.right + 5,
                                              self.memberCountImageView.y,
                                              self.locationImageView.width,
                                              self.locationImageView.height);
    
    self.locationLabel.frame = CGRectMake(self.locationImageView.right + 5,
                                          self.memberCountLabel.y,
                                          self.width - 15 - self.locationImageView.right - 5,
                                          footerHeight);
    
    const CGFloat borderWidth = 0.5f;
    self.topBorderLayer.frame = CGRectMake(0, self.height - borderWidth, self.width, borderWidth);
}


@end
