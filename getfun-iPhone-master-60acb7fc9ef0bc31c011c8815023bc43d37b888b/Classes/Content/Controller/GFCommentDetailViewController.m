//
//  GFCommentDetailViewController.m
//  GetFun
//
//  Created by muhuaxin on 15/11/29.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFCommentDetailViewController.h"
#import "GFProfileViewController.h"
#import "GFCommentMTL.h"
#import "GFContentMTL.h"
#import "GFContentInfoMTL.h"
#import "GFCommentReplyCell.h"
#import "GFContentInputView.h"
#import "GFNetworkManager+Comment.h"
#import "GFNetworkManager+Content.h"
#import "GFAccountManager.h"
#import "GFImageGroupView.h"

@interface GFCommentDetailViewController ()
<UITableViewDataSource, UITableViewDelegate, HPGrowingTextViewDelegate, GFCommentReplyCellDelegate>

@property (nonatomic, strong, readonly) NSNumber *contentId;
@property (nonatomic, strong, readonly) NSNumber *rootCommentId;

@property (nonatomic, strong) GFContentMTL *content;
@property (nonatomic, strong) GFCommentMTL *rootComment;
@property (nonatomic, strong) NSMutableArray *allComments;
@property (nonatomic, strong) NSNumber *refQueryTime;

@property (nonatomic, strong) GFCommentMTL *commentToReply;

@property (nonatomic, strong) GFContentInputView *inputView;
@property (nonatomic, strong) UITableView *tableView;

@end

static NSString * const kTableViewIdentifier = @"kTableViewIdentifier";

@implementation GFCommentDetailViewController
- (GFContentInputView *)inputView {
    if (_inputView == nil) {
        _inputView = [[GFContentInputView alloc] initWithFrame:CGRectMake(0, self.view.height - kInputViewHeight, SCREEN_WIDTH, kInputViewHeight)];
        _inputView.textView.delegate = self;
    }
    return _inputView;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, self.view.height-64) style:UITableViewStyleGrouped];
        [_tableView registerClass:[GFCommentReplyCell class] forCellReuseIdentifier:kTableViewIdentifier];
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, kInputViewHeight, 0);
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

- (NSMutableArray *)allComments {
    if (_allComments == nil) {
        _allComments = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _allComments;
}


- (instancetype)initWithRootCommentId:(NSNumber *)commentId contentId:(NSNumber *)contentId {
    if (self = [super init]) {
        _rootCommentId = commentId;
        _contentId = contentId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"查看所有回复";
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.inputView];
    
    __weak typeof(self) weakSelf = self;
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf fetchComment];
    }];

    self.inputView.funButtonHandler = ^() {
        [MobClick event:@"gf_xq_02_01_03_1"];
        [GFAccountManager checkLoginStatus:YES loginCompletion:^(BOOL justLogin, GFUserMTL *user) {
            if (user) {
                [weakSelf funRootComment];
            }
        }];
    };
    
    [self fetchRootComment];
    [self fetchComment];
    [self fetchContent];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self addkeyboardNotification];
}

- (void)dealloc {
    [_inputView removeFromSuperview];
    _inputView = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self removeKeyboardNotification];
}

#pragma mark - Private methods
- (void)fetchRootComment {
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager getCommentWithCommentId:self.rootCommentId
                                      success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, GFCommentMTL *comment) {
                                          if (code == 1 && comment) {
                                              weakSelf.rootComment = comment;
                                              [weakSelf updateDataAndUI];
                                          }
                                      }
                                      failure:^(NSUInteger taskId, NSError *error) {
                                          //
                                      }];
}

