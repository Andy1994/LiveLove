//
//  GFPublishLinkViewController.m
//  GetFun
//
//  Created by zhouxz on 15/11/28.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFPublishLinkViewController.h"
#import "GFPublishParameterMTL.h"
#import "GFNetworkManager+Publish.h"
#import "GFPublishManager.h"

NSString * const GFUserDefaultsKeyPublishLinkDraft = @"GFUserDefaultsKeyPublishLinkDraft";
#define kTitleCharactersMaxCount 70

@interface GFPublishLinkViewController () <UITextViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UITextField *linkTextField;
@property (nonatomic, strong) UIButton *pasteLinkButton;

@property (nonatomic, assign) BOOL contentAlreadyBeginEditing;
@property (nonatomic, strong) UITextView *contentTextView;

@end

@implementation GFPublishLinkViewController
- (UITextField *)linkTextField {
    if (!_linkTextField) {
        _linkTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 17 + 64, self.pasteLinkButton.x - 10 - 15, 33)];
        _linkTextField.keyboardType = UIKeyboardTypeURL;
        [_linkTextField gf_makeIndentSpace:12];
        _linkTextField.placeholder = @"http://";
        _linkTextField.userInteractionEnabled = YES;
        _linkTextField.textAlignment = NSTextAlignmentLeft;
        _linkTextField.backgroundColor = [UIColor whiteColor];
        _linkTextField.textColor = [UIColor blackColor];
        _linkTextField.font = [UIFont systemFontOfSize:14.0f];
        _linkTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _linkTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        _linkTextField.layer.borderColor = [UIColor themeColorValue12].CGColor;
        _linkTextField.layer.borderWidth = 1.0f;
        _linkTextField.layer.cornerRadius = 2.0f;
        _linkTextField.delegate = self;
    }
    return _linkTextField;
}

