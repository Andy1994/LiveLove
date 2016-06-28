//
//  GFContentDetailViewController.m
//  GetFun
//
//  Created by muhuaxin on 15/11/15.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFContentDetailViewController.h"

#import "GFAccountManager.h"
#import "GFNetworkManager+Comment.h"
#import "GFNetworkManager+Publish.h"

#import "GFContentMTL.h"
#import "GFCommentMTL.h"
#import "GFContentDetailMTL.h"
#import "GFPictureMTL.h"
#import "GFUserMTL.h"
#import "GFVoteItemMTL.h"

#import "GFContentDetailArticleView.h"
#import "GFContentDetailVoteView.h"
#import "GFContentDetailLinkView.h"
#import "GFContentDetailPictureView.h"
#import "GFContentInputView.h"

#import "GFContentDetailFunUsersView.h"
#import "GFContentDetailShareView.h"
#import "GFUserCommentCell.h"
#import "GFContentTagUserGuideView.h"
#import "GFCommentDetailViewController.h"

#import "NTESActivityViewController.h"
#import "GFCopyUrlActionActivity.h"
#import "GFContentDetailNoCommentView.h"
#import "GFCommentListViewController.h"
#import "GFWebViewController.h"
#import "GFProfileViewController.h"

#import "GFTagDetailViewController.h"

#import "GFNavigationController.h"
#import "GFLoginRegisterViewController.h"
#import "GFImageGroupView.h"
#import "WXApi.h"
#import "GFSoundEffect.h"
#import "AppDelegate.h"

// 链接贴、投票贴不要沉浸式阅读
// 图文帖、图片帖要沉浸式阅读

NSString * const GFUserDefaultsKeyLastVersionForContentDetailGuide = @"GFUserDefaultsKeyLastVersionForContentDetailGuide"; //用户引导提示标记，只有在有用户引导时才会使用，请勿删除！！

@interface GFContentDetailHeaderFooter : UICollectionReusableView
@end

@implementation GFContentDetailHeaderFooter
- (void)prepareForReuse {
    [super prepareForReuse];
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
    }
    return self;
}
@end

@interface GFContentDetailViewController()
<UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
UIWebViewDelegate,
HPGrowingTextViewDelegate>

// 通用
@property (nonatomic, strong) GFContentMTL                      *content;

@property (nonatomic, strong) UIBarButtonItem                   *shareBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem                   *commentBarButtonItem;
@property (nonatomic, strong) UIButton                          *commentNumButton;
@property (nonatomic, strong) UIView                            *reloadView; //网络出错时重新加载
@property (nonatomic, strong) GFContentInputView                *inputView;

@property (nonatomic, strong) NTESActivityViewController        *shareViewController;
@property (nonatomic, strong) UICollectionView                  *contentCollectionView;
@property (nonatomic, copy  ) NSArray                           *hotComments;
@property (nonatomic, strong) NSMutableArray                    *allComments;
@property (nonatomic, strong) NSNumber                          *nextQueryTime;

// 获得content时直接初始化该image用于分享，创建分享activity时直接取此image
@property (nonatomic, copy) UIImage                             *shareImage;

// 图文
@property (nonatomic, assign, readonly) BOOL preview;
@property (nonatomic, strong) GFContentDetailArticleView        *articleView;
@property (nonatomic, strong) NSDictionary                      *contentData;
@property (nonatomic, strong) NSArray                           *imageOrderKeys;
@property (nonatomic, strong) NSMutableArray                    *imagesForArticle;
@property (nonatomic, strong) WebViewJavascriptBridge           *bridge;
// 投票
@property (nonatomic, strong) GFContentDetailVoteView           *voteView;
// 图片
@property (nonatomic, strong) GFContentDetailPictureView        *pictureView;
// 链接
@property (nonatomic, strong) GFContentDetailLinkView           *linkView;

@property (nonatomic, strong) MBProgressHUD *entryLoadHud;
@property (nonatomic, assign) GFContentType contentType;
@end

@implementation GFContentDetailViewController
#pragma mark - getter
- (UIBarButtonItem *)commentBarButtonItem {
    if (!_commentBarButtonItem) {
        
        UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //大小为34 * 34
        [commentButton setBackgroundImage:[UIImage imageNamed:@"nav_comment"] forState:UIControlStateNormal];
        [commentButton sizeToFit];
        self.commentNumButton.centerX = commentButton.width;
        [commentButton addSubview:self.commentNumButton];
        _commentBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:commentButton];
        [commentButton addTarget:self action:@selector(commentBarItemAction:) forControlEvents:UIControlEventTouchUpInside];
        _commentBarButtonItem.tintColor = [UIColor blackColor];
    }
    return _commentBarButtonItem;
}