- (void)fetchComment {
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager getCommentsReplyToCommentId:self.rootCommentId
                                        queryTime:self.refQueryTime
                                          success:^(NSUInteger taskId, NSInteger code, NSArray *comments, NSNumber *nextQueryTime, NSString *errorMessage, BOOL hasMore) {
                                              
                                              [weakSelf.tableView finishInfiniteScrolling];

                                              if (code == 1 && comments) {
                                                  [weakSelf.allComments addObjectsFromArray:comments];
                                                  weakSelf.refQueryTime = nextQueryTime;

                                                  weakSelf.tableView.showsInfiniteScrolling = [weakSelf.refQueryTime integerValue] != -1;
                                                  
                                                  [weakSelf updateDataAndUI];
                                              }
                                          }
                                          failure:^(NSUInteger taskId, NSError *error) {
                                              [weakSelf.tableView finishInfiniteScrolling];
                                          }];
}

- (void)fetchContent {
    
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager getContentWithContentId:self.contentId
                                      keyFrom:GFKeyFromUnkown
                                      success:^(NSUInteger taskId, NSInteger code, GFContentMTL *content, NSDictionary *data, NSString *errorMessage) {
                                          if (code == 1) {
                                              weakSelf.content = content;
                                              [weakSelf updateDataAndUI];
                                          }
                                      } failure:^(NSUInteger taskId, NSError *error) {
                                          //
                                      }];
}

- (void)funRootComment {
    NSInteger funCount = [self.rootComment.commentInfo.funCount integerValue];
    
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager addFunWithCommentId:self.rootComment.commentInfo.commentId
                                  success:^(NSUInteger taskId, NSInteger code, NSString *errorMessage) {
                                      if (code == 1) {
                                          weakSelf.rootComment.loginUserHasFuned = YES;
                                          weakSelf.rootComment.commentInfo.funCount = @(funCount + 1);
                                          weakSelf.inputView.funCount = funCount + 1;
                                          weakSelf.inputView.funned = YES;
                                          [weakSelf.tableView reloadData];
                                          if (weakSelf.funHandler) {
                                              weakSelf.funHandler(weakSelf.rootComment);
                                          }
                                      } else {
                                          weakSelf.inputView.funCount = 0;
                                          weakSelf.inputView.funned = NO;
                                          NSString *msg = [errorMessage length] > 0 ? errorMessage : @"Fun评论失败";
                                          [MBProgressHUD showHUDWithTitle:msg duration:kCommonHudDuration inView:self.view];
                                      }
                                  }
                                  failure:^(NSUInteger taskId, NSError *error) {
                                      weakSelf.inputView.funCount = 0;
                                      weakSelf.inputView.funned = NO;
                                      [weakSelf showNetworkFailure];
                                  }];
}

- (void)funComment:(GFCommentMTL *)comment {
    __weak typeof(self) weakSelf = self;    
    [GFNetworkManager addFunWithCommentId:comment.commentInfo.commentId
                                  success:^(NSUInteger taskId, NSInteger code, NSString *errorMessage) {
                                      if (code == 1) {
                                          comment.commentInfo.funCount = @([comment.commentInfo.funCount integerValue] + 1);
                                          comment.loginUserHasFuned = YES;
                                          self.inputView.funned = YES;
                                          [weakSelf.tableView reloadData];
                                      } else {
                                          NSString *msg = [errorMessage length] > 0 ? errorMessage : @"Fun评论失败";
                                          [MBProgressHUD showHUDWithTitle:msg duration:kCommonHudDuration inView:self.view];
                                      }
                                  }
                                  failure:^(NSUInteger taskId, NSError *error) {
                                      [weakSelf showNetworkFailure];
                                  }];
}
///楼主标签是否显示
- (BOOL)isContentHost:(NSNumber *)userId {
    return userId && [self.content.user.userId isEqualToNumber:userId];
}

- (void)showNetworkFailure {
    [MBProgressHUD showHUDWithTitle:@"网络失败" duration:kCommonHudDuration inView:self.view];
}

