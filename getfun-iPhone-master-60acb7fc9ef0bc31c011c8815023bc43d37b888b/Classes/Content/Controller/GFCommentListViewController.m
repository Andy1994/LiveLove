//
//  GFCommentListViewController.m
//  GetFun
//
//  Created by muhuaxin on 15/12/3.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFCommentListViewController.h"

#import "GFNetworkManager+Comment.h"
#import "GFNetworkManager+Content.h"
#import "GFAccountManager.h"

#import "GFContentMTL.h"
#import "GFContentInfoMTL.h"

#import "GFContentInputView.h"
#import "GFContentDetailNoCommentView.h"
#import "GFCommentCell.h"

#import "GFCommentDetailViewController.h"
#import "GFImageGroupView.h"
#import "GFProfileViewController.h"

@interface GFCommentListViewController () <UITableViewDataSource, UITableViewDelegate, HPGrowingTextViewDelegate>

@property (nonatomic, strong) GFContentMTL *content;

@property (nonatomic, strong) UITableView                  *tableView;
@property (nonatomic, strong) GFContentInputView           *inputView;
@property (nonatomic, strong) GFContentDetailNoCommentView *noCommentView;

@property (nonatomic, copy  ) NSArray                      *hotComments;
@property (nonatomic, strong) NSMutableArray               *allComments;
@property (nonatomic, strong) NSNumber                     *nextQueryTime;

@end

static NSString * const kGFCommentListViewControllerCellId = @"kGFCommentListViewControllerCellId";

@implementation GFCommentListViewController

- (instancetype)initWithContent:(GFContentMTL *)content {
    if (self = [super init]) {
        _content = content;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.inputView];
    
    [self fetchHotComments];
    [self fetchAllComments];
    
    __weak typeof(self) weakSelf = self;
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf fetchAllComments];
    }];
}

- (void)dealloc {
    [_inputView removeFromSuperview];
    _inputView = nil;
}

- (BOOL)funned {
    GFContentActionStatus *funActionStatus = self.content.actionStatuses[GFContentMTLActionStatusesKeyFun];
    return [funActionStatus.count integerValue] > 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self addkeyboardNotification];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self removeKeyboardNotification];
}

#pragma mark - Getters
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.view.height) style:UITableViewStyleGrouped];
        [_tableView registerClass:[GFCommentCell class] forCellReuseIdentifier:kGFCommentListViewControllerCellId];
        _tableView.contentInset = UIEdgeInsetsMake(64, 0, kInputViewHeight, 0);
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

- (GFContentInputView *)inputView {
    if (_inputView == nil) {
        _inputView = [[GFContentInputView alloc] initWithFrame:CGRectMake(0, self.view.height - kInputViewHeight, SCREEN_WIDTH, kInputViewHeight)];
        _inputView.textView.delegate = self;
        _inputView.funned = [self funned];
        _inputView.funCount = [self funned] ? [self.content.contentInfo.funCount integerValue] : 0;
        
        __weak typeof(self) weakSelf = self;
        _inputView.funButtonHandler = ^{
            
            [GFAccountManager checkLoginStatus:YES loginCompletion:^(BOOL justLogin, GFUserMTL *user) {
                if (user) {
                    [weakSelf changeFunStatus];
                } else {
                    weakSelf.inputView.funned = [weakSelf funned];
                }
            }];
            
        };
    }
    return _inputView;
}

- (void)changeFunStatus {
    BOOL funned = [self funned];
    NSInteger count = [self.content.contentInfo.funCount integerValue];
    [GFNetworkManager changeFunStatusWithContentId:self.content.contentInfo.contentId isFun:!funned success:^(NSUInteger taskId, NSInteger code, NSString *errorMessage) {
        if (code == 1) {
            GFContentActionStatus *funActionStatus = self.content.actionStatuses[GFContentMTLActionStatusesKeyFun];
            funActionStatus.count = funned ? @0 : @1;
            
            NSInteger totalFunCount = funned ? count - 1 : count + 1;
            
            self.inputView.funCount = totalFunCount;
            
            self.inputView.funned = !funned;
            self.content.contentInfo.funCount = @(totalFunCount);
        } else {
            self.inputView.funCount = count;
            self.inputView.funned = funned;
        }
    } failure:^(NSUInteger taskId, NSError *error) {
        self.inputView.funCount = count;
        self.inputView.funned = funned;
        [self showNetworkFailure];
    }];
}


- (GFContentDetailNoCommentView *)noCommentView {
    if (_noCommentView == nil) {
        _noCommentView = [[GFContentDetailNoCommentView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 320)];
    }
    return _noCommentView;
}

