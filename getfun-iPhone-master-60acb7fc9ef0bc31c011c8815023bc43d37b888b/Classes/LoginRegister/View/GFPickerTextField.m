//
//  GFPickerTextField.m
//  GetFun
//
//  Created by liupeng on 15/11/24.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFPickerTextField.h"

@interface GFPickerTextField ()

@property (strong, nonatomic, readwrite) UIImageView *accessoryImageView;
@property (strong, nonatomic, readwrite) UILabel *selectLabel;
@end

@implementation GFPickerTextField

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.accessoryImageView];
        [self addSubview:self.selectLabel];
    }
    return self;
}

- (UIImageView *)accessoryImageView {
    if (!_accessoryImageView) {
        _accessoryImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory_arrow_dark"]];
    }
    return _accessoryImageView;
}

- (UILabel *)selectLabel {
    if (!_selectLabel) {
        _selectLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _selectLabel.text = @"请选择";
        _selectLabel.textColor = RGBCOLOR(37, 37, 37);
        _selectLabel.textAlignment = NSTextAlignmentRight;
        _selectLabel.font = [UIFont systemFontOfSize:17.0f];
    }
    return _selectLabel;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.accessoryImageView.size = CGSizeMake(25.0f, 25.0f);
    self.accessoryImageView.center = CGPointMake(self.width - self.accessoryImageView.size.width / 2, self.height / 2);

    self.selectLabel.size = CGSizeMake(70.0, self.accessoryImageView.height);
    self.selectLabel.center = CGPointMake(self.width - self.accessoryImageView.width - 10.0f - self.selectLabel.width / 2, self.height / 2);
}


@end
