//
//  GFPublishVoteViewController.m
//  GetFun
//
//  Created by zhouxz on 15/11/28.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFPublishVoteViewController.h"
#import "GFPublishParameterMTL.h"
#import "GFPublishManager.h"

NSString * const GFUserDefaultsKeyPublishVoteDraft = @"GFUserDefaultsKeyPublishVoteDraft";
const NSInteger kDescriptionMaxCharactersCount = 16;


@interface GFPublishVoteViewController () <UITextViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UITextView *titleTextView;
@property (nonatomic, strong) UILabel *titleCountLabel;
@property (nonatomic, strong) UITextField *leftDescTextField;
@property (nonatomic, strong) UITextField *rightDescTextField;
@property (nonatomic, strong) UIImageView *pkImageView;
@property (nonatomic, strong) UIImageView *leftImageView;
@property (nonatomic, copy) NSString *leftImagePath;
@property (nonatomic, strong) UIImageView *rightImageView;
@property (nonatomic, copy) NSString *rightImagePath;
@property (nonatomic, strong) UIView *separatorView; //图片中间分割线
@property (nonatomic, strong) UIImageView *leftSelectPhotoImage;
@property (nonatomic, strong) UIImageView *rightSelectPhotoImage;
@property (nonatomic, strong) UIButton *leftPhotoButton;
@property (nonatomic, strong) UIButton *rightPhotoButton;

@property (nonatomic, assign) BOOL titleAlreadyBeginEditing;

@end

@implementation GFPublishVoteViewController
- (UILabel *)titleCountLabel {
    if (!_titleCountLabel) {
        _titleCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleCountLabel.font = [UIFont systemFontOfSize:13];
        _titleCountLabel.textAlignment = NSTextAlignmentCenter;
        _titleCountLabel.textColor = [UIColor textColorValue5];
        _titleCountLabel.text = @"70";
        [_titleCountLabel sizeToFit];
        _titleCountLabel.frame = CGRectMake(self.titleTextView.right - _titleCountLabel.width - 5,
                                            self.titleTextView.bottom,
                                            _titleCountLabel.width + 5,
                                            _titleCountLabel.height + 15);
    }
    return _titleCountLabel;
}

- (UITextView *)titleTextView {
    if (!_titleTextView) {
        _titleTextView = [[UITextView alloc] initWithFrame:CGRectMake(15, 64 + 15, self.view.width-30, 60)];
        _titleTextView.font = [UIFont systemFontOfSize:19.0f];
        _titleTextView.delegate = self;
        _titleTextView.textColor = [UIColor textColorValue5];
        _titleTextView.text = @"发出来让他们撕去吧";
    }
    return _titleTextView;
}

- (UITextField *)leftDescTextField {
    if (!_leftDescTextField) {
        _leftDescTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, self.titleCountLabel.bottom, self.view.width/2, 43)];
        _leftDescTextField.backgroundColor = RGBCOLOR(66, 211, 198);
        _leftDescTextField.textColor = [UIColor whiteColor];
        _leftDescTextField.textAlignment = NSTextAlignmentCenter;
        _leftDescTextField.font = [UIFont systemFontOfSize:13.0f];
        _leftDescTextField.placeholder = @"输入答案A";
        [_leftDescTextField addTarget:self action:@selector(didTextChangedInTextField:) forControlEvents:UIControlEventEditingChanged];
        _leftDescTextField.delegate = self;
    }
    return _leftDescTextField;
}

- (UITextField *)rightDescTextField {
    if (!_rightDescTextField) {
        _rightDescTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.leftDescTextField.right, self.leftDescTextField.y, self.view.width/2, 43)];
        _rightDescTextField.backgroundColor = RGBCOLOR(151, 120, 241);
        _rightDescTextField.textColor = [UIColor whiteColor];
        _rightDescTextField.textAlignment = NSTextAlignmentCenter;
        _rightDescTextField.font = [UIFont systemFontOfSize:13.0f];
        _rightDescTextField.placeholder = @"输入答案B";
        [_rightDescTextField addTarget:self action:@selector(didTextChangedInTextField:) forControlEvents:UIControlEventEditingChanged];
        _rightDescTextField.delegate = self;
    }
    return _rightDescTextField;
}