- (UIButton *)commentNumButton {
    if (!_commentNumButton) {
        _commentNumButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _commentNumButton.frame = CGRectMake(0, 0, 22, 14);
        [_commentNumButton setTitle:@"0" forState:UIControlStateDisabled];
        _commentNumButton.hidden = YES;
        [_commentNumButton setTitleColor:[UIColor textColorValue1] forState:UIControlStateDisabled];
        _commentNumButton.titleLabel.font = [UIFont systemFontOfSize:10.0f];
        //大小为16 * 14
        [_commentNumButton setBackgroundImage:[[UIImage imageNamed:@"comment_num"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
        [_commentNumButton setBackgroundImage:[[UIImage imageNamed:@"comment_num"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateDisabled];
        _commentNumButton.enabled = NO;
    }
    return _commentNumButton;
}

- (GFContentInputView *)inputView {
    if (_inputView == nil) {
        _inputView = [[GFContentInputView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - kInputViewHeight, SCREEN_WIDTH, kInputViewHeight)];
        _inputView.textView.delegate = self;
    }
    return _inputView;
}

- (UIView *)reloadView {
    if (!_reloadView) {
        //2个子视图：提示图，按钮
        UIImageView *tipView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"placeholder_content_network_retry"]];
        [tipView sizeToFit];
        
        UIButton *reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [reloadButton setBackgroundImage:[UIImage imageNamed:@"content_reload"] forState:UIControlStateNormal];
        [reloadButton sizeToFit];
        
        const CGFloat space = 6.0f;
        _reloadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, tipView.height + reloadButton.height + space)];
        _reloadView.center = CGPointMake(self.view.width/2, self.view.height/2);
        
        tipView.center = CGPointMake(_reloadView.width/2, tipView.height/2);
        reloadButton.center = CGPointMake(_reloadView.width/2, _reloadView.height - reloadButton.height/2);
        
        [_reloadView addSubview:tipView];
        [_reloadView addSubview:reloadButton];
        
        @weakify(self)
        [reloadButton bk_addEventHandler:^(id sender) {
            @strongify(self)
            [self.reloadView removeFromSuperview];
            [self fetchContent];
        } forControlEvents:UIControlEventTouchUpInside];
        
        _reloadView.userInteractionEnabled = YES;
    }
    return _reloadView;
}

- (NTESActivityViewController *)shareViewController {
    if (!_shareViewController) {
        _shareViewController = [[NTESActivityViewController alloc] init];
    }
    return _shareViewController;
}

- (UICollectionView *)contentCollectionView {
    if (!_contentCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _contentCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _contentCollectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _contentCollectionView.backgroundColor = [UIColor clearColor];
        _contentCollectionView.bounces = NO;
        _contentCollectionView.delegate = self;
        _contentCollectionView.dataSource = self;

        [_contentCollectionView registerClass:[GFContentDetailHeaderFooter class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([GFContentDetailHeaderFooter class])];
        [_contentCollectionView registerClass:[GFContentDetailHeaderFooter class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:NSStringFromClass([GFContentDetailHeaderFooter class])];
        [_contentCollectionView registerClass:[GFContentDetailShareView class] forCellWithReuseIdentifier:NSStringFromClass([GFContentDetailShareView class])];
        [_contentCollectionView registerClass:[GFContentDetailFunUsersView class] forCellWithReuseIdentifier:NSStringFromClass([GFContentDetailFunUsersView class])];
        [_contentCollectionView registerClass:[GFUserCommentCell class] forCellWithReuseIdentifier:NSStringFromClass([GFUserCommentCell class])];
    }
    return _contentCollectionView;
}

- (NSMutableArray *)allComments {
    if (!_allComments) {
        _allComments = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _allComments;
}

- (GFContentDetailArticleView *)articleView {
    if (_articleView == nil) {
        _articleView = [[GFContentDetailArticleView alloc] initWithFrame:self.view.bounds];
        _articleView.articleWebView.delegate = self;
        _articleView.articleWebView.scrollView.delegate = self;
    }
    return _articleView;
}

- (GFContentDetailVoteView *)voteView {
    if (_voteView == nil) {
        _voteView = [[GFContentDetailVoteView alloc] initWithFrame:CGRectZero];
    }
    return _voteView;
}

- (GFContentDetailPictureView *)pictureView {
    if (!_pictureView) {
        _pictureView = [[GFContentDetailPictureView alloc] initWithFrame:CGRectZero];
    }
    return _pictureView;
}

- (GFContentDetailLinkView *)linkView {
    if (!_linkView) {
        _linkView = [[GFContentDetailLinkView alloc] initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height - 64)];
        _linkView.linkWebView.delegate = self;
        _linkView.linkWebView.scrollView.delegate = self;
    }
    return _linkView;
}

//- (instancetype)initWithContentId:(NSNumber *)contentId preview:(BOOL)preview {
//    return [self initWithContentId:contentId preview:preview keyFrom:GFKeyFromUnkown];
//}
//
//- (instancetype)initWithContentId:(NSNumber *)contentId preview:(BOOL)preview keyFrom:(GFKeyFrom)keyFrom {
//    if (self = [super init]) {
//        _contentId = contentId;
//        _preview = preview;
//        _keyFrom = keyFrom;
//    }
//    return self;
//}
//
//- (instancetype)initWithContentId:(NSNumber *)contentId contentType:(GFContentType)contentType preview:(BOOL)preview keyFrom:(GFKeyFrom)keyFrom {
//    id obj = [self initWithContentId:contentId preview:preview keyFrom:keyFrom];
//    [(GFContentDetailViewController *)obj setContentType:contentType];
//    return obj;
//}

- (instancetype)initWithContent:(GFContentMTL *)content preview:(BOOL)preview {
    return [self initWithContent:content preview:preview keyFrom:GFKeyFromUnkown];
}

- (instancetype)initWithContent:(GFContentMTL *)content preview:(BOOL)preview keyFrom:(GFKeyFrom)keyFrom {
    if (self = [super init]) {
        _content = content;
        _preview = preview;
        _keyFrom = keyFrom;
    }
    return self;
}

- (instancetype)initWithContent:(GFContentMTL *)content contentType: (GFContentType)contentType preview:(BOOL)preview keyFrom:(GFKeyFrom)keyFrom {
    
    id obj = [self initWithContent:content preview:preview keyFrom:keyFrom];
    [(GFContentDetailViewController *)obj setContentType:contentType];
    return obj;
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self hideFooterImageView:YES];
//    UIImage *normalImage = [UIImage imageNamed:@"nav_back_dark"];
//    self.navigationItem.leftBarButtonItem = [UIBarButtonItem gf_barButtonItemWithImage:normalImage target:self selector:@selector(backBarButtonItemSelected)];
    
    self.view.backgroundColor = [UIColor themeColorValue13];
    [self loadNavigationItems];
    
    [self fetchContent];
    if (GFContentTypeLink == self.contentType) {
        self.inputView.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

//    [self setHidesBarsOnSwipe];
    if (!self.preview) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardFrameChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
//    if ([self.navigationController respondsToSelector:@selector(setHidesBarsOnSwipe:)]) {
//        self.navigationController.hidesBarsOnSwipe = NO;
//    }
    [self gf_setNavBarShrink:NO];
    
    if (!self.preview) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    
    [self.view endEditing:YES];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)dealloc {
    if (_inputView) {
        [_inputView removeFromSuperview];
        _inputView = nil;
    }
    if (_articleView) {
        [_articleView.articleWebView stopLoading];
        [_articleView removeFromSuperview];
        _articleView = nil;
    }
    if (_linkView) {
        [_linkView.linkWebView stopLoading];
        [_linkView removeFromSuperview];
        _linkView = nil;
    }
    if (_content) {
        _content = nil;
    }
    if (_shareViewController) {
        _shareViewController = nil;
    }
    if (_bridge) {
        _bridge = nil;
    }
    if (_voteView) {
        _voteView = nil;
    }
    if (_pictureView) {
        _pictureView = nil;
    }
}

- (void)onKeyboardFrameChange:(NSNotification *)notification {
    
    NSValue *endFrameValue = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect endFrame = [endFrameValue CGRectValue];
    CGFloat endY = endFrame.origin.y;
    
    [UIView animateWithDuration:.3 animations:^{
        self.inputView.bottom = endY;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - UI
////设置沉浸式阅读，滑动时隐藏导航栏
//- (void)setHidesBarsOnSwipe {
//    if ([self.navigationController respondsToSelector:@selector(setHidesBarsOnSwipe:)]) {
//        //只有图文帖和图帖才有沉浸式阅读
//        GFContentType type = self.content.contentInfo.type;
//        self.navigationController.hidesBarsOnSwipe = (type == GFContentTypeArticle || type == GFContentTypePicture);
//    }
//}

- (void)setupFunctionViews {
    
    if (!self.preview) {
    
        __weak typeof(self) weakSelf = self;
        
        BOOL funned = [self.content isFunned];
        NSInteger funCount = [self.content.contentInfo.funCount integerValue];

        [self.view addSubview:self.inputView];
        
        self.inputView.funButtonHandler = ^{
            [GFAccountManager checkLoginStatus:YES loginCompletion:^(BOOL justLogin, GFUserMTL *user) {
                if (user) {
                    [weakSelf funContent];
                    [weakSelf setContentFunned];
                }
            }];
        };
        self.inputView.funned = funned;
        self.inputView.funCount = funCount;
    }
}

//设置导航栏按钮
- (void)loadNavigationItems {
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    space.width = 34.0f;
    
    NSMutableArray *buttonItems = [[NSMutableArray alloc] initWithCapacity:0];
    
    UIBarButtonItem *moreItem = [UIBarButtonItem gf_barButtonItemWithImage:[UIImage imageNamed:@"nav_more_dark"] target:self selector:@selector(moreBarItemAction:)];
    moreItem.tintColor = [UIColor blackColor];
    [buttonItems addObject:moreItem];
    
    GFContentStatus status = self.content.contentInfo.status;
    if (status == GFContentStatusNormal || status == GFContentStatusPoor) {
        self.shareBarButtonItem = [UIBarButtonItem gf_barButtonItemWithImage:[UIImage imageNamed:@"nav_share_dark"] target:self selector:@selector(shareBarItemAction:)];
        self.shareBarButtonItem.tintColor = [UIColor blackColor];
        self.shareBarButtonItem.enabled = NO;
        [buttonItems addObjectsFromArray:@[space, self.shareBarButtonItem]];
    }
    
    NSUInteger commentCount = [self.content.contentInfo.commentCount unsignedIntegerValue];
    self.commentNumButton.hidden = (commentCount == 0);
    [self.commentNumButton setTitle:[NSString stringWithFormat:@"%@", commentCount <= 99 ? @(commentCount) : @"99+"] forState:UIControlStateDisabled];
    
    [buttonItems addObjectsFromArray:@[space, self.commentBarButtonItem]];
    
    self.navigationItem.rightBarButtonItems = buttonItems;
}

- (void)showReloadView {
    if (![self.reloadView superview]) {
        [self.view addSubview:self.reloadView];
        [self.view sendSubviewToBack:self.reloadView];
    }
}

- (void)hideReloadView {
    if ([self.reloadView superview]) {
        [self.reloadView removeFromSuperview];
    }
}

- (void)setupContentDetailViews {
    
    __weak typeof(self) weakSelf = self;
    
    GFContentType type = self.content.contentInfo.type;
    // 链接贴直接把linkView添加到当前view，Z非链接贴使用collectionView(用于显示分享、fun和评论)
    if (type == GFContentTypeLink) {
        [self.view addSubview:self.linkView];
    } else {
        [self.view addSubview:self.contentCollectionView];
        [self.contentCollectionView addInfiniteScrollingWithActionHandler:^{
            [weakSelf fetchAllComments];
        }];
    }
    
    switch (type) {
        case GFContentTypeArticle: {
            // 这里load网页数据，完成后再显示视图、请求评论
            [self setupJSBridgeForWebView:self.articleView.articleWebView];
            NSURL *url = [[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html"];
            if (url) {
                [self.articleView.articleWebView loadRequest:[NSURLRequest requestWithURL:url]];
            }
            break;
        }
        case GFContentTypeVote: {
            
            // update voteView
            CGFloat height = [GFContentDetailVoteView viewHeightWithContent:self.content];
            self.voteView.frame = CGRectMake(0, 0, SCREEN_WIDTH, height);
            [self.voteView updateContent:self.content animate:NO];
            [self.voteView.userInfoView setAvatarTappedHandler:^(GFUserMTL *user) {
                [MobClick event:@"gf_xq_01_01_01_1"];
                [weakSelf pushIntoProfileViewController:user.userId];
            }];
            [self.voteView.tagContainer setTagHandler:^(GFTagInfoMTL *tagInfo, NSInteger tagIndex) {
                NSString *event = [NSString stringWithFormat:@"gf_xq_01_02_%@_1", @(25+tagIndex)];
                [MobClick event:event];
                
                GFTagDetailViewController *tagDetailViewController = [[GFTagDetailViewController alloc] initWithTagId:tagInfo.tagId];
                [weakSelf.navigationController pushViewController:tagDetailViewController animated:YES];
            }];
            self.voteView.voteView.voteItemHandler = ^(GFVoteItemMTL *voteItem) {
                [GFAccountManager checkLoginStatus:YES
                                   loginCompletion:^(BOOL justLogin, GFUserMTL *user) {
                                       if (user) {
                                           [weakSelf chooseVoteItem:voteItem];
                                       } else {
                                           
                                           [MBProgressHUD showHUDWithTitle:@"登录后才能投票" duration:kCommonHudDuration inView:weakSelf.view];
                                       }
                                   }];
            };

            [self setupFunctionViews];
            [self.contentCollectionView reloadData];
            
            [self fetchHotComments];
            [self fetchAllComments];
            
            break;
        }
        case GFContentTypeLink: {

            GFContentDetailLinkMTL *detailModel = (GFContentDetailLinkMTL *)self.content.contentDetail;
            NSURL *url = [NSURL URLWithString:detailModel.url];
            if (url) {
                [self.linkView.linkWebView loadRequest:[NSURLRequest requestWithURL:url]];
//                if (![self.linkView.linkWebView isLoading]) {
//                    if (self.entryLoadHud) {
//                        [self.entryLoadHud hide:YES];
//                    }
//                }
                
//                self.linkView.frame = CGRectMake(0, 64, self.view.width, self.view.height-64);
                
            }
            break;
        }
        case GFContentTypePicture: {
            CGFloat height = [GFContentDetailPictureView viewHeightWithContent:self.content];
            self.pictureView.frame = CGRectMake(0, 0, SCREEN_WIDTH, height);
            [self.pictureView updateContent:self.content];
            
            [self.pictureView.userInfoView setAvatarTappedHandler:^(GFUserMTL *user) {
                [MobClick event:@"gf_xq_01_01_01_1"];
                [weakSelf pushIntoProfileViewController:user.userId];
            }];
            [self.pictureView.tagContainer setTagHandler:^(GFTagInfoMTL *tagInfo, NSInteger tagIndex) {
                NSString *event = [NSString stringWithFormat:@"gf_xq_01_02_%@_1", @(25+tagIndex)];
                [MobClick event:event];
                
                GFTagDetailViewController *tagDetailViewController = [[GFTagDetailViewController alloc] initWithTagId:tagInfo.tagId];
                [weakSelf.navigationController pushViewController:tagDetailViewController animated:YES];
            }];
            
            GFContentDetailPictureMTL *pictureDetail = (GFContentDetailPictureMTL *)self.content.contentDetail;
            @weakify(self)
            [self.pictureView setTapImageHandler:^(NSInteger iniPictureIndex) {
                @strongify(self)
                GFImageGroupView *imageGroupView = [[GFImageGroupView alloc] initWithImages:self.content.pictures
                                                                                  orderKeys:pictureDetail.pictureSummary
                                                                                 initialKey:[pictureDetail.pictureSummary objectAtIndex:iniPictureIndex]
                                                                                   delegate:self.pictureView];
                [imageGroupView presentToContainer:self.view.window animated:YES completion:nil];
            }];
            
            [self setupFunctionViews];
            [self.contentCollectionView reloadData];
            
            [self fetchHotComments];
            [self fetchAllComments];
            
            break;
        }
        case GFContentTypeUnknown:{
            break;
        }
    }
    //使状态栏背景色变为白色,防止由于沉浸式阅读导航栏上移时状态栏背景色透明显示下方文字
    UIView *statusBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20.0f)];
    statusBackgroundView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:statusBackgroundView];
    [self.view bringSubviewToFront:statusBackgroundView];
}

- (void)setupJSBridgeForWebView:(GFWebView *)webView {
    __weak typeof(self) weakSelf = self;
    @weakify(self)
    
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:webView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        responseCallback(@"Response for message from ObjC");
    }];
    
    // 响应JS调用"profile", 点击用户头像查看个人页
    [self.bridge registerHandler:@"profile" handler:^(id data, WVJBResponseCallback responseCallback) {
        [MobClick event:@"gf_xq_01_01_01_1"];
        NSInteger userIdInteger = [[data objectForKey:@"id"] integerValue];
        NSNumber *userIdNumber = [NSNumber numberWithInteger:userIdInteger];
        [weakSelf pushIntoProfileViewController:userIdNumber];
    }];
    
    // 响应JS调用"tag", 点击tag标签
    [self.bridge registerHandler:@"tag" handler:^(id data, WVJBResponseCallback responseCallback) {

        // JS出来的是string，需要转换
        NSInteger tagIdInteger = [[data objectForKey:@"id"] integerValue];
        NSNumber *tagIdNumber = [NSNumber numberWithInteger:tagIdInteger];
        GFTagDetailViewController *tagDetailViewController = [[GFTagDetailViewController alloc] initWithTagId:tagIdNumber];
        [weakSelf.navigationController pushViewController:tagDetailViewController animated:YES];
    }];
    
    // 响应JS调用"check_big_pic"，点击查看大图
    [self.bridge registerHandler:@"check_big_pic" handler:^(id data, WVJBResponseCallback responseCallback) {
        @strongify(self)
        NSString *picId = [data objectForKey:@"id"];
        GFImageGroupView *imageGroupView = [[GFImageGroupView alloc] initWithImages:self.content.pictures
                                                                                         orderKeys:self.imageOrderKeys
                                                                                        initialKey:picId
                                            delegate:self];
        [imageGroupView presentToContainer:self.view.window animated:YES completion:nil];
    }];
    
    [self.bridge registerHandler:@"sendData" handler:^(id data, WVJBResponseCallback responseCallback) {
        //
    }];
}

#pragma mark - content data request
- (void)fetchContent {
    MBProgressHUD *hud = [MBProgressHUD showLoadingHUDWithTitle:nil inView:self.view];
    
    @weakify(self)
    void (^successHandler)(NSUInteger, NSInteger, GFContentMTL *, NSDictionary *, NSString *) = ^(NSUInteger taskId, NSInteger code, GFContentMTL * content, NSDictionary * data, NSString * errorMessage){
        @strongify(self)
        [hud hide:YES];
        if (code == 1) {

            self.content = content;
            self.contentData = data;
            
            if (self.shareBarButtonItem) {
                self.shareBarButtonItem.enabled = YES;
            }
            
            //准备用于分享的图片
            [self prepareImageForShare:content];
            
            //获取content类型后决定是否沉浸式阅读
//            [self setHidesBarsOnSwipe];
            
            //创建内容详情视图
            [self setupContentDetailViews];
        } else {
            if ([errorMessage length] > 0) {
                [MBProgressHUD showHUDWithTitle:errorMessage duration:kCommonHudDuration inView:self.view];
            } else { //只有在服务器返回信息为空时才显示刷新按钮
                [self showReloadView];
            }
        }
    };
    
    void (^failureHandler)() = ^(){
        @strongify(self)
        [hud hide:YES];
        [self showReloadView];
    };
    
    if (self.preview) {
        [GFNetworkManager queryPreviewContent:self.content.contentInfo.contentId
                                      success:successHandler
                                      failure:failureHandler];
    } else {
        [GFNetworkManager getContentWithContentId:self.content.contentInfo.contentId
                                          keyFrom:self.keyFrom
                                          success:successHandler
                                          failure:failureHandler];
    }
}

- (void)fetchHotComments {
    
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager getHotCommentsByRelatedId:self.content.contentInfo.contentId
                                        success:^(NSUInteger taskId, NSInteger code, NSArray *comments, NSString *errorMessage) {
                                            if (code == 1) {
                                                if(comments){
                                                    weakSelf.hotComments = comments;
                                                    [weakSelf.contentCollectionView reloadData];
                                                }
                                            }
                                        } failure:^(NSUInteger taskId, NSError *error) {
                                            
                                        }];
}

- (void)fetchAllComments {
    
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager getCommentsWithContentId:self.content.contentInfo.contentId queryTime:self.nextQueryTime
                                       success:^(NSUInteger taskId, NSInteger code, NSArray *comments, NSNumber *nextQueryTime, NSString *errorMessage) {
                                           [weakSelf.contentCollectionView finishInfiniteScrolling];
                                           if (code == 1) {
                                               if (comments) {
                                                   [weakSelf.allComments addObjectsFromArray:comments];
                                                   weakSelf.nextQueryTime = nextQueryTime;
                                                   weakSelf.contentCollectionView.showsInfiniteScrolling = [nextQueryTime integerValue] != -1;
                                                   [weakSelf.contentCollectionView reloadData];
                                               }
                                           }
                                       } failure:^(NSUInteger taskId, NSError *error) {
                                           [weakSelf.contentCollectionView finishInfiniteScrolling];
                                       }];
}

#pragma mark - action
- (void)backBarButtonItemSelected {
    [MobClick event:@"gf_xq_01_02_18_1"];
    
    GFContentType type = self.content.contentInfo.type;
    switch (type) {
        case GFContentTypeArticle: {
            [MobClick event:@"gf_xq_01_02_18_1"];
            break;
        }
        case GFContentTypeVote: {
            [MobClick event:@"gf_xq_04_02_18_1"];
            break;
        }
        case GFContentTypeLink: {
            break;
        }
        case GFContentTypePicture: {
            break;
        }
        case GFContentTypeUnknown:{
            break;
        }
    }
    if (self.contentUpdateHandler) {
        self.contentUpdateHandler(self.content);
    }
    
//    [self.navigationController popViewControllerAnimated:YES];
    [super backBarButtonItemSelected];
}

- (void)commentBarItemAction:(UIBarButtonItem *)item {
    
    [self.shareViewController cancelAction];
        [MobClick event:@"gf_xq_01_02_07_1"];
    GFContentType type = self.content.contentInfo.type;
    if (type == GFContentTypeLink) {
        [MobClick event:@"gf_xq_03_02_07_1"];
        GFCommentListViewController *controller = [[GFCommentListViewController alloc] initWithContent:self.content];
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        [self.inputView.textView becomeFirstResponder];
        if (type == GFContentTypeArticle) {
            [self.articleView.articleWebView.scrollView scrollToBottom];
        }
        [self.contentCollectionView scrollToBottom];
    }
}

- (void)shareBarItemAction:(UIBarButtonItem *)item {
    [self.view endEditing:YES];
    [MobClick event:@"gf_xq_01_02_08_1"];
    
    GFContentType type = self.content.contentInfo.type;
    switch (type) {
        case GFContentTypeArticle: {
            [MobClick event:@"gf_xq_01_02_08_1"];
            break;
        }
        case GFContentTypeVote: {
            [MobClick event:@"gf_xq_04_02_08_1"];
            break;
        }
        case GFContentTypeLink: {
            break;
        }
        case GFContentTypePicture: {
            break;
        }
        case GFContentTypeUnknown:{
            break;
        }
    }
    
    [[self shareActivityViewControllerWithParams:nil] showIn:self];
}

- (void)moreBarItemAction:(UIBarButtonItem *)item {
    
    [self.view endEditing:YES];
    [self.shareViewController cancelAction];
    
    [MobClick event:@"gf_xq_01_02_15_1"];
    
    GFContentType type = self.content.contentInfo.type;
    switch (type) {
        case GFContentTypeArticle: {
            [MobClick event:@"gf_xq_01_02_15_1"];
            break;
        }
        case GFContentTypeVote: {
            [MobClick event:@"gf_xq_04_02_15_1"];
            break;
        }
        case GFContentTypeLink: {
//            GFContentDetailLinkMTL *linkModel = (GFContentDetailLinkMTL *)self.content.contentDetail;
            break;
        }
        case GFContentTypePicture: {
            break;
        }
        case GFContentTypeUnknown:{
            break;
        }
    }
    
    __weak typeof(self) weakSelf = self;
    UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:nil];
    BOOL isContentPoster = self.content.user.userId && [[GFAccountManager sharedManager].loginUser.userId isEqualToNumber:self.content.user.userId];
    if (isContentPoster) {
        [actionSheet bk_addButtonWithTitle:@"删除" handler:^{
            [MobClick event:@"gf_xq_01_02_16_1"];
            
            GFContentType type = weakSelf.content.contentInfo.type;
            switch (type) {
                case GFContentTypeArticle: {
                    [MobClick event:@"gf_xq_01_02_16_1"];
                    break;
                }
                case GFContentTypeVote: {
                    [MobClick event:@"gf_xq_04_02_16_1"];
                    break;
                }
                case GFContentTypeLink: {
                    break;
                }
                case GFContentTypePicture: {
                    break;
                }
                case GFContentTypeUnknown:{
                    break;
                }
            }
            
            [weakSelf deleteContent];
        }];
    } else {
        [actionSheet bk_addButtonWithTitle:@"举报" handler:^{
            [MobClick event:@"gf_xq_01_02_17_1"];
            
            GFContentType type = weakSelf.content.contentInfo.type;
            switch (type) {
                case GFContentTypeArticle: {
                    [MobClick event:@"gf_xq_01_02_17_1"];
                    break;
                }
                case GFContentTypeVote: {
                    [MobClick event:@"gf_xq_04_02_17_1"];
                    break;
                }
                case GFContentTypeLink: {
                    break;
                }
                case GFContentTypePicture: {
                    break;
                }
                case GFContentTypeUnknown:{
                    break;
                }
            }
            
            [weakSelf reportContent];
        }];
    }
    
    [actionSheet bk_setCancelButtonWithTitle:@"取消" handler:^{
        
    }];
    
    [actionSheet showInView:self.view];
}

