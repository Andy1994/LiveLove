//
//  GFSettingTableViewCell.m
//  GetFun
//
//  Created by zhouxz on 15/12/11.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFSettingTableViewCell.h"

@implementation GFSettingTableViewCell
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:17.0f];
        _titleLabel.textColor = [UIColor textColorValue1];
    }
    return _titleLabel;
}

- (UISwitch *)switchButton {
    if (!_switchButton) {
        _switchButton = [[UISwitch alloc] initWithFrame:CGRectZero];
    }
    return _switchButton;
}

- (UIImageView *)accessoryImageView {
    if (!_accessoryImageView) {
        _accessoryImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory_arrow_dark"]];
        [_accessoryImageView sizeToFit];
    }
    return _accessoryImageView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.accessoryImageView];
        [self.contentView addSubview:self.switchButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake(17, 0, self.contentView.width / 3 * 2, self.contentView.height);
    self.accessoryImageView.center = CGPointMake(self.contentView.width-17-self.accessoryView.width / 2, self.contentView.height/2);
    self.switchButton.frame = ({
        CGSize size = CGSizeMake(52, 32);
        CGPoint origin = CGPointMake(self.contentView.width-17-size.width, self.contentView.height / 2 - size.height/2);
        CGRect rect = CGRectMake(origin.x, origin.y, size.width, size.height);
        rect;
    });
}

@end