- (UIImageView *)pkImageView {
    if (!_pkImageView) {
        _pkImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"content_pk1"]];
        [_pkImageView sizeToFit];
        _pkImageView.center = CGPointMake(self.view.width/2, self.leftDescTextField.centerY);
    }
    return _pkImageView;
}

- (UIImageView *)leftImageView {
    if (!_leftImageView) {
        _leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.leftDescTextField.bottom, self.view.width/2-0.5, self.view.width/2)];
        _leftImageView.backgroundColor = [UIColor themeColorValue14];
        _leftImageView.contentMode = UIViewContentModeScaleAspectFill;
        _leftImageView.clipsToBounds = YES;
    }
    return _leftImageView;
}

- (UIImageView *)rightImageView {
    if (!_rightImageView) {
        _rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.leftImageView.right + 1, self.leftImageView.y, self.view.width/2-0.5, self.view.width/2)];
        _rightImageView.backgroundColor = [UIColor themeColorValue14];
        _rightImageView.contentMode = UIViewContentModeScaleAspectFill;
        _rightImageView.clipsToBounds = YES;
    }
    return _rightImageView;
}

- (UIView *)separatorView {
    if (!_separatorView) {
        _separatorView = [[UIView alloc] initWithFrame:CGRectMake(self.leftImageView.right, self.leftImageView.y, 1, self.view.width/2)];
        _separatorView.backgroundColor = [RGBCOLOR(195, 195, 195) colorWithAlphaComponent:0.5];
    }
    return _separatorView;
}


- (UIImageView *)leftSelectPhotoImage {
    if (!_leftSelectPhotoImage) {
        _leftSelectPhotoImage = [self selectPhotoImage];
        _leftSelectPhotoImage.frame = CGRectMake(17, self.leftImageView.y + 10, _leftSelectPhotoImage.width, _leftSelectPhotoImage.height);
    }
    return _leftSelectPhotoImage;
}

- (UIImageView *)rightSelectPhotoImage {
    if (!_rightSelectPhotoImage) {
        _rightSelectPhotoImage = [self selectPhotoImage];
        _rightSelectPhotoImage.frame = CGRectMake(self.rightImageView.right-17-_rightSelectPhotoImage.width, self.rightImageView.y + 10, _rightSelectPhotoImage.width, _rightSelectPhotoImage.height);
    }
    return _rightSelectPhotoImage;
}

- (UIButton *)leftPhotoButton {
    if (!_leftPhotoButton) {
        _leftPhotoButton = [self photoButton];
        _leftPhotoButton.frame = self.leftImageView.frame;
    }
    return _leftPhotoButton;
}

- (UIButton *)rightPhotoButton {
    if (!_rightPhotoButton) {
        _rightPhotoButton = [self photoButton];
        _rightPhotoButton.frame = self.rightImageView.frame;
    }
    return _rightPhotoButton;
}

//左右选择图片按钮工厂方法
- (UIImageView *)selectPhotoImage {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"publish_select_photo"]];
    [imageView sizeToFit];
    imageView.layer.masksToBounds = YES;
    imageView.layer.cornerRadius = imageView.width/2;
    return imageView;
}