#pragma mark - update request
- (void)addComment:(NSString *)text {
    if (text.length == 0) {
        return;
    }
    
    GFContentType type = self.content.contentInfo.type;
    switch (type) {
        case GFContentTypeArticle: {
            [MobClick event:@"gf_xq_01_02_06_1"];
            break;
        }
        case GFContentTypeVote: {
            [MobClick event:@"gf_xq_04_02_06_1"];
            break;
        }
        case GFContentTypeLink: {
            break;
        }
        case GFContentTypePicture: {
            break;
        }
        case GFContentTypeUnknown:{
            break;
        }
    }
    __weak typeof(self) weakSelf = self;
    [GFAccountManager checkLoginStatus:YES
                       loginCompletion:^(BOOL justLogin, GFUserMTL *user) {
                           if (user) {
                               
                               [GFNetworkManager addCommentWithRelateId:weakSelf.content.contentInfo.contentId content:text parentId:nil success:^(NSUInteger taskId, NSInteger code, GFCommentMTL *comment, NSString *errorMessage) {
                                   if (code == 1) {
                                       if (comment) {
                                           [weakSelf.allComments insertObject:comment atIndex:0];
                                           [weakSelf.contentCollectionView reloadData];
                                           
                                           weakSelf.content.contentInfo.commentCount = @([weakSelf.content.contentInfo.commentCount unsignedIntegerValue] + 1);
                                           [weakSelf.commentNumButton setTitle:[NSString stringWithFormat:@"%@", weakSelf.content.contentInfo.commentCount] forState:UIControlStateDisabled];
                                           
                                           //首页评论数更新回调
                                           if (weakSelf.commentAndFunHandler) {
                                               weakSelf.commentAndFunHandler(weakSelf.content);
                                           }
                                           
                                           //评论后弹到顶部查看
                                           [weakSelf.contentCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
                                           
                                           
                                           [MBProgressHUD showHUDWithTitle:@"评论成功！" duration:kCommonHudDuration inView:self.view];
                                       }

                                   } else {
                                       NSString *msg = [errorMessage length] > 0 ? errorMessage : @"添加评论失败";
                                       [MBProgressHUD showHUDWithTitle:msg duration:kCommonHudDuration inView:weakSelf.view];
                                   }
                               } failure:^(NSUInteger taskId, NSError *error) {
                                   [MBProgressHUD showHUDWithTitle:@"网络失败" duration:kCommonHudDuration inView:weakSelf.view];
                               }];
                               
                           } else {
                               [MBProgressHUD showHUDWithTitle:@"登录后才能评论" duration:kCommonHudDuration inView:weakSelf.view];
                           }
                       }];
}

- (void)setContentFunned {
    [MobClick event:@"gf_xq_01_02_02_1"];
    
    NSInteger count = [self.content.contentInfo.funCount integerValue];
    
    GFContentActionStatus *funActionStatus = [self.content.actionStatuses objectForKey:GFContentMTLActionStatusesKeyFun];
    funActionStatus.count = @1;
    
    NSInteger totalFunCount = count + 1;
    self.inputView.funCount = totalFunCount;
    self.inputView.funned = YES;
    self.content.contentInfo.funCount = @(totalFunCount);
    if (self.commentAndFunHandler) {
        self.commentAndFunHandler(self.content);
    }
    
    NSMutableArray *funUsers = [self.content.funUsers mutableCopy];
    if (!funUsers) {
        funUsers = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    GFUserMTL *user = [GFAccountManager sharedManager].loginUser;
    if (user) {
        self.content.funUsers = [@[user] arrayByAddingObjectsFromArray:funUsers];
        [self.contentCollectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
    }
}

- (void)funContent {
    
    BOOL funned = [self.content isFunned]; // 一定应是NO
    if (funned) return;
    
    [GFNetworkManager changeFunStatusWithContentId:self.content.contentInfo.contentId isFun:!funned success:^(NSUInteger taskId, NSInteger code, NSString *errorMessage) {

    } failure:^(NSUInteger taskId, NSError *error) {

    }];
}

- (void)funComment:(GFCommentMTL *)comment inCell:(GFUserCommentCell *)cell {
    
    if (!comment || comment.loginUserHasFuned) return;
    
    [GFAccountManager checkLoginStatus:YES
                       loginCompletion:^(BOOL justLogin, GFUserMTL *user) {
                           if (user) {
                               [GFNetworkManager addFunWithCommentId:comment.commentInfo.commentId success:^(NSUInteger taskId, NSInteger code, NSString *errorMessage) {
                                   if (code == 1) {
                                       comment.loginUserHasFuned = YES;
                                       comment.commentInfo.funCount = @([comment.commentInfo.funCount integerValue] + 1);
                                       [cell bindWithModel:comment];
                                       
                                       [cell.userInfoHeader doFunAnimation];
                                       
                                   } else {
                                       NSString *msg = [errorMessage length] > 0 ? errorMessage : @"添加评论失败";
                                       [MBProgressHUD showHUDWithTitle:msg duration:kCommonHudDuration inView:self.view];
                                   }
                               } failure:^(NSUInteger taskId, NSError *error) {
                                   [MBProgressHUD showHUDWithTitle:@"网络失败" duration:kCommonHudDuration inView:self.view];
                               }];
                           } else {
                               [MBProgressHUD showHUDWithTitle:@"登录后才能Fun" duration:kCommonHudDuration inView:self.view];
                           }
                       }];
}

- (void)reportContent {
    [GFNetworkManager reportContentWithContentId:self.content.contentInfo.contentId reportInfo:nil success:^(NSUInteger taskId, NSInteger code, NSString *errorMessage) {
        if (code == 1) {
            [MBProgressHUD showHUDWithTitle:@"举报成功" duration:kCommonHudDuration inView:self.view];
        } else {
            [MBProgressHUD showHUDWithTitle:errorMessage duration:kCommonHudDuration inView:self.view];
        }
    } failure:^(NSUInteger taskId, NSError *error) {
        [MBProgressHUD showHUDWithTitle:@"网络失败" duration:kCommonHudDuration inView:self.view];
    }];
}

- (void)deleteContent {
    
    __weak typeof(self) weakSelf = self;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDWithTitle:@"正在删除..." inView: self.view];
    [GFNetworkManager deleteContentWithContentId:self.content.contentInfo.contentId success:^(NSUInteger taskId, NSInteger code, NSString *errorMessage) {
        
        if (code == 1) {
            hud.labelText = @"删除成功";
            [hud hide:YES afterDelay:kCommonHudDuration];
            
            if (weakSelf.deleteContentHandler) {
                weakSelf.deleteContentHandler(weakSelf.content);
            }
            
            [weakSelf.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:@(YES) afterDelay:0.5f];
        } else {
            hud.labelText = errorMessage;
            [hud hide:YES afterDelay:kCommonHudDuration];
        }
    } failure:^(NSUInteger taskId, NSError *error) {
        hud.labelText = @"网络失败";
        [hud hide:YES afterDelay:kCommonHudDuration];
    }];
}

- (void)chooseVoteItem:(GFVoteItemMTL *)voteItem {
    
    NSArray *voteItems = [(GFContentDetailVoteMTL *)self.content.contentDetail voteItems];
    GFVoteItemMTL *leftItem = voteItems[0];
    GFVoteItemMTL *rightItem = voteItems[1];
    BOOL left = leftItem.voteItemId && [voteItem.voteItemId isEqualToNumber:leftItem.voteItemId];
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager voteWithContentId:self.content.contentInfo.contentId voteItemId:voteItem.voteItemId success:^(NSUInteger taskId, NSInteger code, NSString *errorMessage) {
        if (code == 1) {
            GFContentActionStatus *voteActionStatus = weakSelf.content.actionStatuses[GFContentMTLActionStatusesKeySpecial];
            voteActionStatus.count = @1;
            if (left) {
                leftItem.supportCount = @([leftItem.supportCount integerValue] + 1);
                voteActionStatus.relatedId = leftItem.voteItemId;
            } else {
                rightItem.supportCount = @([rightItem.supportCount integerValue] + 1);
                voteActionStatus.relatedId = rightItem.voteItemId;
            }
            [weakSelf.voteView updateContent:weakSelf.content animate:YES];
            if (weakSelf.voteHandler) {
                weakSelf.voteHandler(weakSelf.content, left);
            }
        } else {
            [MBProgressHUD showHUDWithTitle:errorMessage duration:kCommonHudDuration inView:self.view];
        }
    } failure:^(NSUInteger taskId, NSError *error) {
        [MBProgressHUD showHUDWithTitle:@"网络失败" duration:kCommonHudDuration inView:self.view];
    }];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    //依次为顶部、中间user和分享、热门评论、全部评论
    return 4;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger numberOfItems = 0;
    switch (section) {
        case 0:{
            numberOfItems = 0; //只利用该区域的header
            break;
        }
        case 1:{
            if ([self.content.funUsers count] == 0) {
                numberOfItems = 1;
            } else {
                numberOfItems = 2;
            }
            break;
        }
        case 2:{
            numberOfItems = [self.hotComments count];
            break;
        }
        case 3:{
            numberOfItems = [self.allComments count];
            break;
        }
    }
    return numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    __weak typeof(self) weakSelf = self;
    UICollectionViewCell *cell = nil;
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFContentDetailShareView class]) forIndexPath:indexPath];
            [(GFContentDetailShareView *)cell setShareHandler:^(GFShareType type) {
                [weakSelf shareWithType:type];
            }];
        } else {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFContentDetailFunUsersView class]) forIndexPath:indexPath];
            [(GFContentDetailFunUsersView *)cell bindWithModel:self.content];
            [(GFContentDetailFunUsersView *)cell setFunUserAvatarHandler:^(GFUserMTL *user) {
                [MobClick event:@"gf_xq_01_04_01_1"];
                GFProfileViewController *profileViewController = [[GFProfileViewController alloc] initWithUserID:user.userId];
                [weakSelf.navigationController pushViewController:profileViewController animated:YES];
            }];
        }
    } else { 
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFUserCommentCell class]) forIndexPath:indexPath];
        GFCommentMTL *comment = nil;
        if (indexPath.section == 2) {
            comment = [self.hotComments objectAtIndex:indexPath.row];
        } else if(indexPath.section == 3) {
            comment = [self.allComments objectAtIndex:indexPath.row];
        }
        
        [[(GFUserCommentCell *)cell userInfoHeader] setStyle:GFUserInfoHeaderStyleDateAndFun];
        [(GFUserCommentCell *)cell setShouldShowReplyInfo:YES];
        [(GFUserCommentCell *)cell bindWithModel:comment
                                   contentUserId:self.content.user.userId];
        
        @weakify(self)
        [(GFUserCommentCell *)cell setTapImageHandler:^(GFUserCommentCell *cell, NSUInteger iniImageIndex) {
            [MobClick event:@"gf_xq_06_04_01_1"];
            @strongify(self)
            
            NSDictionary *picturySummary = nil;
            NSArray *orderKeys = nil;
            NSString *iniPictureKey = nil;
            if ([comment.commentInfo.pictureKeys count] > 0) {
                picturySummary = comment.pictures;
                orderKeys = comment.commentInfo.pictureKeys;
                iniPictureKey = [orderKeys objectAtIndex:iniImageIndex];
            } else {
                picturySummary = comment.emotions;
                orderKeys = comment.commentInfo.emotionIds;
                iniPictureKey = [orderKeys objectAtIndex:iniImageIndex];
            }
            
            GFImageGroupView *imageGroupView = [[GFImageGroupView alloc] initWithImages:picturySummary
                                                                                             orderKeys:orderKeys
                                                                                            initialKey:iniPictureKey
                                                delegate:cell];
            [imageGroupView presentToContainer:self.view.window animated:YES completion:nil];
        }];
        
        __weak typeof(cell) weakCell = cell;
        [[(GFUserCommentCell *)cell userInfoHeader] setFunHandler:^{
            [GFAccountManager checkLoginStatus:YES
                               loginCompletion:^(BOOL justLogin, GFUserMTL *user) {
                                   if (user) {
                                       [MobClick event:@"gf_xq_01_03_02_1"];
                                       
                                       [GFNetworkManager addFunWithCommentId:comment.commentInfo.commentId success:^(NSUInteger taskId, NSInteger code, NSString *errorMessage) {
                                           if (code == 1) {
                                               comment.loginUserHasFuned = YES;
                                               comment.commentInfo.funCount = @([comment.commentInfo.funCount integerValue] + 1);
                                               [(GFUserCommentCell *)cell bindWithModel:comment
                                                                          contentUserId:weakSelf.content.user.userId];
                                               
                                               [[(GFUserCommentCell *)weakCell userInfoHeader] doFunAnimation];
                                               
                                           } else {
///  errorMessage：不能重复点fun
                                               NSString *msg = [errorMessage length] > 0 ? errorMessage : @"添加评论失败";
                                                [MBProgressHUD showHUDWithTitle:msg duration:kCommonHudDuration inView:self.view];
                                           }
                                       } failure:^(NSUInteger taskId, NSError *error) {
                                           [MBProgressHUD showHUDWithTitle:@"网络失败" duration:kCommonHudDuration inView:self.view];
                                       }];
                                       
                                   } else {
                                       [MBProgressHUD showHUDWithTitle:@"登录后才能Fun" duration:kCommonHudDuration inView:self.view];
                                   }
                               }];
        }];
        
        [[(GFUserCommentCell *)cell userInfoHeader] setAvatarHandler:^{
            GFUserMTL *user = comment.user;
            GFProfileViewController *profileViewController = [[GFProfileViewController alloc] initWithUserID:user.userId];
            [self.navigationController pushViewController:profileViewController animated:YES];
        }];
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *supplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([GFContentDetailHeaderFooter class]) forIndexPath:indexPath];
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) { //Header
        if (indexPath.section == 0) {
            GFContentType type = self.content.contentInfo.type;
            if (type == GFContentTypeArticle) {
                [supplementaryView addSubview:self.articleView];
            } else if (type == GFContentTypeVote) {
                [supplementaryView addSubview:self.voteView];
            } else {
                [supplementaryView addSubview:self.pictureView];
            }
        } else {
            UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, supplementaryView.width, supplementaryView.height-10)];
            bgView.backgroundColor = [UIColor whiteColor];
            [supplementaryView addSubview:bgView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.font = [UIFont boldSystemFontOfSize:15];
            label.textColor = [UIColor blackColor];
            
            if (indexPath.section == 2) {
                label.text = @"热门评论";
            } else  if(indexPath.section == 3){
                label.text = [NSString stringWithFormat:@"全部评论(%@)", self.content.contentInfo.commentCount];
            }
            [label sizeToFit];
            label.center = CGPointMake(17 + label.width/2, bgView.height/2);
            [bgView addSubview:label];
        }
    } else { //Footer
        if (indexPath.section == 1) {
            if ([self.hotComments count] == 0 && [self.allComments count] == 0) {
                GFContentDetailNoCommentView *noCommentView = [[GFContentDetailNoCommentView alloc] initWithFrame:supplementaryView.bounds];
                [supplementaryView addSubview:noCommentView];
            }
        } else if(indexPath.section == 3) {
            UIView *footer = [[UIView alloc] initWithFrame:supplementaryView.bounds];
            [supplementaryView addSubview:footer];
        }
    }
    return supplementaryView;
}

