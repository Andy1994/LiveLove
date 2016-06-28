//
//  GFFeedbackViewController.m
//  GetFun
//
//  Created by zhouxz on 15/12/11.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFFeedbackViewController.h"
#import "GFNetworkManager+User.h"

@interface GFFeedbackViewController () <DTRichTextEditorViewDelegate>

@property (nonatomic, strong) DTRichTextEditorView *contentView;
@property (nonatomic, strong) UIButton *feedbackButton;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, assign) BOOL contentAlreadyBeginEditing;
@end

@implementation GFFeedbackViewController

- (DTRichTextEditorView *)contentView {
    if (!_contentView) {
        _contentView = [[DTRichTextEditorView alloc] initWithFrame:CGRectMake(0, 10+64, self.view.width, 150.0f)];
        _contentView.defaultFontSize = 18.0f;
        _contentView.editorViewDelegate = self;
        [_contentView gf_AddTopBorderWithColor:[UIColor themeColorValue15] andWidth:0.5f];
        [_contentView gf_AddBottomBorderWithColor:[UIColor themeColorValue15] andWidth:0.5f];

    }
    return _contentView;
}

- (UILabel *)placeholderLabel {
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _placeholderLabel.font = [UIFont systemFontOfSize:17];
        _placeholderLabel.textAlignment = NSTextAlignmentLeft;
        _placeholderLabel.textColor = [UIColor textColorValue5];
        _placeholderLabel.text = @"给我们提点建议~";
        [_placeholderLabel sizeToFit];
        _placeholderLabel.frame = CGRectMake(10, 0, self.view.width-20, 30);
    }
    return _placeholderLabel;
}

- (UIButton *)feedbackButton {
    if (!_feedbackButton) {
        _feedbackButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _feedbackButton.frame = CGRectMake(0, 0, 40, 40);
        [_feedbackButton setTitle:@"提交" forState:UIControlStateNormal];
        _feedbackButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_feedbackButton setBackgroundColor:[UIColor clearColor]];
        [_feedbackButton setTitleColor:[UIColor textColorValue7] forState:UIControlStateNormal];
        __weak typeof(self) weakSelf = self;
        [_feedbackButton bk_addEventHandler:^(id sender) {
            [MobClick event:@"gf_sz_03_01_01_1"];
            [weakSelf addFeedback];
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _feedbackButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"意见反馈";
    [self.view addSubview:self.contentView];
    [self.contentView addSubview:self.placeholderLabel];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.feedbackButton];
}

- (void)dealloc {
    [_contentView removeFromSuperview];
    _contentView = nil;
}

- (void)backBarButtonItemSelected {
    [MobClick event:@"gf_sz_03_01_02_1"];
    [super backBarButtonItemSelected];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addFeedback {
    [MobClick event:@"gf_sz_03_01_01_1"];

    NSString *content = [self.contentView.attributedText string];
    NSString *mobile = @"18610263117";
    
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager addFeedbackContent:content
                                  mobile:mobile
                                 success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage) {
                                     if (code == 1) {
                                         [MBProgressHUD showHUDWithTitle:@"反馈成功！" duration:kCommonHudDuration inView:self.view];
                                         [weakSelf.navigationController popViewControllerAnimated:YES];
                                     } else {
                                         [MBProgressHUD showHUDWithTitle:apiErrorMessage duration:kCommonHudDuration inView:self.view];
                                     }
                                 } failure:^(NSUInteger taskId, NSError *error) {
                                     [MBProgressHUD showHUDWithTitle:@"请检查网络" duration:kCommonHudDuration inView:self.view];
                                 }];
    
}

- (void)editorViewDidBeginEditing:(DTRichTextEditorView *)editorView {
    
    if (!self.contentAlreadyBeginEditing) {
        self.contentAlreadyBeginEditing = YES;
        self.placeholderLabel.hidden = YES;
    }
}

- (NSAttributedString *)editorView:(DTRichTextEditorView *)editorView willPasteText:(NSAttributedString *)text inRange:(NSRange)range {
    
    NSString *plain = [text plainTextString];
    
    return [[NSAttributedString alloc] initWithString:plain];
}

@end
