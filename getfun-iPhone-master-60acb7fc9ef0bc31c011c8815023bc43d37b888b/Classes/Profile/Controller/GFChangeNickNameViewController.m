//
//  GFChangeNickNameViewController.m
//  GetFun
//
//  Created by zhouxz on 15/12/11.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFChangeNickNameViewController.h"
#import "GFAccountManager.h"

#define GF_NICKNAME_MAX_CHARACTERS_COUNT 15

@interface GFChangeNickNameViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *nickNameTextField;
@property (nonatomic, strong) UILabel *characterCountLabel; //提示输入字符个数
@property (nonatomic, strong) UIButton *okButton;

@end

@implementation GFChangeNickNameViewController

- (UITextField *)nickNameTextField {
    if (!_nickNameTextField) {
        _nickNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 20+64, self.view.width, 44.0f)];
        
        _nickNameTextField.text = [GFAccountManager sharedManager].loginUser.nickName;
        _nickNameTextField.backgroundColor = [UIColor whiteColor];
        _nickNameTextField.textColor = [UIColor textColorValue1];
        _nickNameTextField.font = [UIFont systemFontOfSize:17.0f];
        
        //设置缩进
        UIView *indentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 44)];
        indentView.backgroundColor = [UIColor clearColor];
        _nickNameTextField.leftView = indentView;
        _nickNameTextField.leftViewMode = UITextFieldViewModeAlways;
        
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 44)];
        rightView.backgroundColor = [UIColor clearColor];
        _nickNameTextField.rightView = rightView;
        _nickNameTextField.rightViewMode = UITextFieldViewModeAlways;
#if 1 // modified by lhc, 2016-01-21
        [_nickNameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
#else
        _nickNameTextField.delegate = self;
#endif
    }
    return _nickNameTextField;
}

- (UILabel *)characterCountLabel {
    if (!_characterCountLabel) {
        const CGFloat width = 40;
        _characterCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.width - width - 20, 0, width, 40)];
        _characterCountLabel.centerY = self.nickNameTextField.centerY;
        _characterCountLabel.font = [UIFont systemFontOfSize:17.0f];
        _characterCountLabel.textColor = [UIColor textColorValue5];
        _characterCountLabel.textAlignment = NSTextAlignmentRight;
        _characterCountLabel.text = [NSString stringWithFormat:@"%@", @(GF_NICKNAME_MAX_CHARACTERS_COUNT - [self.nickNameTextField.text length])];
        
    }
    return _characterCountLabel;
}

- (UIButton *)okButton {
    if (!_okButton) {
        _okButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _okButton.frame = CGRectMake(0, 0, 40, 40);
        [_okButton setTitle:@"完成" forState:UIControlStateNormal];
        [_okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_okButton setBackgroundColor:[UIColor clearColor]];
        [_okButton setTitleColor:[UIColor textColorValue7] forState:UIControlStateNormal];
        __weak typeof(self) weakSelf = self;
        [_okButton bk_addEventHandler:^(id sender) {
            [weakSelf rightBarButtonItemSelected];
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _okButton;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"修改昵称";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.okButton];
    
    [self.view addSubview:self.nickNameTextField];
    [self.view addSubview:self.characterCountLabel];
    if ([self.nickNameTextField.text length] >= GF_NICKNAME_MAX_CHARACTERS_COUNT) {
        self.nickNameTextField.text = [self.nickNameTextField.text substringToIndex:GF_NICKNAME_MAX_CHARACTERS_COUNT];
        self.characterCountLabel.text = [NSString stringWithFormat:@"%zd",0];
    }
}

- (void)rightBarButtonItemSelected {
    
    NSString *nickName = self.nickNameTextField.text;
    nickName = [nickName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([nickName length] > 15 || [nickName length] == 0) {
        [MBProgressHUD showHUDWithTitle:@"昵称长度为1-15个字符" duration:kCommonHudDuration];
        return;
    }
    
    if (self.nickNameChangeHandler) {
        self.nickNameChangeHandler(self.nickNameTextField.text, ^(){
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
}

- (void)textFieldDidChange:(UITextField *)textField
{
    UITextRange *selectedRange = [textField markedTextRange];
    NSString * newText = [textField textInRange:selectedRange];
    //获取高亮部分
    if(newText.length > 0) {
        return;
    } else {
        NSString *text = textField.text;
        NSInteger length = text.length;
        if (text.length <= GF_NICKNAME_MAX_CHARACTERS_COUNT) {
            self.characterCountLabel.text = length > GF_NICKNAME_MAX_CHARACTERS_COUNT ? @"0" : [NSString stringWithFormat:@"%@", @(GF_NICKNAME_MAX_CHARACTERS_COUNT - length)];
        } else {
            self.characterCountLabel.text = @"0";
            textField.text = [text substringToIndex:GF_NICKNAME_MAX_CHARACTERS_COUNT];
        }
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSInteger length = [text length];
    
    self.characterCountLabel.text = length > GF_NICKNAME_MAX_CHARACTERS_COUNT ? @"0" : [NSString stringWithFormat:@"%@", @(GF_NICKNAME_MAX_CHARACTERS_COUNT - length)];

    return length <= GF_NICKNAME_MAX_CHARACTERS_COUNT;
}


@end
