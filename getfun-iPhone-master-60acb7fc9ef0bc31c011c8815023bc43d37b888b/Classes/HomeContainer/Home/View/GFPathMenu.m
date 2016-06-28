//
//  GFPathMenu.m
//  GetFun
//
//  Created by zhouxz on 15/12/14.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFPathMenu.h"
NSString * const GFUserDefaultsKeyShouldHidePictureBadge = @"GFUserDefaultsKeyShouldHidePictureBadge";

@interface GFPathItemButton ()
@property (strong, nonatomic) UIImageView *badgeView;
@end

@implementation GFPathItemButton
- (UIImageView *)badgeView {
    if (!_badgeView) {
        _badgeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_badge_new"]];
        [_badgeView sizeToFit];
        _badgeView.center = CGPointMake(self.bounds.size.width *0.75,0);
    }
    return _badgeView;
}
- (instancetype)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage backgroundImage:(UIImage *)backgroundImage backgroundHighlightedImage:(UIImage *)backgroundHighlightedImage {
    
    if (self = [super initWithImage:image highlightedImage:highlightedImage backgroundImage:backgroundImage backgroundHighlightedImage:backgroundHighlightedImage]) {
        [self addSubview:self.badgeView];
        self.showBadge = NO;
    }
    return self;
}

- (void)setShowBadge:(BOOL)showBadge {
    self.badgeView.hidden = !showBadge;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    CGFloat x = -20;
    CGFloat y = contentRect.size.height - 5;
    CGFloat width = contentRect.size.width + 40;
    CGFloat height = contentRect.size.height;
    CGRect titleRect = CGRectMake(x, y, width, height);
    return titleRect;
}

@end

@interface GFPathMenu () <DCPathButtonDelegate>

@property (nonatomic, strong) GFPathItemButton *qrButton;
@property (nonatomic, strong) GFPathItemButton *voteButton;
@property (nonatomic, strong) GFPathItemButton *pictureButton;
@property (nonatomic, strong) GFPathItemButton *linkButton;
@property (nonatomic, strong) GFPathItemButton *articleButton;
@property (nonatomic, strong) UIButton *centerButton;

@end

@implementation GFPathMenu