- (void)updateDataAndUI {
    if (self.rootComment.loginUserHasFuned) {
        self.inputView.funCount = [self.rootComment.commentInfo.funCount integerValue];
    } else {
        self.inputView.funCount = 0;
    }
    self.inputView.funned = self.rootComment.loginUserHasFuned;
    self.inputView.textView.placeholder = [NSString stringWithFormat:@"回复%@", self.rootComment.user.nickName];
    [self.tableView reloadData];
}

//注意：应该在调用前去除空格换行
- (void)addComment:(NSString *)text {

    if (text.length == 0) {
        return;
    }
    
    if (self.commentToReply == nil) {
        self.commentToReply = self.rootComment;
    }
    
    if (self.commentToReply.commentInfo.commentId == nil) {
        return;
    }
    
    @weakify(self)
    [GFNetworkManager addCommentWithRelateId:self.content.contentInfo.contentId
                                     content:text
                                    parentId:self.commentToReply.commentInfo.commentId
                                     success:^(NSUInteger taskId, NSInteger code, GFCommentMTL *comment, NSString *errorMessage) {
                                         @strongify(self)
                                         if (code == 1) {
                                             if (comment) {
                                                 [self.allComments addObject:comment];
                                                 self.rootComment.children = self.allComments;
                                                 self.rootComment.commentInfo.replyCountTotal = @([self.rootComment.commentInfo.replyCountTotal integerValue] + 1);
                                                 [self.tableView reloadData];
                                                 
                                                 if (self.childCommentHandler) {
                                                     self.childCommentHandler(self.rootComment, self.commentToReply);
                                                 }
                                                 [MBProgressHUD showHUDWithTitle:@"评论成功！" duration:kCommonHudDuration inView:self.view];
                                             }
                                         } else {
                                             NSString *msg = [errorMessage length] > 0 ? errorMessage : @"评论失败";
                                             [MBProgressHUD showHUDWithTitle:msg duration:kCommonHudDuration inView:self.view];
                                         }
                                     }
                                     failure:^(NSUInteger taskId, NSError *error) {
                                         @strongify(self)
                                         [self showNetworkFailure];
                                     }];
}

#pragma mark - KeyboardNotification
- (void)addkeyboardNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardFrameChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardFrameDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)removeKeyboardNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onKeyboardFrameChange:(NSNotification *)notification {
    NSValue *endFrameValue = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect endFrame = [endFrameValue CGRectValue];
    CGFloat endY = endFrame.origin.y;
    
    [UIView animateWithDuration:.5 animations:^{
        self.inputView.bottom = endY;
    }];
}