- (NSMutableArray *)allComments {
    if (_allComments == nil) {
        _allComments = [[NSMutableArray alloc] init];
    }
    return _allComments;
}

#pragma mark - Private methods

- (void)fetchHotComments {
    [GFNetworkManager getHotCommentsByRelatedId:self.content.contentInfo.contentId
                                        success:^(NSUInteger taskId, NSInteger code, NSArray *comments, NSString *errorMessage) {
                                            if (code == 1) {
                                                if (comments) {
                                                    self.hotComments = comments;
                                                    [self.tableView reloadData];
                                                    [self setTableViewFooter];
                                                }
                                            }
                                        }
                                        failure:^(NSUInteger taskId, NSError *error) {
                                            
                                        }];
}

- (void)fetchAllComments {
    
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager getCommentsWithContentId:self.content.contentInfo.contentId
                                   queryTime:self.nextQueryTime
                                     success:^(NSUInteger taskId, NSInteger code, NSArray *comments, NSNumber *nextQueryTime, NSString *errorMessage) {
                                         [weakSelf.tableView finishInfiniteScrolling];
                                         
                                         if (code == 1) {
                                             if (comments) {
                                                 [weakSelf.allComments addObjectsFromArray:comments];
                                                 weakSelf.nextQueryTime = nextQueryTime;
                                                 
                                                 weakSelf.tableView.showsInfiniteScrolling = [weakSelf.nextQueryTime integerValue] != -1;
                                                 
                                                 [weakSelf.tableView reloadData];
                                                 [weakSelf setTableViewFooter];
                                             }
                                             
                                         }
                                     }
                                     failure:^(NSUInteger taskId, NSError *error) {
                                         [weakSelf.tableView finishInfiniteScrolling];
                                     }];
}

- (void)addComment:(NSString *)text {
    if (text.length == 0) {
        return;
    }
    
    @weakify(self)
    [GFNetworkManager addCommentWithRelateId:self.content.contentInfo.contentId
                                     content:text
                                    parentId:nil
                                     success:^(NSUInteger taskId, NSInteger code, GFCommentMTL *comment, NSString *errorMessage) {
                                         @strongify(self)
                                         if (code == 1) {
                                             if (comment) {
                                                 [self.allComments insertObject:comment atIndex:0];
                                                 [self.tableView reloadData];
                                                 [self setTableViewFooter];
                                                 [MBProgressHUD showHUDWithTitle:@"评论成功！" duration:kCommonHudDuration inView:self.view];
                                             }
                                         } else {
                                             @strongify(self)
                                             NSString *msg = [errorMessage length] > 0 ? errorMessage : @"评论失败";
                                             [MBProgressHUD showHUDWithTitle:msg duration:kCommonHudDuration inView:self.view];
                                         }
                                     }
                                     failure:^(NSUInteger taskId, NSError *error) {
                                         [self showNetworkFailure];
                                     }];
}

- (void)funComment:(GFCommentMTL *)comment inCell:(GFCommentCell *)cell {
    if (!comment) {
        return;
    }
    
    [GFNetworkManager addFunWithCommentId:comment.commentInfo.commentId
                                  success:^(NSUInteger taskId, NSInteger code, NSString *errorMessage) {
                                      if (code == 1) {
                                          comment.loginUserHasFuned = YES;
                                          comment.commentInfo.funCount = @([comment.commentInfo.funCount integerValue] + 1);
                                          [cell bindWithModel:comment];
                                      } else {
                                          NSString *msg = [errorMessage length] > 0 ? errorMessage : @"Fun评论失败";
                                          [MBProgressHUD showHUDWithTitle:msg duration:kCommonHudDuration inView:self.view];
                                      }
                                  }
                                  failure:^(NSUInteger taskId, NSError *error) {
                                      [self showNetworkFailure];
                                  }];
}

- (BOOL)isContentHost {
    return self.content.user.userId && [[GFAccountManager sharedManager].loginUser.userId isEqualToNumber:self.content.user.userId];
}

- (void)setTableViewFooter {
    if (self.allComments.count == 0) {
        [self.tableView setTableFooterView:self.noCommentView];
    } else {
        [self.tableView setTableFooterView:nil];
    }
}

- (void)showNetworkFailure {
    [MBProgressHUD showHUDWithTitle:@"网络失败" duration:kCommonHudDuration inView:self.view];
}

