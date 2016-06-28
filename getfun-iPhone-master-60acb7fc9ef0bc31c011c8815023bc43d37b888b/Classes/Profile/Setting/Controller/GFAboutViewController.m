//
//  GFAboutViewController.m
//  GetFun
//
//  Created by zhouxz on 15/12/11.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFAboutViewController.h"

@interface GFAboutViewController ()

@property (nonatomic, strong) UIImageView *abountImageView;
@property (nonatomic, strong) UILabel *versionLabel;
@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation GFAboutViewController

- (UIImageView *)abountImageView {
    if (!_abountImageView) {
        _abountImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"placeholder_about_getfun"]];
        [_abountImageView sizeToFit];
        _abountImageView.centerX = self.view.width/2;
        _abountImageView.centerY = 64 + 73 + _abountImageView.height / 2;
    }
    return _abountImageView;
}


- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 20)];
        _textLabel.center = CGPointMake(self.view.width / 2, self.abountImageView.bottom + 73 + 20.0f / 2);
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.text = @"\"让你发现别人不知道的多维宇宙\"";
        _textLabel.font = [UIFont systemFontOfSize:17];
        _textLabel.textColor = [UIColor textColorValue3];
    }
    return _textLabel;
}

- (UILabel *)versionLabel {
    if (!_versionLabel) {
        _versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 20)];
        _versionLabel.center = CGPointMake(self.view.width / 2, self.view.height - 20.0f / 2 - 30);
        _versionLabel.textAlignment = NSTextAlignmentCenter;
        _versionLabel.text = [NSString stringWithFormat:@"版本号%@", APP_VERSION];
        _versionLabel.font = [UIFont systemFontOfSize:15];
        _versionLabel.textColor = [UIColor textColorValue3];
    }
    return _versionLabel;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"关于我们";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.abountImageView];
    [self.view addSubview:self.textLabel];
    [self.view addSubview:self.versionLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