- (UIButton *)photoButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    __weak typeof(self) weakSelf = self;
    [button bk_addEventHandler:^(id sender) {
        switch (weakSelf.keyFrom) {
            case GFPublishKeyFromHome: {
                if (button == self.leftPhotoButton) {
                    [MobClick event:@"gf_fb_03_01_04_1"];
                } else if (button == self.rightPhotoButton) {
                    [MobClick event:@"gf_fb_03_01_05_1"];
                }
                break;
            }
            case GFPublishKeyFromTagTopic: {
                break;
            }
            case GFPublishKeyFromTagNoTopic: {
                if (button == self.leftPhotoButton) {
                    [MobClick event:@"gf_bq_02_07_04_1"];
                } else if (button == self.rightPhotoButton) {
                    [MobClick event:@"gf_bq_02_07_05_1"];
                }
                break;
            }
            case GFPublishKeyFromGroup: {
                break;
            }
        }

        [weakSelf.view endEditing:YES];
        [button setSelected:YES]; // 用于标记选择的图片设置为左侧选项还是右侧选项
        [weakSelf showImagePickerViewController]; 
    } forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"发投票";
    
    [self.view addSubview:self.titleTextView];
    [self.view addSubview:self.titleCountLabel];
    [self.view addSubview:self.leftDescTextField];
    [self.view addSubview:self.rightDescTextField];
    [self.view addSubview:self.pkImageView];
    [self.view addSubview:self.leftImageView];
    [self.view addSubview:self.rightImageView];
    [self.view addSubview:self.leftSelectPhotoImage];
    [self.view addSubview:self.rightSelectPhotoImage];
    [self.view addSubview:self.leftPhotoButton];
    [self.view addSubview:self.rightPhotoButton];
    
    NSData *voteData = [GFUserDefaultsUtil objectForKey:GFUserDefaultsKeyPublishVoteDraft];
    if (voteData) {
        GFPublishVoteMTL *vote = [NSKeyedUnarchiver unarchiveObjectWithData:voteData];
        if (vote) {
            if ([vote.title length] > 0) {
                self.titleTextView.text = vote.title;
                self.titleTextView.textColor = [UIColor textColorValue1];
                self.titleAlreadyBeginEditing = YES;
            }
            if ([vote.imageTitle1 length] > 0) {
                self.leftDescTextField.text = vote.imageTitle1;
            }
            if ([vote.imageTitle2 length] > 0) {
                self.rightDescTextField.text = vote.imageTitle2;
            }
            
            DDLogInfo(@"vote draft leftImagePath = %@ before fix", vote.imageUrl1);
            if ([vote.imageUrl1 length] > 0) {
                NSString *imgPath = [self fixSandboxFilePath:vote.imageUrl1];
                DDLogInfo(@"vote draft leftImagePath = %@ after fix", imgPath);
                self.leftImagePath = imgPath;
                self.leftImageView.image = [UIImage imageWithContentsOfFile:imgPath];
            }
            
            DDLogInfo(@"vote draft rightImagePath = %@ before fix", vote.imageUrl2);
            if ([vote.imageUrl2 length] > 0) {

                NSString *imgPath = [self fixSandboxFilePath:vote.imageUrl2];
                DDLogInfo(@"vote draft rightImagePath = %@ after fix", imgPath);
                self.rightImagePath = imgPath;
                self.rightImageView.image = [UIImage imageWithContentsOfFile:imgPath];
            }
        }
    }
    
    [self hideFooterImageView:YES];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)backBarButtonItemSelected {
    switch (self.keyFrom) {
        case GFPublishKeyFromHome: {
            [MobClick event:@"gf_fb_03_01_06_1"];
            break;
        }
        case GFPublishKeyFromTagTopic: {
            break;
        }
        case GFPublishKeyFromTagNoTopic: {
            [MobClick event:@"gf_bq_02_07_06_1"];
            break;
        }
        case GFPublishKeyFromGroup: {
            break;
        }
    }

    [self.view endEditing:YES];
    NSString *title = @"";
    if (self.titleAlreadyBeginEditing) {
        title = self.titleTextView.text;
    }
    NSString *imageTitle1 = self.leftDescTextField.text;
    NSString *imageTitle2 = self.rightDescTextField.text;
    if ([title length] > 0 || [imageTitle1 length] > 0 || [imageTitle2 length] > 0 || [self.leftImagePath length] > 0 || [self.rightImagePath length] > 0) {
        [UIAlertView bk_showAlertViewWithTitle:@"是否保存草稿" message:@"" cancelButtonTitle:@"放弃" otherButtonTitles:@[@"保存"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                GFPublishVoteMTL *vote = [[GFPublishVoteMTL alloc] init];
                vote.title = title;
                vote.imageTitle1 = imageTitle1;
                vote.imageTitle2 = imageTitle2;
                vote.imageUrl1 = self.leftImagePath;
                vote.imageUrl2 = self.rightImagePath;
                
                NSData *voteData = [NSKeyedArchiver archivedDataWithRootObject:vote];
                [GFUserDefaultsUtil setObject:voteData forKey:GFUserDefaultsKeyPublishVoteDraft];
            } else {
                [GFUserDefaultsUtil setObject:nil forKey:GFUserDefaultsKeyPublishVoteDraft];
            }
            [super backBarButtonItemSelected];
        }];
    } else {
        [GFUserDefaultsUtil setObject:nil forKey:GFUserDefaultsKeyPublishVoteDraft];
        [super backBarButtonItemSelected];
    }
}