- (GFPathItemButton *)qrButton {
    if (!_qrButton) {
        UIImage *img = [UIImage imageNamed:@"menu_qr"];
        _qrButton = [[GFPathItemButton alloc] initWithImage:img
                                                highlightedImage:[img opacity:0.5f]
                                                 backgroundImage:nil
                                      backgroundHighlightedImage:nil];
        [_qrButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _qrButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        _qrButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _qrButton;
}

- (GFPathItemButton *)voteButton {
    if (!_voteButton) {
        UIImage *img = [UIImage imageNamed:@"menu_vote"];
        _voteButton = [[GFPathItemButton alloc] initWithImage:img
                                             highlightedImage:[img opacity:0.5f]
                                              backgroundImage:nil
                                   backgroundHighlightedImage:nil];
        [_voteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _voteButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        _voteButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _voteButton;
}

- (GFPathItemButton *)pictureButton {
    if (!_pictureButton) {
        UIImage *img = [UIImage imageNamed:@"menu_picture"];
              _pictureButton = [[GFPathItemButton alloc] initWithImage:img
                                                highlightedImage:[img opacity:0.5f]
                                                 backgroundImage:nil
                                      backgroundHighlightedImage:nil];
        [_pictureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _pictureButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        _pictureButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _pictureButton;
}

- (GFPathItemButton *)linkButton {
    if (!_linkButton) {
        UIImage *img = [UIImage imageNamed:@"menu_link"];
        _linkButton = [[GFPathItemButton alloc] initWithImage:img
                                             highlightedImage:[img opacity:0.5f]
                                              backgroundImage:nil
                                   backgroundHighlightedImage:nil];
        [_linkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _linkButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        _linkButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _linkButton;
}

- (GFPathItemButton *)articleButton {
    if (!_articleButton) {
        UIImage *img = [UIImage imageNamed:@"menu_article"];
        _articleButton = [[GFPathItemButton alloc] initWithImage:img
                                                highlightedImage:[img opacity:0.5f]
                                                 backgroundImage:nil
                                      backgroundHighlightedImage:nil];
        [_articleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _articleButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        _articleButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _articleButton;
}

- (instancetype)initWithCenterImage:(UIImage *)centerImage
                   highlightedImage:(UIImage *)centerHighlightedImage
                      disabledImage:(UIImage *)centerDisabledImage {
    if (self = [super initWithCenterImage:centerImage highlightedImage:centerHighlightedImage]) {
        [self.centerButton setBackgroundImage:centerDisabledImage forState:UIControlStateDisabled];
    }
    return self;
}

- (UIButton *)centerButton {
    UIButton *button = nil;
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIButton class]] && ![view isKindOfClass:[GFPathItemButton class]]) {
            button = (UIButton *)view;
        }
    }
    return button;
}

+ (instancetype)defaultPathMenu {
    
    UIImage *img = [UIImage imageNamed:@"menu_action"];
    GFPathMenu *pathMenu = [[GFPathMenu alloc] initWithCenterImage:img
                                                  highlightedImage:[img opacity:0.5f]
                                                     disabledImage:img];
    [pathMenu addPathItems:@[
                             pathMenu.qrButton,
                             pathMenu.voteButton,
                             pathMenu.pictureButton,
                             pathMenu.linkButton,
                             pathMenu.articleButton
                             ]];
    pathMenu.basicDuration = 0.2f;
    pathMenu.delegate = pathMenu;
    pathMenu.bottomViewColor = [[UIColor blackColor] colorWithAlphaComponent:0.8f];
    pathMenu.bloomRadius = 120.0f;
    pathMenu.allowCenterButtonRotation = YES;
    pathMenu.allowSounds = NO;
    pathMenu.bloomDirection = kDCPathButtonBloomDirectionTop;
    
    BOOL shouldHide = [GFUserDefaultsUtil boolForKey:GFUserDefaultsKeyShouldHidePictureBadge];
    pathMenu.pictureButton.showBadge = !shouldHide;
    
    return pathMenu;
}

#pragma mark - DCPathButtonDelegate
- (void)pathButton:(DCPathButton *)dcPathButton clickItemButtonAtIndex:(NSUInteger)itemButtonIndex {
    if (2 == itemButtonIndex) {
        [GFUserDefaultsUtil setBool:YES forKey:GFUserDefaultsKeyShouldHidePictureBadge];
        self.pictureButton.showBadge = NO;
    }
    
    if (self.menuDelegate && [self.menuDelegate respondsToSelector:@selector(pathMenu:clickItemButtonAtIndex:)]) {
        [self.menuDelegate pathMenu:self clickItemButtonAtIndex:itemButtonIndex];
    }
}

- (void)willPresentDCPathButtonItems:(DCPathButton *)dcPathButton {
    GFPathMenu *pathMenu = (GFPathMenu *)dcPathButton;
    [self performSelector:@selector(updateTitle:) withObject:@YES afterDelay:pathMenu.basicDuration];
    
    if (self.menuDelegate && [self.menuDelegate respondsToSelector:@selector(clickPathMenu:)]) {
        [self.menuDelegate clickPathMenu:self];
    }
}

- (void)didPresentDCPathButtonItems:(DCPathButton *)dcPathButton {
    
}

- (void)willDismissDCPathButtonItems:(DCPathButton *)dcPathButton {
    [self updateTitle:@NO];
}

- (void)didDismissDCPathButtonItems:(DCPathButton *)dcPathButton {
    
}

- (void)updateTitle:(NSNumber *)shouldShow {
    [self.qrButton setTitle:[shouldShow boolValue] ? @"扫一扫" : @"" forState:UIControlStateNormal];
    [self.voteButton setTitle:[shouldShow boolValue] ? @"发投票" : @"" forState:UIControlStateNormal];
    [self.pictureButton setTitle:[shouldShow boolValue] ? @"发图片" : @"" forState:UIControlStateNormal];
    [self.linkButton setTitle:[shouldShow boolValue] ? @"发链接" : @"" forState:UIControlStateNormal];
    [self.articleButton setTitle:[shouldShow boolValue] ? @"发文章" : @"" forState:UIControlStateNormal];

}

- (void)setCenterButtonEnabled:(BOOL)enabled {
    self.centerButton.enabled = enabled;
}
@end