#pragma mark - UICollectionViewFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    CGSize size = CGSizeZero;
    if (section == 0) {
        GFContentType type = self.content.contentInfo.type;
        if (type == GFContentTypeArticle) {
            size = CGSizeMake(collectionView.width, self.articleView.height);
        } else if (type == GFContentTypeVote) {
            size = CGSizeMake(collectionView.width, self.voteView.height);
        } else if (type == GFContentTypePicture) {
            size = CGSizeMake(collectionView.width, self.pictureView.height);
        }
    } else if (section == 2 && [self.hotComments count] > 0) { //热门评论
        size = CGSizeMake(collectionView.width, 50);
    } else if (section == 3 && [self.allComments count] > 0) { //全部评论
        size = CGSizeMake(collectionView.width, 50);
    }
    return size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    CGSize size = CGSizeZero;
    if (section == 1 && [self.hotComments count] == 0 && [self.allComments count] == 0) { // 没有评论时底部占位
        size = CGSizeMake(collectionView.width, 320);
    } else if(section == 3 && ([self.hotComments count] > 0 || [self.allComments count] > 0)) { //有评论时底部才添加footer
        size = CGSizeMake(collectionView.width, kInputViewHeight + 10);
    }
    
    return size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 0;
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            height = [GFContentDetailShareView heightWithModel:nil];
        } else {
            height = [GFContentDetailFunUsersView heightWithModel:nil];
        }
    } else {
        GFCommentMTL *comment = nil;
        if (indexPath.section == 2 && [self.hotComments count] > 0) {
            comment = [self.hotComments objectAtIndex:indexPath.row];
        } else if(indexPath.section == 3 && [self.allComments count] > 0) {
            comment = [self.allComments objectAtIndex:indexPath.row];
        }
        height = [GFUserCommentCell heightWithModel:comment
                                             indent:NO
                                shouldShowReplyInfo:YES];
    }
    return CGSizeMake(collectionView.width, height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 || indexPath.section == 1) return;
    
    static BOOL isHotComment = NO;
    
    [MobClick event:@"gf_xq_01_03_01_1"];

    GFCommentMTL *comment = nil;
    if (indexPath.section == 2 && [self.hotComments count] > 0) {
        comment = [self.hotComments objectAtIndex:indexPath.row];
        isHotComment = YES;
    } else {
        comment = [self.allComments objectAtIndex:indexPath.row];
        isHotComment = NO;
    }
    
    if (comment) {
        GFCommentDetailViewController *controller = [[GFCommentDetailViewController alloc] initWithRootCommentId:comment.commentInfo.commentId contentId:self.content.contentInfo.contentId];
        
        __weak typeof(self) weakSelf = self;
        
        controller.funHandler = ^(GFCommentMTL *newComment){
            //注意：不能直接替换，该block回调的newComment由fetchRootComment而来，不含有childComment信息，直接替换会导致childComment信息消失
            NSInteger index = -1;
            if (isHotComment) {
                if ([weakSelf.hotComments containsObject:newComment]) {
                    index = [weakSelf.hotComments indexOfObject:newComment];
                    GFCommentMTL *origin = [weakSelf.hotComments objectAtIndex:index];
                    origin.loginUserHasFuned = newComment.loginUserHasFuned;
                    origin.commentInfo.funCount = newComment.commentInfo.funCount;
                }
            } else {
                if ([weakSelf.allComments containsObject:newComment]) {
                    index = [weakSelf.allComments indexOfObject:newComment];
                    GFCommentMTL *origin = [weakSelf.allComments objectAtIndex:index];
                    origin.loginUserHasFuned = newComment.loginUserHasFuned;
                    origin.commentInfo.funCount = newComment.commentInfo.funCount;                    
                }
            }
            [weakSelf.contentCollectionView reloadItemsAtIndexPaths:@[indexPath]];
        };
                
        controller.childCommentHandler = ^(GFCommentMTL *parentComment, GFCommentMTL *childComment) {
            NSInteger index = -1;
            if (isHotComment) {
                if ([weakSelf.hotComments containsObject:parentComment]) {
                    index = [weakSelf.hotComments indexOfObject:parentComment];
                    GFCommentMTL *origin = [weakSelf.hotComments objectAtIndex:index];
                    origin = parentComment;
                }
            } else {
                if ([weakSelf.allComments containsObject:parentComment]) {
                    index = [weakSelf.allComments indexOfObject:parentComment];
                    [[weakSelf allComments] replaceObjectAtIndex:index withObject:parentComment];
                }
            }
            [weakSelf.contentCollectionView reloadItemsAtIndexPaths:@[indexPath]];
        };
        
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    [(GFWebView *)webView setCookieIfNeeded:request.URL.absoluteString];
    
    NSString *scheme = [[request.URL scheme] lowercaseString];
    if ([scheme isEqualToString:GFGetfunRedirectShare]) {
        // getfun://share?title=xxx&shortTitle=xxx&desc=xxx&img=xxx&url=xxx
        // 处理分享
        
        NSDictionary *parametersForShare = [request.URL.absoluteString urlQueryToDictionary];
        if ([parametersForShare count] > 0) {
            [[self shareActivityViewControllerWithParams:parametersForShare] showIn:self];
        }
        return NO;
    } else if ([scheme isEqualToString:@"getfun"]) {
        [[AppDelegate appDelegate] handleGetfunLinkUrl:request.URL.absoluteString];
        return NO;
    }
    
    NSURL *url = request.URL;
    if ([url.scheme isEqualToString:@"file"] || [url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]) {
        return YES;
    }
    
    return NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
#pragma mark- 优化webView
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitDiskImageCacheEnabled"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitOfflineWebApplicationCacheEnabled"];  [[NSUserDefaults standardUserDefaults] synchronize];
    GFContentType type = self.content.contentInfo.type;
    
    __weak typeof(self) weakSelf = self;
    if (type == GFContentTypeArticle) {

        self.articleView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        self.articleView.articleWebView.frame = weakSelf.articleView.bounds;

        [self.bridge callHandler:@"getData" data:self.contentData responseCallback:^(id responseData) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[responseData dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            
            CGFloat jsContentHeight = [[dict objectForKey:@"height"] floatValue];
            CGFloat updateWebviewHeight = MIN(jsContentHeight, SCREEN_HEIGHT);
            
            weakSelf.articleView.frame = CGRectMake(0, 0, SCREEN_WIDTH, updateWebviewHeight);
            weakSelf.articleView.articleWebView.frame = weakSelf.articleView.bounds;

            [weakSelf.contentCollectionView reloadData];
            
            [weakSelf setupFunctionViews];
            
            weakSelf.imagesForArticle = [[dict objectForKey:@"imgMap"] mutableCopy];
            NSMutableArray *imageOrderKeys = [[NSMutableArray alloc] initWithCapacity:[weakSelf.imagesForArticle count]];
            for (NSDictionary *imageInfo in weakSelf.imagesForArticle) {
                NSString *storeKey = [imageInfo objectForKey:@"key"];
                [imageOrderKeys addObject:storeKey];
            }
            weakSelf.imageOrderKeys = imageOrderKeys;
            
            [weakSelf checkUpdateImageWithOffset:weakSelf.articleView.articleWebView.scrollView.contentOffset];
            
            if (!weakSelf.preview) {
                [weakSelf fetchHotComments];
                [weakSelf fetchAllComments];
            }
            
            [weakSelf prepareImageForShare:weakSelf.content];
            
        }];
        
    } else if (type == GFContentTypeLink) {
        [self setupFunctionViews];
    }
}

