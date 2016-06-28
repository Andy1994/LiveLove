//
//  GFPublishArticleViewController.m
//  GetFun
//
//  Created by zhouxz on 15/11/28.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFPublishArticleViewController.h"
#import "GFPublishParameterMTL.h"
#import "GFPublishManager.h"
#import "HTMLParser.h"
#import "GFCacheUtil.h"

@interface GFRichTextEditorView : DTRichTextEditorView

@end

@implementation GFRichTextEditorView
- (CGRect)caretRectForPosition:(UITextPosition *)position {
    CGRect rect = [super caretRectForPosition:position];
    
    CGFloat maxY = CGRectGetMaxY(rect);
    
    rect = CGRectMake(rect.origin.x, maxY - self.defaultFontSize - 2, rect.size.width, self.defaultFontSize);
    
    return rect;
}

@end

#define GF_ARTICLETITLE_MAX_CHARACTERS_COUNT (70)

NSString * const GFUserDefaultsKeyPublishArticleDraft = @"GFUserDefaultsKeyPublishArticleDraft";

@interface GFPublishArticleViewController () <UITextViewDelegate, DTRichTextEditorViewDelegate>

@property (nonatomic, strong) UIView *contentBackgroundView;
@property (nonatomic, strong) UILabel *titleCountLabel;
@property (nonatomic, strong) UITextView *titleTextView;
@property (nonatomic, assign) BOOL titleAlreadyBeginEditing;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) GFRichTextEditorView *contentTextView;
@property (nonatomic, assign) BOOL contentAlreadyBeginEditing;

@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) NSMutableArray *selectedImages;

@end

@implementation GFPublishArticleViewController
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
                                            _titleCountLabel.height);
    }
    return _titleCountLabel;
}
- (UITextView *)titleTextView {
    if (!_titleTextView) {
        if (SCREEN_WIDTH<325) {
            /**
             针对4s特别处理
            */
            _titleTextView = [[UITextView alloc] initWithFrame:CGRectMake(12, 6+64, self.view.width-24, 30.0f)];
            _titleTextView.font = [UIFont systemFontOfSize:17.0f];
        }else{
            _titleTextView = [[UITextView alloc] initWithFrame:CGRectMake(12, 20+64, self.view.width-24, 58.0f)];
            _titleTextView.font = [UIFont systemFontOfSize:22.0f];

  
        }
        _titleTextView.delegate = self;
        _titleTextView.textColor = [UIColor textColorValue5];
        _titleTextView.text = @"输入标题";
    }
    return _titleTextView;
}


- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(16, self.contentTextView.y - 12, self.view.width - 32, 0.5f)];
        _lineView.backgroundColor = [UIColor themeColorValue15];
    }
    return _lineView;
}

- (GFRichTextEditorView *)contentTextView {
    if (!_contentTextView) {
        _contentTextView = [[GFRichTextEditorView alloc] initWithFrame:CGRectMake(16, self.titleTextView.bottom + 27, self.view.width-32, self.view.height-self.titleTextView.bottom-27)];
        // modified by zxz 20160115, 输入框遮挡文字的bugfix
        _contentTextView.attributedTextContentView.edgeInsets = UIEdgeInsetsMake(15, 0, 100, 0);
        _contentTextView.defaultFontSize = 17.0f;
        _contentTextView.editorViewDelegate = self;
        _contentTextView.canInteractWithPasteboard = NO;
//        _contentTextView.attributedText = [[NSAttributedString alloc] initWithString:@"把你有趣的故事分享给大家~"
//                                                                          attributes:@{
//                                                                                       NSFontAttributeName : [UIFont systemFontOfSize:17.0f],
//                                                                                       NSForegroundColorAttributeName:[UIColor textColorValue5]
//                                                                                       }];
    }
    return _contentTextView;
}
- (UILabel *)placeholderLabel {
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _placeholderLabel.font = [UIFont systemFontOfSize:17];
        _placeholderLabel.textAlignment = NSTextAlignmentLeft;
        _placeholderLabel.textColor = [UIColor textColorValue5];
        _placeholderLabel.text = @"输入正文";
        [_placeholderLabel sizeToFit];
        _placeholderLabel.frame = CGRectMake(0, 0, self.view.width, 30);
    }
    return _placeholderLabel;
}