#pragma mark - KeyboardNotification
- (void)addkeyboardNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardFrameChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)removeKeyboardNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)onKeyboardFrameChange:(NSNotification *)notification {
    NSValue *endFrameValue = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect endFrame = [endFrameValue CGRectValue];
    CGFloat endY = endFrame.origin.y;
    
    [UIView animateWithDuration:.5 animations:^{
        self.inputView.bottom = endY;
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sections = 0;
    if (self.hotComments.count > 0) {
        sections++;
    }
    if (self.allComments.count > 0) {
        sections++;
    }
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if (self.hotComments.count > 0) {
            return self.hotComments.count;
        } else if (self.allComments.count > 0) {
            return self.allComments.count;
        }
    } else if (section == 1) {
        if (self.allComments.count > 0) {
            return self.allComments.count;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    GFCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:kGFCommentListViewControllerCellId forIndexPath:indexPath];
    
    GFCommentMTL *comment = nil;
    
    if (section == 0) {
        if (self.hotComments.count > 0) {
            comment = self.hotComments[row];
        } else if (self.allComments.count > 0) {
            comment = self.allComments[row];
        }
    } else if (section == 1) {
        if (self.allComments.count > 0) {
            comment = self.allComments[row];
        }
    }
    
    [cell bindWithModel:comment];
    cell.isMine = [self isContentHost];
    
    @weakify(self)
    cell.funButtonHandler = ^(GFCommentCell *cell, GFCommentMTL *model) {
        @strongify(self)
        [self funComment:model inCell:cell];
        [cell doFunAnimate];
    };
    
    cell.avatarTappedHandler = ^(GFCommentCell *cell, GFCommentMTL *model) {
        @strongify(self)
        GFUserMTL *user = model.user;
        GFProfileViewController *profileViewController = [[GFProfileViewController alloc] initWithUserID:user.userId];
        [self.navigationController pushViewController:profileViewController animated:YES];

    };
    
    [cell setTapImageHandler:^(GFCommentCell *cell, NSUInteger iniImageIndex) {
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
        [imageGroupView presentToContainer:self.navigationController.view animated:YES completion:nil];
    }];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *text = nil;
    if (section == 0) {
        if (self.hotComments.count > 0) {
            text = @"热门跟帖";
        } else if (self.allComments.count > 0) {
            text = @"最新跟帖";
        }
    } else if (section == 1) {
        if (self.allComments.count > 0) {
            text = @"最新跟帖";
        }
    }
    return text;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    GFCommentMTL *comment = nil;
    
    if (section == 0) {
        if (self.hotComments.count > 0) {
            comment = self.hotComments[row];
        } else if (self.allComments.count > 0) {
            comment = self.allComments[row];
        }
    } else if (section == 1) {
        if (self.allComments.count > 0) {
            comment = self.allComments[row];
        }
    }
    
    GFCommentDetailViewController *controller = [[GFCommentDetailViewController alloc] initWithRootCommentId:comment.commentInfo.commentId contentId:self.content.contentInfo.contentId];
    [self.navigationController pushViewController:controller animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    GFCommentMTL *comment = nil;
    
    if (section == 0) {
        if (self.hotComments.count > 0) {
            comment = self.hotComments[row];
        } else if (self.allComments.count > 0) {
            comment = self.allComments[row];
        }
    } else if (section == 1) {
        if (self.allComments.count > 0) {
            comment = self.allComments[row];
        }
    }
    
    return [GFCommentCell heightWithModel:comment];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont boldSystemFontOfSize:15];
    label.textColor = [UIColor blackColor];
    label.frame = CGRectMake(17, 11, 100, 18);
    [view addSubview:label];
    
    if (section == 0) {
        if (self.hotComments.count > 0) {
            label.text = @"热门评论";
        } else if (self.allComments.count > 0) {
            label.text = [NSString stringWithFormat:@"全部评论(%@)", @(self.allComments.count)];
        }
    } else if (section == 1) {
        if (self.allComments.count > 0) {
            label.text = [NSString stringWithFormat:@"全部评论(%@)", @(self.allComments.count)];
        }
    }
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

#pragma mark - UITextFieldDelegate
- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView {
    GFLoginType type = [GFAccountManager sharedManager].loginType;
    __weak typeof(self) weakSelf = self;
    if (type == GFLoginTypeAnonymous || type == GFLoginTypeNone) {
        [GFAccountManager checkLoginStatus:YES loginCompletion:^(BOOL justLogin, GFUserMTL *user) {
            if (user) {
                [weakSelf.inputView.textView becomeFirstResponder];
            }
        }];
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView {
    NSString *text = growingTextView.text;
    
    if ([[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        [MBProgressHUD showHUDWithTitle:@"评论不能为空" duration:kCommonHudDuration inView:self.view];
        return YES;
    }else if([text length] > 1000){

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

@end