#pragma mark - 评论输入框
- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView {
    [MobClick event:@"gf_xq_01_02_03_1"];
    
    GFLoginType type = [GFAccountManager sharedManager].loginType;
    __weak typeof(self) weakSelf = self;
    if (type == GFLoginTypeAnonymous || type == GFLoginTypeNone) {
        [GFAccountManager checkLoginStatus:YES loginCompletion:^(BOOL justLogin, GFUserMTL *user) {
            if (user) {
                [MobClick event:@"gf_xq_01_02_04_1"];
                [weakSelf.inputView.textView becomeFirstResponder];
            } else {
                [MobClick event:@"gf_xq_01_02_05_1"];
            }
        }];
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView {
    [MobClick event:@"gf_xq_01_02_06_1"];
    
    NSString *text = growingTextView.text;
    if ([[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        [MBProgressHUD showHUDWithTitle:@"评论不能为空" duration:kCommonHudDuration inView:self.view];
        return YES;
    }else if([text length] > 1000){
        [MBProgressHUD showHUDWithTitle:@"评论不能超过1000字" duration:kCommonHudDuration inView:self.view];
        return YES;
    }
    growingTextView.text = nil;
    [self.view endEditing:YES];
    
    [self addComment:text];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:1];
    [self.contentCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    
    return YES;
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
    
    CGFloat deltaHeight = height - growingTextView.height; 
    
    CGRect rect = self.inputView.frame;
    CGRect frame = CGRectMake(CGRectGetMinX(rect), CGRectGetMaxY(rect) - CGRectGetHeight(rect) - deltaHeight, CGRectGetWidth(rect), CGRectGetHeight(rect) + deltaHeight);
    self.inputView.frame = frame;
}

- (NTESActivityViewController *)shareActivityViewControllerWithParams:(NSDictionary *)params {
    
    NTESWeixinSessionShareActivity *weixinSession = [self getWeixinSessionActivityWithParams:params];
    NTESWeixinTimelineShareActivity *weixinTimeline = [self getWeixinTimelineActivityWithParams:params];
    NTESSinaWeiboShareActivity *sinaWeibo = [self getSinaWeiboActivityWithParams:params];
    NTESQQSessionShareActivity *qq = [self getQQSessionActivityWithParams:params];
    NTESQzoneShareActivity *qzone = [self getQzoneActivityWithParams:params];
    GFCopyUrlActionActivity *copy = [self getCopyUrlActionActivityWithParams:params];
    
    NSArray *activities = @[weixinSession, weixinTimeline, sinaWeibo, qq, qzone, copy];
    self.shareViewController.applicationActivities = activities;
    
    __weak typeof(self) weakSelf = self;
    self.shareViewController.completionHandler = ^(NSString *activityType, BOOL completed) {
        if (activityType) {
            [GFNetworkManager didShareContentWithContentId:weakSelf.content.contentInfo.contentId shareType:activityType];
        }
        
        if (!activityType) { //复制链接
            if (completed) {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
                hud.labelText = @"已经复制到剪贴板";
                hud.mode = MBProgressHUDModeText;
                hud.removeFromSuperViewOnHide  =YES;
                hud.userInteractionEnabled = NO;
                [hud hide:YES afterDelay:kCommonHudDuration];
                
            }
            [MobClick event:@"gf_xq_01_02_14_1"];
        } else {
            GFShareType shareType = [activityType gf_shareType];
            switch (shareType) {
                case GFShareTypeQQ: {
                    [MobClick event:@"gf_xq_01_02_10_1"];
                    break;
                }
                case GFShareTypeQZone: {
                    [MobClick event:@"gf_xq_01_02_09_1"];
                    break;
                }
                case GFShareTypeWeChat: {
                    [MobClick event:@"gf_xq_01_02_11_1"];
                    break;
                }
                case GFShareTypeTimeline: {
                    [MobClick event:@"gf_xq_01_02_12_1"];
                    break;
                }
                case GFShareTypeWeibo: {
                    [MobClick event:@"gf_xq_01_02_13_1"];
                    break;
                }
            }
            
        }
    };
    
    return self.shareViewController;
}

#pragma mark - share activity
- (NTESWeixinSessionShareActivity *)getWeixinSessionActivityWithParams:(NSDictionary *)params {
    
    
    return [[NTESWeixinSessionShareActivity alloc] initWithURL:[self urlForShareType:GFShareTypeWeChat]
                                                         image:nil
                                                    thumbImage:[self thumbImageForShareType:GFShareTypeWeChat]
                                                         title:[self titleForShareType:GFShareTypeWeChat]
                                                   description:[self descriptionForShareType:GFShareTypeWeChat]];
}

- (NTESWeixinTimelineShareActivity *)getWeixinTimelineActivityWithParams:(NSDictionary *)params {
    
    return [[NTESWeixinTimelineShareActivity alloc] initWithURL:[self urlForShareType:GFShareTypeTimeline]
                                                          image:nil
                                                     thumbImage:[self thumbImageForShareType:GFShareTypeTimeline]
                                                          title:[self titleForShareType:GFShareTypeTimeline]
                                                    description:nil];
}

- (NTESQQSessionShareActivity *)getQQSessionActivityWithParams:(NSDictionary *)params {
    
    return [[NTESQQSessionShareActivity alloc] initWithURL:[self urlForShareType:GFShareTypeQQ]
                                                     image:nil
                                                thumbImage:[self thumbImageForShareType:GFShareTypeQQ]
                                                     title:[self titleForShareType:GFShareTypeQQ]
                                               description:[self descriptionForShareType:GFShareTypeQQ]];
}

- (NTESQzoneShareActivity *)getQzoneActivityWithParams:(NSDictionary *)params {
    
    return [[NTESQzoneShareActivity alloc] initWithURL:[self urlForShareType:GFShareTypeQZone]
                                                 image:nil
                                            thumbImage:[self thumbImageForShareType:GFShareTypeQZone]
                                                 title:[self titleForShareType:GFShareTypeQZone]
                                           description:[self descriptionForShareType:GFShareTypeQZone]];
}

- (NTESSinaWeiboShareActivity *)getSinaWeiboActivityWithParams:(NSDictionary *)params {
    
//    return [[NTESSinaWeiboShareActivity alloc] initWithURL:@"http://www.baidu.com"
//                                                     image:[UIImage imageNamed:@"icon_qq"]
//                                                thumbImage:[UIImage imageNamed:@"icon_qq"]
//                                                     title:@"titletitletitletitletitle"
//                                               description:@"descriptiondescriptiondescriptiondescription"];
    
    return [[NTESSinaWeiboShareActivity alloc] initWithURL:[self urlForShareType:GFShareTypeWeibo]
                                                     image:[self thumbImageForShareType:GFShareTypeWeibo]
                                                thumbImage:[self thumbImageForShareType:GFShareTypeWeibo]
                                                     title:[self titleForShareType:GFShareTypeWeibo]
                                               description:[self descriptionForShareType:GFShareTypeWeibo]];
}

- (GFCopyUrlActionActivity *)getCopyUrlActionActivityWithParams:(NSDictionary *)params {
    NSString *url = [NSString stringWithFormat:@"%@/publish/detail?id=%@",GF_API_BASE_URL, self.content.contentInfo.contentId];
    GFCopyUrlActionActivity *activity = [[GFCopyUrlActionActivity alloc] initWithUrl:url];
    return activity;
}

- (NSString *)urlForShareType:(GFShareType)type {
    NSString *url = [NSString stringWithFormat:@"%@/publish/detail?id=%@",GF_API_BASE_URL, self.content.contentInfo.contentId];
    return url;
//    NSString *url = [GF_API_BASE_URL stringByAppendingPathComponent:[NSString stringWithFormat:@"publish/detail?id=%@", self.content.contentInfo.contentId]];
//    return url;
}

- (UIImage *)imageForShareType:(GFShareType)type {

    return self.shareImage ? self.shareImage : [UIImage imageNamed:@"default_share_logo"];
}

- (UIImage *)thumbImageForShareType:(GFShareType)type {
    
    return [self imageForShareType:type];
}

- (NSString *)titleForShareType:(GFShareType)type {
    
    NSString *title = self.content.contentDetail.title;
    GFContentType contentType = self.content.contentDetail.type;
    switch (contentType) {
        case GFContentTypeArticle: {
            //
            break;
        }
        case GFContentTypeVote: {
            //
            break;
        }
        case GFContentTypeLink: {
            if (!title || [title length] == 0) {
                title = @"分享了一个链接";
            }
            break;
        }
        case GFContentTypePicture: {
            if (!title || [title length] == 0) {
                
                GFContentDetailPictureMTL *pictureDetailMTL = (GFContentDetailPictureMTL *)self.content.contentDetail;
                title = [NSString stringWithFormat:@"包含%lu张图片", (unsigned long)[pictureDetailMTL.pictureSummary count]];
            }
            break;
        }
        case GFContentTypeUnknown:{
            break;
        }
    }
    
    if ([title length] > 120) {
        title = [title substringToIndex:120];
    }
    
    return title;
}

- (NSString *)descriptionForShareType:(GFShareType)type {
    
    NSString *desc = @" ";
    
    GFContentType contentType = self.content.contentInfo.type;
    switch (contentType) {
        case GFContentTypeArticle: {
            GFContentDetailArticleMTL *articleModel = (GFContentDetailArticleMTL *)self.content.contentDetail;
            if (articleModel.summary) {
                desc = articleModel.summary;
                if (type == GFShareTypeWeibo) {
                    desc = [desc stringByAppendingString:[self urlForShareType:GFShareTypeWeibo]];
                }
            }
            break;
        }
        case GFContentTypeVote: {
            GFContentDetailVoteMTL *voteDetail = (GFContentDetailVoteMTL *)self.content.contentDetail;
            NSArray *voteItems = voteDetail.voteItems;
            GFVoteItemMTL *leftItem = [voteItems objectAtIndex:0];
            GFVoteItemMTL *rightItem = [voteItems objectAtIndex:1];
            desc = [NSString stringWithFormat:@"%@ %@, 你选哪一个？", leftItem.title, rightItem.title];
            if (type == GFShareTypeWeibo) {
                desc = [desc stringByAppendingString:[self urlForShareType:GFShareTypeWeibo]];
            }
            break;
        }
        case GFContentTypeLink: {
            GFContentDetailLinkMTL *linkDetail = (GFContentDetailLinkMTL *)self.content.contentDetail;
            desc = linkDetail.url;
            break;
        }
        case GFContentTypePicture: {
            GFContentDetailPictureMTL *pictureDetail = (GFContentDetailPictureMTL *)self.content.contentDetail;
            NSString *title = self.content.contentDetail.title;
            NSUInteger count = [pictureDetail.pictureSummary count];
            if(title) {
                desc = title;
            } else if(count > 0) {
                desc = [desc stringByAppendingString:[NSString stringWithFormat:@"分享了%@张图片", @(count)]];
            }
            if (type == GFShareTypeWeibo) {
                desc = [desc stringByAppendingString:[self urlForShareType:GFShareTypeWeibo]];
            }
            break;
        }
        case GFContentTypeUnknown:{
            break;
        }
    }
    
    if ([desc length] > 500) {
        desc = [desc substringToIndex:500];
    }
    
    return desc;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    __weak typeof(self) weakSelf = self;
    
    static CGFloat lastWebViewOffsetY = 0;
    static CGFloat lastCollectionViewOffsetY = 0;

    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat lastOffsetY = 0;
    
    if ([scrollView isKindOfClass:[UICollectionView class]]) {
        lastOffsetY = lastCollectionViewOffsetY;
    } else {
        lastOffsetY = lastWebViewOffsetY;
    }
    
    if (![self.inputView.textView isFirstResponder] && !self.inputView.hidden) {
        // 视图向上滚动
        if (offsetY > lastOffsetY) {
            if ([scrollView isKindOfClass:[UICollectionView class]] && offsetY == scrollView.contentSize.height - self.view.height) {
                [UIView animateWithDuration:0.2f animations:^{
                    weakSelf.inputView.bottom = SCREEN_HEIGHT;
                    [weakSelf gf_setNavBarShrink:NO];
                }];
            } else {
                [UIView animateWithDuration:0.2f animations:^{
                    weakSelf.inputView.y = SCREEN_HEIGHT;
                    [weakSelf gf_setNavBarShrink:YES];
                }];
            }
        } else { //向下滚动
            [UIView animateWithDuration:0.2f animations:^{
                weakSelf.inputView.bottom = SCREEN_HEIGHT;
                [weakSelf gf_setNavBarShrink:NO];
            }];
        }
    }
    
    if ([scrollView isKindOfClass:[UICollectionView class]]) {
        lastCollectionViewOffsetY = offsetY;
    } else {
        lastWebViewOffsetY = offsetY;
    }
    
    // 图文帖scrollview的enable / disable逻辑
    GFContentType type = self.content.contentInfo.type;
    if (type == GFContentTypeArticle) {
        if (scrollView == self.contentCollectionView) {
            self.articleView.articleWebView.scrollView.scrollEnabled = (offsetY == 0);
        }
    }
    
//    //沉浸式阅读滑动速度较慢时上方导航栏不显示，手动显示
//    if (self.content.contentInfo.type == GFContentTypeArticle || self.content.contentInfo.type == GFContentTypePicture){
//        if (offsetY < 10 && [self.navigationController respondsToSelector:@selector(setHidesBarsOnSwipe:)]) {
//                [self.navigationController setNavigationBarHidden:NO animated:YES];
//        }
//    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    GFContentType type = self.content.contentInfo.type;
    if (type == GFContentTypeArticle && ![scrollView isKindOfClass:[UICollectionView class]]) {
        // 图文帖，滚动的是UIWebView, 检查图片加载
        
        [self checkUpdateImageWithOffset:(*targetContentOffset)];
    }
}

- (void)checkUpdateImageWithOffset:(CGPoint)offset {
    
    // offset是webview的当前偏移量
    CGFloat sensitifity = 300;
    CGFloat visibleTop = self.articleView.articleWebView.scrollView.contentOffset.y - sensitifity;
    CGFloat visibleBottom = self.articleView.articleWebView.scrollView.contentOffset.y + self.articleView.articleWebView.height + sensitifity;
    
    @synchronized (self) {
        NSMutableArray *imgsToDownload = [[NSMutableArray alloc] initWithCapacity:0];
        
        // 找到符合条件需要下载的图片
        for (NSDictionary *dict in self.imagesForArticle) {
            CGFloat imgTop = [[dict objectForKey:@"top"] floatValue];
            CGFloat imgBottom = imgTop + [[dict objectForKey:@"height"] floatValue];
            if (imgTop < visibleBottom && imgBottom > visibleTop) {
                [imgsToDownload addObject:dict];
            }
        }
        
        // 对每个图片进行下载
        for (NSDictionary *dict in imgsToDownload) {
            NSString *imgKey = [dict objectForKey:@"key"];
            GFPictureMTL *picture = [self.content.pictures objectForKey:imgKey];
            AFNetworkReachabilityStatus status = [GFNetworkStatusUtil networkStatus];
            NSString *url = [picture.url gf_urlStandardizedWithType:GFImageStandardizedTypeContentDetailArticle gifConverted:(status != AFNetworkReachabilityStatusReachableViaWiFi && picture.format == GFPictureFormatGIF)];
            NSString *fileName = [url md5String];
            NSString *tmpPath = NSTemporaryDirectory();
            NSString *destPath = [tmpPath stringByAppendingPathComponent:fileName];
            if ([[NSFileManager defaultManager] fileExistsAtPath:destPath]) {
                [self updateImage:dict path:destPath];
            } else {
                [[YYWebImageManager sharedManager] requestImageWithURL:[NSURL URLWithString:url]
                                                               options:YYWebImageOptionShowNetworkActivity
                                                              progress:NULL
                                                             transform:NULL
                                                            completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                                                if (image) {
                                                                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                                                        
                                                                        NSData *data = [image imageDataRepresentation];
                                                                        [data writeToFile:destPath options:NSDataWritingWithoutOverwriting error:nil];
                                                                        dispatch_async(                                                                    dispatch_get_main_queue(), ^{
                                                                            [self updateImage:dict path:destPath];
                                                                        });
                                                                    });
                                                                }
                                                            }];
            }
        }
        
        [self.imagesForArticle removeObjectsInArray:imgsToDownload];
    }
}

- (void)updateImage:(NSDictionary *)imageInfo path:(NSString *)path {

    AFNetworkReachabilityStatus status = [GFNetworkStatusUtil networkStatus];
    NSDictionary *data = @{
                           @"id" : [imageInfo objectForKey:@"key"],
                           @"src" : path,
                           @"showGifIcon" : @(status != AFNetworkReachabilityStatusReachableViaWiFi)
                           };
    
    [self.bridge callHandler:@"updateImage" data:data responseCallback:^(id responseData) {
        
    }];
                                   
   [self.imagesForArticle removeObject:imageInfo];
}

#pragma mark - GFImageGroupDelegate
- (NSArray<UIView *> *)pictureViews {
    NSMutableArray<UIImageView *> *imageList = [[NSMutableArray alloc] initWithCapacity:0];
    [self.imageOrderKeys bk_each:^(id obj) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imgView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
        [imageList addObject:imgView];
    }];
    
//    [self.content.pictures bk_each:^(NSString *key, GFPictureMTL *value) {
//        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectZero];
//        imgView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
//        [imageList addObject:imgView];
//    }];
    return imageList;
}

