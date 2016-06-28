//
//  GFWebViewController.m
//  GetFun
//
//  Created by muhuaxin on 15/12/12.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFWebViewController.h"
#import "GFWebView.h"
#import "AppDelegate.h"

@interface GFWebViewController () <UIWebViewDelegate>

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) GFWebView *webView;

@end

@implementation GFWebViewController
- (instancetype)initWithURL:(NSURL*)pageURL {
    self = [super init];
    if (self) {
        self.url = pageURL;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.url && self.webView.request == nil) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    }
}

- (void)dealloc {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if (_webView) {
        [_webView stopLoading];
        _webView.delegate = nil;
        [_webView removeFromSuperview];
        _webView = nil;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.webView.frame = CGRectMake(0, 64, self.view.width, self.view.height-64);
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *urlString = [request.URL absoluteString];
    [(GFWebView *)webView setCookieIfNeeded:urlString];
    
    if ([urlString hasPrefix:@"getfun://"]) {
        [[AppDelegate appDelegate] handleGetfunLinkUrl:urlString];
        return NO;
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self updateViews];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSString *title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.title = title;
    [self updateViews];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self updateViews];
}


#pragma mark - Private Instance methods

- (void)initSubviews {
//    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    UIImage *lImage = [[UIImage imageNamed:@"navi_back_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    [leftButton setImage:lImage forState:UIControlStateNormal];
//    [leftButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self setLeftBarButtons:@[leftButton, self.closeButton]];
//    
//    UIImage *shareImage = [[UIImage imageNamed:@"common_navi_more_n"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    self.shareButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    self.shareButton.hidden = self.shareButtonHidden;
//    [self.shareButton setImage:shareImage forState:UIControlStateNormal];
//    [self.shareButton addTarget:self action:@selector(shareButtonAction) forControlEvents:UIControlEventTouchUpInside];
//    [self setRightBarButton:self.shareButton];
    
    
    
    [self.view addSubview:self.webView];
    
    self.view.backgroundColor = [UIColor themeColorValue13];
}

- (void)refreshButtonAction {
    [self.webView reload];
}

- (void)updateViews {
    if ([self.webView canGoBack]) {
//        self.closeButton.hidden = NO;
    } else {
//        self.closeButton.hidden = YES;
    }
}

- (void)loadURL:(NSURL *)pageURL {
    [self.webView loadRequest:[NSURLRequest requestWithURL:pageURL]];
}

- (void)back:(id)sender {
    if (self.webView.canGoBack) {
        [self.webView goBack];
        [self updateViews];
    } else {
//        [super back:sender];
    }
}

- (void)closeButtonHandler {
    
}

#pragma mark - Getter & Setter

- (GFWebView *)webView {
    if (!_webView) {
        _webView = [[GFWebView alloc] init];
        _webView.backgroundColor = [UIColor clearColor];
        _webView.scalesPageToFit = YES;
        _webView.contentMode = UIViewContentModeRedraw;
        _webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _webView.opaque = YES;
        _webView.delegate = self;
    }
    return _webView;
}

- (void)setUrl:(NSURL *)url {
    if (_url == url)
        return;
    
    _url = url;
    
    if (self.webView.loading) {
        [self.webView stopLoading];
    }
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:_url]];
}


@end