- (void)sendBarButtonItemSelected {
    switch (self.keyFrom) {
        case GFPublishKeyFromHome: {
            [MobClick event:@"gf_fb_03_01_07_1"];
            break;
        }
        case GFPublishKeyFromTagTopic: {
            break;
        }
        case GFPublishKeyFromTagNoTopic: {
            [MobClick event:@"gf_bq_02_07_07_1"];
            break;
        }
        case GFPublishKeyFromGroup: {
            break;
        }
    }
    
    NSString *title = [self.titleTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!self.titleAlreadyBeginEditing || !title || [title length] == 0) {
        [MBProgressHUD showHUDWithTitle:@"请输入标题" duration:kCommonHudDuration];
        return;
    }
    
    if (!self.titleAlreadyBeginEditing || [title length] < 5) {
        [MBProgressHUD showHUDWithTitle:@"标题不能少于5个字" duration:kCommonHudDuration];
        return;
    }
    
    
    NSString *imageTitle1 = [self.leftDescTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *imageTitle2 = [self.rightDescTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!imageTitle1 || [imageTitle1 length] == 0 || !imageTitle2 || [imageTitle2 length] == 0) {
        [MBProgressHUD showHUDWithTitle:@"请填写投票选项的名称" duration:kCommonHudDuration inView: self.view];
        return;
    }
    
    if ([imageTitle1 length] > kDescriptionMaxCharactersCount || [imageTitle2 length] > kDescriptionMaxCharactersCount) {
        [MBProgressHUD showHUDWithTitle:[NSString stringWithFormat:@"投票选项的名称不能多于%@个字", @(kDescriptionMaxCharactersCount)] duration:kCommonHudDuration inView: self.view];
        return;
    }
    
    if ((self.leftImagePath && !self.rightImagePath) || (self.rightImagePath && !self.leftImagePath) ) {
        [MBProgressHUD showHUDWithTitle:@"目前不支持只上传一个选项图片，请再增加另外一个选项的图片" duration:kCommonHudDuration inView:self.view];
        return;
    }
    
    GFPublishVoteMTL *voteMTL = [[GFPublishVoteMTL alloc] init];
    voteMTL.title = title;
    voteMTL.imageTitle1 = imageTitle1;
    voteMTL.imageUrl1 = self.leftImagePath;
    voteMTL.imageTitle2 = imageTitle2;
    voteMTL.imageUrl2 = self.rightImagePath;
    
    if (self.currentPOI) {
        voteMTL.longitude = [NSNumber numberWithDouble:self.currentPOI.location.longitude];
        voteMTL.latitude = [NSNumber numberWithDouble:self.currentPOI.location.latitude];
        
        NSString *address = [NSString stringWithFormat:@"%@%@%@%@",
                             [self.currentPOI.province isEqualToString:self.currentPOI.city] ? @"" : self.currentPOI.province,
                             self.currentPOI.city,self.currentPOI.district,
                             self.currentPOI.name];
        voteMTL.address = address;
    }
    if (self.selectedGroup) {
        voteMTL.groupId = self.selectedGroup.groupInfo.groupId;
    }
    if (self.tag) {
        voteMTL.tagId = self.tag.tagInfo.tagId;
    }

    [GFPublishManager publish:voteMTL];
    
    [super sendBarButtonItemSelected];
}

- (void)didTextChangedInTextField:(id)sender {
    UITextField *textField = sender;
    
    UITextRange *selectedRange = [textField markedTextRange];
    NSString * newText = [textField textInRange:selectedRange];
    //获取高亮部分
    if(newText.length > 0) {
        return;
    } else {
        NSString *text = textField.text;
        if (text.length > kDescriptionMaxCharactersCount) {
            textField.text = [text substringToIndex:kDescriptionMaxCharactersCount];
        }
    }

}

- (void)handleSelectImage:(UIImage *)image path:(NSString *)path {
    
    [super handleSelectImage:image path:path];
    
    BOOL left = self.leftPhotoButton.selected;
    if (left) {
        [self.leftImageView setImage:image];
        self.leftImagePath = path;
    } else {
        [self.rightImageView setImage:image];
        self.rightImagePath = path;
    }
    [self.leftPhotoButton setSelected:NO];
    [self.rightPhotoButton setSelected:NO];
}

- (void)handleCancelSelectImage {
    [self.leftPhotoButton setSelected:NO];
    [self.rightPhotoButton setSelected:NO];
    [super handleCancelSelectImage];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    switch (self.keyFrom) {
        case GFPublishKeyFromHome: {
            [MobClick event:@"gf_fb_03_01_01_1"];
            break;
        }
        case GFPublishKeyFromTagTopic: {
            break;
        }
        case GFPublishKeyFromTagNoTopic: {
            [MobClick event:@"gf_bq_02_07_01_1"];
            break;
        }
        case GFPublishKeyFromGroup: {
            break;
        }
    }
    
    if (!self.titleAlreadyBeginEditing) {
        self.titleTextView.text = nil;
        self.titleTextView.textColor = [UIColor textColorValue1];
        self.titleAlreadyBeginEditing = YES;
    }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    switch (self.keyFrom) {
        case GFPublishKeyFromHome: {
            if (textField == self.leftDescTextField) {
                [MobClick event:@"gf_fb_03_01_02_1"];
            } else if (textField == self.rightDescTextField) {
                [MobClick event:@"gf_fb_03_01_03_1"];
            }
            break;
        }
        case GFPublishKeyFromTagTopic: {
            break;
        }
        case GFPublishKeyFromTagNoTopic: {
            if (textField == self.leftDescTextField) {
                [MobClick event:@"gf_bq_02_07_02_1"];
            } else if (textField == self.rightDescTextField) {
                [MobClick event:@"gf_bq_02_07_03_1"];
            }
            break;
        }
        case GFPublishKeyFromGroup: {
            break;
        }
    }

}

- (void)textViewDidChange:(UITextView *)textView {
    UITextRange *selectedRange = [textView markedTextRange];
    NSString * newText = [textView textInRange:selectedRange];
    //获取高亮部分
    if(newText.length > 0) {
        return;
    } else {
        NSString *text = textView.text;
        
        NSInteger length = text.length;
        if (length <= 70) {
            self.titleCountLabel.text = length > 70 ? @"0" : [NSString stringWithFormat:@"%@", @(70 - length)];
        } else {
            self.titleCountLabel.text = @"0";
            text = [text substringWithRange:NSMakeRange(0, 70)];
            textView.text = text;
        }
    }
}
@end