- (void)onKeyboardFrameDidHide:(NSNotification *)notification {
//    self.inputView.textView.placeholder = @"";
    self.commentToReply = nil;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.allComments.count > 0 ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return self.allComments.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GFCommentReplyCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableViewIdentifier forIndexPath:indexPath];
    
    GFCommentMTL *comment = nil;
    if (indexPath.section == 0) {
        comment = self.rootComment;
    } else {
        comment = self.allComments[indexPath.row];
    }
    
    [cell bindWithModel:comment];
    cell.delegate = self;
    cell.isMine = [self isContentHost:comment.user.userId];
    [cell gf_AddTopBorderWithColor:[UIColor themeColorValue15] andWidth:0.5f];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    GFCommentMTL *comment = nil;
    if (section == 0) {
        comment = self.rootComment;
    } else if (section == 1) {
        [MobClick event:@"gf_xq_02_01_01_1"];
        comment = self.allComments[row];
    }
    self.commentToReply = comment;
    
    NSString *nickName = comment.user.nickName;
    if (!nickName) {
        nickName = @"";
    }
    self.inputView.textView.placeholder = [NSString stringWithFormat:@"回复%@：", nickName];
    [self.inputView.textView becomeFirstResponder];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [GFCommentReplyCell heightWithModel:self.rootComment];
    } else {
        return [GFCommentReplyCell heightWithModel:self.allComments[indexPath.row]];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    } else {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor whiteColor];
        
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont boldSystemFontOfSize:15];
        label.textColor = [UIColor blackColor];
        label.frame = CGRectMake(17, 11, 100, 18);
        label.text = @"更多回复";
        [view addSubview:label];
        
        return view;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.1;
    } else {
        return 40;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

#pragma mark - HPGrowingTextViewDelegate
- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView {
    [MobClick event:@"gf_xq_02_01_04_1"];
    
    GFLoginType type = [GFAccountManager sharedManager].loginType;
    if (type == GFLoginTypeAnonymous || type == GFLoginTypeNone) {
        [GFAccountManager checkLoginStatus:YES loginCompletion:^(BOOL justLogin, GFUserMTL *user) {
            if (user) {
                [MobClick event:@"gf_xq_02_01_05_1"];
                [self.inputView.textView becomeFirstResponder];
            } else {
                [MobClick event:@"gf_xq_02_01_06_1"];
            }
        }];
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView {
    [MobClick event:@"gf_xq_02_01_07_1"];
    
    NSString *text = growingTextView.text;
    if ([[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        [MBProgressHUD showHUDWithTitle:@"评论不能为空" duration:kCommonHudDuration inView:self.view];
        return YES;
    } else if([text length] > 1000){
        [MBProgressHUD showHUDWithTitle:@"评论不能超过1000字" duration:kCommonHudDuration inView:self.view];
        return YES;
    }
    
    
    growingTextView.text = nil;
    [growingTextView resignFirstResponder];
    
    [self addComment:text];
    
    return YES;
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height{
    CGFloat deltaHeight = height - growingTextView.height;
    
    CGRect rect = self.inputView.frame;
    CGRect frame = CGRectMake(CGRectGetMinX(rect), CGRectGetMaxY(rect) - CGRectGetHeight(rect) - deltaHeight, CGRectGetWidth(rect), CGRectGetHeight(rect) + deltaHeight);
    self.inputView.frame = frame;
}

#pragma mark - GFCommentReplyCellDelegate
- (void)avatarTapppedInCell:(GFCommentReplyCell *)cell {
    GFCommentMTL *comment = [cell model];
    GFUserMTL *user = comment.user;
    GFProfileViewController *profileViewController = [[GFProfileViewController alloc] initWithUserID:user.userId];
    [self.navigationController pushViewController:profileViewController animated:YES];

}
- (void)funButtonClickInCell:(GFCommentReplyCell *)cell {
    [GFAccountManager checkLoginStatus:YES loginCompletion:^(BOOL justLogin, GFUserMTL *user) {
        if (user) {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            if (indexPath.section == 0) {
                [self funRootComment];
            } else {
                [MobClick event:@"gf_xq_02_01_02_1"];
                [self funComment:cell.model];
            }
            
            [cell doFunAnimate];
        }
    }];
}
- (void)replyNameInCell:(GFCommentReplyCell *)cell {
    
}
- (void)imageTappedInCell:(GFCommentReplyCell *)cell iniImageIndex:(NSUInteger)index {
    [MobClick event:@"gf_xq_06_04_01_1"];
    
    NSDictionary *picturySummary = nil;
    NSArray *orderKeys = nil;
    NSString *iniPictureKey = nil;
    GFCommentMTL *comment = [cell model];
    if ([comment.commentInfo.pictureKeys count] > 0) {
        picturySummary = comment.pictures;
        orderKeys = comment.commentInfo.pictureKeys;
        iniPictureKey = [orderKeys objectAtIndex:index];
    } else {
        picturySummary = comment.emotions;
        orderKeys = comment.commentInfo.emotionIds;
        iniPictureKey = [orderKeys objectAtIndex:index];
    }
    
    GFImageGroupView *view = [[GFImageGroupView alloc] initWithImages:picturySummary orderKeys:orderKeys initialKey:iniPictureKey delegate:cell];
    [view presentToContainer:self.navigationController.view animated:YES completion:nil];

}

@end