- (NSMutableArray *) selectedImages {
    if (!_selectedImages) {
        _selectedImages = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _selectedImages;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"发文章";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *contentBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    [contentBackgroundView addSubview:self.titleTextView];
    [contentBackgroundView addSubview:self.titleCountLabel];
    [contentBackgroundView addSubview:self.lineView];
    [contentBackgroundView addSubview:self.contentTextView];
    self.contentBackgroundView = contentBackgroundView;
    
     [self.contentTextView addSubview:self.placeholderLabel];
    
    [self.view addSubview:self.contentBackgroundView];
    
    // 加载图文草稿
    NSData *articleData = [GFUserDefaultsUtil objectForKey:GFUserDefaultsKeyPublishArticleDraft];
    if (articleData) {
        GFPublishArticleMTL *article = [NSKeyedUnarchiver unarchiveObjectWithData:articleData];
        if (article) {
            
            if (article.title && [article.title length] > 0) {
                self.titleTextView.text = article.title;
                self.titleTextView.textColor = [UIColor textColorValue1];
                self.titleAlreadyBeginEditing = YES;
                self.titleCountLabel.text = [NSString stringWithFormat:@"%@", @(70 - [article.title length])];
            }

            NSData *htmlData = [article.content dataUsingEncoding:NSUTF8StringEncoding];
            
            NSAttributedString *attributedContent = [[NSAttributedString alloc] initWithHTMLData:htmlData documentAttributes:nil];
            if (attributedContent && [attributedContent length] > 0) {
                self.contentTextView.attributedText = attributedContent;
                self.contentAlreadyBeginEditing = YES;
                self.placeholderLabel.hidden = YES;
            }
        }
    }
}

- (NSData *)fixSandboxPathInHTMLData:(NSData *)htmlData {
    
    NSMutableString *htmlString = [[NSMutableString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlString error:nil];
    HTMLNode *bodyNode = [parser body];
    NSArray *inputNodes = [bodyNode findChildTags:@"img"];
    for (HTMLNode *node in inputNodes) {
        NSString *value = [node getAttributeNamed:@"src"];
        NSString *fixPath = [self fixSandboxFilePath:value];
        [htmlString replaceOccurrencesOfString:value withString:fixPath options:0 range:NSMakeRange(0, [htmlString length])];
    }
    
    NSData *data = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

- (void)dealloc {
    [_contentTextView removeFromSuperview];
    _contentTextView = nil;
}

- (void)backBarButtonItemSelected {
    
    [self.view endEditing:YES];
    
    NSString *title = @"";
    if (self.titleAlreadyBeginEditing) {
        title = [self.titleTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }

    NSString *content = @"";
    if (self.contentAlreadyBeginEditing) {
        content = [[self.contentTextView.attributedText string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }

    if ([title length] > 0 || [content length] > 0) {
        //询问是否保存草稿
        [UIAlertView bk_showAlertViewWithTitle:@"是否保存草稿？" message:@"" cancelButtonTitle:@"取消" otherButtonTitles:@[@"保存"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex==1) {
                // 保存图文
                GFPublishArticleMTL *article = [[GFPublishArticleMTL alloc] init];
                article.title = title;
                article.content = [content length] > 0 ? [self.contentTextView.attributedText htmlString] : @"";
                NSData *articleData = [NSKeyedArchiver archivedDataWithRootObject:article];
                [GFUserDefaultsUtil setObject:articleData forKey:GFUserDefaultsKeyPublishArticleDraft];
            } else {
                [GFUserDefaultsUtil setObject:nil forKey:GFUserDefaultsKeyPublishArticleDraft];
            }
            
            [super backBarButtonItemSelected];
        }];
    } else {
        [GFUserDefaultsUtil setObject:nil forKey:GFUserDefaultsKeyPublishArticleDraft];
        [super backBarButtonItemSelected];
    }
    
}

- (void)sendBarButtonItemSelected {
    
    NSString *title = [self.titleTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (!self.titleAlreadyBeginEditing) {
        [MBProgressHUD showHUDWithTitle:@"请输入标题" duration:kCommonHudDuration inView:self.view];
        return;
    } else if ((!title || [title length] < 5)) {
        [MBProgressHUD showHUDWithTitle:@"标题不能少于5个字" duration:kCommonHudDuration inView:self.view];
        return;
    }  else if ([title length] > 70) {
        [MBProgressHUD showHUDWithTitle:@"标题不能多于70个字" duration:kCommonHudDuration inView:self.view];
        return;
    }
    
    
    NSString *content = [[self.contentTextView.attributedText string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!self.contentAlreadyBeginEditing) {

    }
    if ((self.contentAlreadyBeginEditing && (!content || [content length] == 0)) || !self.contentAlreadyBeginEditing) {
        [MBProgressHUD showHUDWithTitle:@"请填写帖子内容" duration:kCommonHudDuration inView:self.view];
        return;
    }

    NSString *htmlContent = [self.contentTextView.attributedText htmlString];
    GFPublishArticleMTL *publishArticle = [[GFPublishArticleMTL alloc] init];
    publishArticle.title = title;
    publishArticle.content = htmlContent;
    if (self.currentPOI) {
        
        NSString *address = [NSString stringWithFormat:@"%@%@%@%@",
                             [self.currentPOI.province isEqualToString:self.currentPOI.city] ? @"" : self.currentPOI.province,
                             self.currentPOI.city,
                             self.currentPOI.district, self.currentPOI.name];
        publishArticle.address = address;
        publishArticle.longitude = [NSNumber numberWithFloat:self.currentPOI.location.longitude];
        publishArticle.latitude = [NSNumber numberWithFloat:self.currentPOI.location.latitude];
    }
    if (self.selectedGroup) {
        publishArticle.groupId = self.selectedGroup.groupInfo.groupId;
    }
    if (self.tag) {
        publishArticle.tagId = self.tag.tagInfo.tagId;
    }
    [GFPublishManager publish:publishArticle];
    
    [GFUserDefaultsUtil setObject:nil forKey:GFUserDefaultsKeyPublishArticleDraft];
    
    [super sendBarButtonItemSelected];
}

- (void)handleSelectImage:(UIImage *)image path:(NSString *)path {
    [super handleSelectImage:image path:path];
    
    [self.selectedImages addObject:@(1)]; //计数用，记录当前选择图片数目
    
    if (!self.contentAlreadyBeginEditing) {
        self.contentTextView.attributedString = [[NSAttributedString alloc] initWithString:@"\n"];
        self.contentAlreadyBeginEditing = YES;
        self.placeholderLabel.hidden = YES;
    }
    
    if (![self.contentTextView isFirstResponder]) {
        [self.contentTextView becomeFirstResponder];
    }
    
    DTTextRange *textRange = (DTTextRange *)[self.contentTextView selectedTextRange];
    CGFloat displayWidth = image.size.width;
    CGFloat displayHeight = image.size.height;
    if (displayWidth > SCREEN_WIDTH - 100.0f) {
        displayHeight = displayHeight / displayWidth * (SCREEN_WIDTH - 100.0f);
        displayWidth = SCREEN_WIDTH - 100.0f;
    }
    
    DTImageTextAttachment *attachment = [[DTImageTextAttachment alloc] initWithElement:nil options:nil];
//    attachment.image = image;
    attachment.contentURL = [NSURL fileURLWithPath:path];
    attachment.displaySize = CGSizeMake(displayWidth, displayHeight);
    attachment.originalSize = image.size;
    
    [self.contentTextView replaceRange:textRange withAttachment:attachment inParagraph:YES];
}

#pragma mark - DTRichTextEditorViewDelegate
- (void)editorViewDidBeginEditing:(DTRichTextEditorView *)editorView {
    
    [MobClick event:@"gf_fb_02_01_02_1"];
    if (!self.contentAlreadyBeginEditing) {
        self.contentAlreadyBeginEditing = YES;
        self.placeholderLabel.hidden = YES;
    }
}

- (void)editorViewDidEndEditing:(DTRichTextEditorView *)editorView
{
    
}

- (NSAttributedString *)editorView:(DTRichTextEditorView *)editorView willPasteText:(NSAttributedString *)text inRange:(NSRange)range {
    
    
    if (!self.contentAlreadyBeginEditing) {
//        self.contentTextView.attributedText = [[NSAttributedString alloc] initWithString:@"\n"];
        self.contentAlreadyBeginEditing = YES;
        self.placeholderLabel.hidden = YES;
    }
    
    NSString *plain = [text plainTextString];
    return [[NSAttributedString alloc] initWithString:plain attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:20.0f],
                                                                                   NSForegroundColorAttributeName:[UIColor textColorValue1]
                                                                                   }];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [MobClick event:@"gf_fb_02_01_01_1"];
    if (!self.titleAlreadyBeginEditing) {
        self.titleTextView.text = nil;
        self.titleTextView.textColor = [UIColor textColorValue1];
        self.titleAlreadyBeginEditing = YES;
    }
}

- (void)textViewDidChange:(UITextView *)textView {
#if 0 // modified by lhc, 2016-01-21
    NSString *text = textView.text;
    if ([text length] > 70) {
        text = [text substringWithRange:NSMakeRange(0, 70)];
        textView.text = text;
    }
    
    NSInteger countRemain = 70 - [textView.text length];
    if (countRemain < 0) {
        countRemain = 0;
    }
    self.titleCountLabel.text = [NSString stringWithFormat:@"%ld", (long)countRemain];
#else
    UITextRange *selectedRange = [textView markedTextRange];
    NSString * newText = [textView textInRange:selectedRange];
    //获取高亮部分
    if(newText.length > 0) {
        return;
    } else {
        NSString *text = textView.text;
        
        NSInteger length = text.length;
        if (length <= GF_ARTICLETITLE_MAX_CHARACTERS_COUNT) {
            self.titleCountLabel.text = length > GF_ARTICLETITLE_MAX_CHARACTERS_COUNT ? @"0" : [NSString stringWithFormat:@"%@", @(GF_ARTICLETITLE_MAX_CHARACTERS_COUNT - length)];
        } else {
            self.titleCountLabel.text = @"0";
            text = [text substringWithRange:NSMakeRange(0, GF_ARTICLETITLE_MAX_CHARACTERS_COUNT)];
            textView.text = text;
        }
    }
#endif
}

//重写父类属性方法
- (NSUInteger)currentSelectedPhotoCount {
//    return [self.selectedImages count];
    return 0; //由于图片键盘删除无法获取事件，暂时返回0，一直限制为最大数目
}

@end
