//
//  GFProfileUpdateTableViewCell.m
//  GetFun
//
//  Created by zhouxz on 15/12/11.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFProfileUpdateTableViewCell.h"
#import "GFUserMTL.h"

@interface GFProfileUpdateTableViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *contentTextField;
@property (nonatomic, strong) UIImageView *accessoryImageView;
@property (nonatomic, strong) CALayer *bottomBorderLayer;

@end

@implementation GFProfileUpdateTableViewCell
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:17.0f];
        _titleLabel.textColor = [UIColor blackColor];
    }
    return _titleLabel;
}

- (UITextField *)contentTextField {
    if (!_contentTextField) {
        _contentTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _contentTextField.textColor = RGBCOLOR(149, 146, 190);
        _contentTextField.textAlignment = NSTextAlignmentRight;
        _contentTextField.font = [UIFont systemFontOfSize:17.0f];
        _contentTextField.userInteractionEnabled = NO;
    }
    return _contentTextField;
}

- (UIImageView *)accessoryImageView {
    if (!_accessoryImageView) {
        _accessoryImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory_arrow_dark"]];
        [_accessoryImageView sizeToFit];
    }
    return _accessoryImageView;
}

- (CALayer *)bottomBorderLayer {
    if (!_bottomBorderLayer) {
        _bottomBorderLayer = [CALayer layer];
        _bottomBorderLayer.backgroundColor = [UIColor themeColorValue12].CGColor;
    }
    return _bottomBorderLayer;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.contentTextField];
        [self.contentView addSubview:self.accessoryImageView];
        [self.contentView.layer addSublayer:self.bottomBorderLayer];
        
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

+ (CGFloat)heightWithModel:(id)model {
    return 50.0f;
}

- (void)bindWithModel:(id)model {
    [super bindWithModel:model];
    
    NSDictionary *modelDict = model;
    
    self.titleLabel.text = [modelDict objectForKey:@"title"];
    self.contentTextField.placeholder = [modelDict objectForKey:@"placeHolder"];
    NSString *content = [modelDict objectForKey:@"content"];
    self.contentTextField.text = content;
    BOOL shouldShowAccessory = [[model objectForKey:@"accessory"] boolValue];
    self.contentTextField.enabled = shouldShowAccessory;
    self.accessoryImageView.hidden = !shouldShowAccessory;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake(15, 0, 90.0f, self.contentView.height);
    self.accessoryImageView.frame = ({
        CGFloat x = self.contentView.width-15-self.accessoryImageView.width;
        CGFloat y = self.contentView.height/2 - self.accessoryImageView.height/2;
        CGRect rect = CGRectMake(x, y, self.accessoryImageView.width, self.accessoryImageView.height);
        rect;
    });
    self.contentTextField.frame = CGRectMake(self.titleLabel.right+10,
                                             0,
                                             self.accessoryImageView.x - 7 - self.titleLabel.right - 10, self.contentView.height);
    const CGFloat borderWidth = 0.5f;
    self.bottomBorderLayer.frame = CGRectMake(0, self.height - borderWidth, self.width, borderWidth);
}

@end