- (UIButton *)pasteLinkButton {
    if (!_pasteLinkButton) {
        _pasteLinkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _pasteLinkButton.layer.cornerRadius = 3.0f;
        _pasteLinkButton.frame = CGRectMake(self.view.width-15-84, 17 + 64, 84, 33);
        [_pasteLinkButton setTitle:@"粘贴链接" forState:UIControlStateNormal];
        [_pasteLinkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _pasteLinkButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_pasteLinkButton setBackgroundColor:[UIColor themeColorValue9]];

        __weak typeof(self) weakSelf = self;
        [_pasteLinkButton bk_addEventHandler:^(id sender) {
            [MobClick event:@"gf_fb_01_01_01_1"];
            NSString *urlString = [UIPasteboard generalPasteboard].string;
            if (urlString) {
                if (![urlString hasPrefix:@"http"]) {
                    urlString = [NSString stringWithFormat:@"http://%@", urlString];
                }
                weakSelf.linkTextField.text = urlString;
            }
            
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _pasteLinkButton;
}

- (UITextView *)contentTextView {
    if (!_contentTextView) {
        _contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(12, self.linkTextField.bottom + 15, self.view.width-24,191)];
        _contentTextView.delegate = self;
        _contentTextView.textAlignment = NSTextAlignmentLeft;
        _contentTextView.backgroundColor = [UIColor whiteColor];
        _contentTextView.textColor = [UIColor textColorValue5];
        _contentTextView.font = [UIFont systemFontOfSize:17.0f];
        _contentTextView.text = @"随便说点什么吧";
    }
    return _contentTextView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"发链接";
    
    [self hideFooterImageView:YES];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.linkTextField];
    [self.view addSubview:self.pasteLinkButton];
    [self.view addSubview:self.contentTextView];
    
    NSData *linkData = [GFUserDefaultsUtil objectForKey:GFUserDefaultsKeyPublishLinkDraft];
    if (linkData) {
        GFPublishLinkMTL *link = [NSKeyedUnarchiver unarchiveObjectWithData:linkData];
        if (link) {
            self.linkTextField.text = link.url;
            if (link.title && [link.title length] > 0) {
                self.contentTextView.text = link.title;
                self.contentAlreadyBeginEditing = YES;
                self.contentTextView.textColor = [UIColor textColorValue1];
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkPasteboard) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)dealloc {
    
}

- (void)checkPasteboard {
    BOOL canPasteURL = [[UIPasteboard generalPasteboard].string gf_isValidType:GFValidateTypeURL];
    self.pasteLinkButton.enabled = canPasteURL;
    [self.pasteLinkButton setBackgroundColor:canPasteURL ? [UIColor themeColorValue9] : [UIColor themeColorValue14]];
}

- (void)backBarButtonItemSelected {
    
    NSString *url = self.linkTextField.text;
    NSString *content = @"";
    if (self.contentAlreadyBeginEditing) {
        content = self.contentTextView.text;
    }
    
    if ([url length] > 0 || [content length] > 0) {
        
        [UIAlertView bk_showAlertViewWithTitle:@"是否保存草稿？" message:@"" cancelButtonTitle:@"取消" otherButtonTitles:@[@"保存"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex==1) {
                // 保存图文
                GFPublishLinkMTL *link = [[GFPublishLinkMTL alloc] init];
                link.url = url;
                link.title = content;
                
                NSData *linkData = [NSKeyedArchiver archivedDataWithRootObject:link];
                [GFUserDefaultsUtil setObject:linkData forKey:GFUserDefaultsKeyPublishLinkDraft];
            } else {
                [GFUserDefaultsUtil setObject:nil forKey:GFUserDefaultsKeyPublishLinkDraft];
            }
            
            [super backBarButtonItemSelected];
        }];
    } else {
        [GFUserDefaultsUtil setObject:nil forKey:GFUserDefaultsKeyPublishLinkDraft];
        [super backBarButtonItemSelected];
    }
}

- (void)sendBarButtonItemSelected {
    
    [self.view endEditing:YES];
    NSString *urlString = self.linkTextField.text;
    
    if (!urlString || urlString.length == 0 ) {
        [MBProgressHUD showHUDWithTitle:@"请输入链接" duration:kCommonHudDuration inView:self.view];
        return;
    }
    
    if (![[urlString lowercaseString] hasPrefix:@"http://"] && ![[urlString lowercaseString] hasPrefix:@"https://"]) {
        urlString = [NSString stringWithFormat:@"http://%@", urlString];
    }
    
    
    if (![urlString gf_isValidType:GFValidateTypeURL]) {
        [MBProgressHUD showHUDWithTitle:@"输入的链接无效" duration:kCommonHudDuration inView:self.view];
        return;
    }
    
    NSString *content = self.contentTextView.text;
    if (!self.contentAlreadyBeginEditing) {
        content = @"";
    }
    
    //检查输入字数限制,进行截取
    if ([content length] > kTitleCharactersMaxCount) {
        content = [content substringWithRange:NSMakeRange(0, kTitleCharactersMaxCount)];
    }
    
    GFPublishLinkMTL *linkMTL = [[GFPublishLinkMTL alloc] init];
    linkMTL.url = urlString;
    linkMTL.title = content;
    if (self.currentPOI) {
        linkMTL.longitude = [NSNumber numberWithDouble:self.currentPOI.location.longitude];
        linkMTL.latitude = [NSNumber numberWithDouble:self.currentPOI.location.longitude];
        
        NSString *address = [NSString stringWithFormat:@"%@%@%@%@",
                             [self.currentPOI.province isEqualToString:self.currentPOI.city] ? @"" : self.currentPOI.province,
                             self.currentPOI.city,
                             self.currentPOI.district,
                             self.currentPOI.name];
        linkMTL.address = address;
    }
    if (self.selectedGroup) {
        linkMTL.groupId = self.selectedGroup.groupInfo.groupId;
    }
    if (self.tag) {
        linkMTL.tagId = self.tag.tagInfo.tagId;
    }

    [GFPublishManager publish:linkMTL];
    [GFUserDefaultsUtil setObject:nil forKey:GFUserDefaultsKeyPublishLinkDraft];
    
    [super sendBarButtonItemSelected];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [MobClick event:@"gf_fb_01_01_01_1"];
}


#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [MobClick event:@"gf_fb_01_01_02_1"];
    if (!self.contentAlreadyBeginEditing) {
        textView.text = @"";
        self.contentAlreadyBeginEditing = YES;
        self.contentTextView.textColor = [UIColor textColorValue1];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *oriText = textView.text;
    NSString *updateText = [oriText stringByReplacingCharactersInRange:range withString:text];
    if ([updateText length] > 70) {
        updateText = [updateText substringToIndex:70];
        textView.text = updateText;
        return NO;
    } else {
        return YES;
    }
}

@end
