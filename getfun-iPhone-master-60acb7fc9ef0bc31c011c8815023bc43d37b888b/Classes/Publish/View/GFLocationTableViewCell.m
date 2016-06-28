//
//  GFLocationTableViewCell.m
//  GetFun
//
//  Created by zhouxz on 15/12/1.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFLocationTableViewCell.h"
#import <AMapSearchKit/AMapSearchKit.h>

@interface GFLocationTableViewCell ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *addressLabel;

@end

@implementation GFLocationTableViewCell

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _iconImageView;
}

- (UILabel *)addressLabel {
    if (!_addressLabel) {
        _addressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _addressLabel.font = [UIFont systemFontOfSize:16.0f];
    }
    return _addressLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.iconImageView];
        [self.contentView addSubview:self.addressLabel];
    }
    return self;
}

+ (CGFloat)heightWithModel:(id)model {
    return 44.0f;
}

- (void)bindWithModel:(id)model {
    [super bindWithModel:model];
    
    if ([model isKindOfClass:[NSString class]]) {
        self.iconImageView.image = [UIImage imageNamed:@"icon_location_invisible2"];
        self.addressLabel.text = model;
    } else {
        AMapPOI *poi = (AMapPOI *)model;
        self.iconImageView.image = [UIImage imageNamed:@"icon_location1"];
        
        self.addressLabel.text = poi.name;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.iconImageView sizeToFit];
    self.iconImageView.frame = CGRectMake(17,
                                          self.contentView.height/2 - self.iconImageView.height/2,
                                          self.iconImageView.width,
                                          self.iconImageView.height);
    self.addressLabel.frame = CGRectMake(self.iconImageView.right + 17,
                                         self.contentView.height/2 - 10,
                                         self.contentView.width-17-17-self.iconImageView.right,
                                         20);
}

@end