#pragma mark - other
- (void)shareWithType:(GFShareType)type {

    [self.view endEditing:YES];
    
    GFContentStatus status = self.content.contentInfo.status;
    if (status != GFContentStatusNormal && status != GFContentStatusPoor) {
        [MBProgressHUD showHUDWithTitle:@"帖子还未通过审核" duration:kCommonHudDuration inView:self.view];
    } else {
        [WXApi registerApp:kWXAppId];
        [WeiboSDK registerApp:kWeiboAppKey];
        __unused TencentOAuth *tencentOAuth = [[TencentOAuth alloc] initWithAppId:kTencentAppId andDelegate:nil];
        
        __weak typeof(self) weakSelf = self;
        switch (type) {
            case GFShareTypeQQ: {
                [MobClick event:@"gf_xq_01_02_24_1"];
                [[weakSelf getQQSessionActivityWithParams:nil] performActivity];
                break;
            }
            case GFShareTypeQZone: {
                [MobClick event:@"gf_xq_01_02_20_1"];
                [[weakSelf getQzoneActivityWithParams:nil] performActivity];
                break;
            }
            case GFShareTypeWeChat: {
                [MobClick event:@"gf_xq_01_02_23_1"];
                [[weakSelf getWeixinSessionActivityWithParams:nil] performActivity];
                break;
            }
            case GFShareTypeTimeline: {
                [MobClick event:@"gf_xq_01_02_19_1"];
                [[weakSelf getWeixinTimelineActivityWithParams:nil] performActivity];
                break;
            }
            case GFShareTypeWeibo: {
                [MobClick event:@"gf_xq_01_02_21_1"];
                [[weakSelf getSinaWeiboActivityWithParams:nil] performActivity];
                break;
            }
        }
    }
}

- (void)pushIntoProfileViewController:(NSNumber *)userId {
    if (userId) {
        GFProfileViewController *profileViewController = [[GFProfileViewController alloc] initWithUserID:userId];
        [self.navigationController pushViewController:profileViewController animated:YES];
    }
}

- (void)prepareImageForShare:(GFContentMTL *)content {
    
    NSString *url = nil;
    NSDictionary *pictures = content.pictures;
    GFPictureMTL *picture;
    if ([self.imageOrderKeys count] > 0 && self.imageOrderKeys[0] && [pictures count] > 0) {
        picture = [pictures objectForKey:self.imageOrderKeys[0]];
    } else if ([pictures count] > 0) {
        picture = [[pictures allValues] objectAtIndex:0];
    }
    url = picture.url;
    
    if (url) {
        url = [url gf_urlStandardizedWithType:GFImageStandardizedTypeContentDetailArticle gifConverted:YES];        
        __weak typeof(self) weakSelf = self;
        [[YYWebImageManager sharedManager] requestImageWithURL:[NSURL URLWithString:url] options:YYWebImageOptionShowNetworkActivity progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        } transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
            return image;
        } completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            weakSelf.shareImage = image;
        }];

    }
}

@end
