//
//  GFMsgListViewController.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/1.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFMsgListViewController.h"
#import "GFMessageMTL.h"
#import "GFMessageCenter.h"
#import "GFMsgTableViewCell.h"
#import "GFCommentDetailViewController.h"
#import "GFGroupDetailViewController.h"
#import "GFGroupUpdateViewController.h"
#import "GFProfileViewController.h"
#import "GFNetworkManager+Message.h"
#import "GFNetworkManager+Group.h"
#import "AppDelegate.h"

@interface GFMsgListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign, readonly) GFBasicMessageType type;
@property (nonatomic, strong) UITableView *messageTableView;

@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSNumber *lastQueryTime;

@property (nonatomic, strong) UIImageView *noMessageImageView;

@property (nonatomic, strong) MBProgressHUD *loadHUD;

@end

@implementation GFMsgListViewController
- (UITableView *)messageTableView {
    if (!_messageTableView) {
        _messageTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
        _messageTableView.backgroundColor = [UIColor clearColor];
        _messageTableView.delegate = self;
        _messageTableView.dataSource = self;
        _messageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_messageTableView registerClass:[GFMsgTableViewCell class] forCellReuseIdentifier:NSStringFromClass([GFMsgTableViewCell class])];
    }
    return _messageTableView;
}

- (NSMutableArray *)messages {
    if (!_messages) {
        _messages = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _messages;
}

- (UIImageView *)noMessageImageView {
    if (!_noMessageImageView) {
        _noMessageImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"placeholder_no_msg"]];
        [_noMessageImageView sizeToFit];
        _noMessageImageView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
        _noMessageImageView.hidden = YES;
    }
    return _noMessageImageView;
}

- (instancetype)initWithBasicMessageType:(GFBasicMessageType)type {
    if (self = [super init]) {
        _type = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configureTitle];
    
    [self.view addSubview:self.messageTableView];
    [self.view addSubview:self.noMessageImageView];

    // 下拉刷新
    __weak typeof(self) weakSelf = self;
    [self.messageTableView addPullToRefreshWithActionHandler:^{
        [weakSelf queryMessages:YES];
    }];
    
    // 上拉加载更多
    [self.messageTableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf queryMessages:NO];
    }];
    
    // load数据
    self.loadHUD = [MBProgressHUD showLoadingHUDWithTitle:@"正在加载消息" inView:self.view];
    [self queryMessages:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMessage:) name:GFNotificationDidReceiveMessage object:nil];
}

- (void)configureTitle {
    switch (self.type) {
        case GFBasicMessageTypeUnknown:{
            break;
        }
        case GFBasicMessageTypeAudit: {
            self.title = @"系统通知";
            break;
        }
        case GFBasicMessageTypeComment: {
            self.title = @"评论我的";
            break;
        }
        case GFBasicMessageTypeFun: {
            self.title = @"FUN我的";
            break;
        }
        case GFBasicMessageTypeParticipate: {
            self.title = @"参与我的PK";
            break;
        }
        case GFBasicMessageTypeActivity: {
            
            break;
        }
        case GFBasicMessageTypeNotify: {
            
            break;
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GFNotificationDidReceiveMessage object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)queryMessages:(BOOL)reset {
    
    __weak typeof(self) weakSelf = self;
    NSNumber *queryTime = reset ? nil : self.lastQueryTime;
    [GFNetworkManager getMessageListWithBasicType:self.type
                                     refQueryTime:queryTime
                                             size:kQueryDataCount
                                          success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, NSNumber *refTime, NSArray *messages) {
                                              
                                              [weakSelf.loadHUD hide:YES];
                                              [weakSelf.messageTableView finishPullToRefresh];
                                              [weakSelf.messageTableView finishInfiniteScrolling];
                                              
                                              if (code == 1) {

                                                  if (reset) {
                                                      [weakSelf.messages removeAllObjects];
                                                  }
                                                  weakSelf.lastQueryTime = refTime;

                                                  [weakSelf.messages addObjectsFromArray:messages];
                                                  
                                                  weakSelf.messageTableView.showsInfiniteScrolling = [refTime integerValue] != -1;
                                                  [weakSelf.messageTableView reloadData];
                                              }
                                              weakSelf.noMessageImageView.hidden = weakSelf.messages.count > 0;
                                          } failure:^(NSUInteger taskId, NSError *error) {
                                              [weakSelf.loadHUD hide:YES];
                                              weakSelf.noMessageImageView.hidden = weakSelf.messages.count > 0;
                                              [weakSelf.messageTableView finishPullToRefresh];
                                              [weakSelf.messageTableView finishInfiniteScrolling];
                                          }];
    
}

- (void)didReceiveMessage:(NSNotification *)notification {
    GFMessageMTL *message = [notification.userInfo objectForKey:kMessageNotificationUserInfoKeyMsg];
    GFBasicMessageType type = message.messageDetail.messageType & 0xF0;
    if (type == self.type) {
        
        if (![self.messages containsObject:message]) {
            [self.messages insertObject:message atIndex:0];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.messageTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GFMsgTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([GFMsgTableViewCell class])];
    GFMessageMTL *message = [self.messages objectAtIndex:indexPath.row];
    [cell bindWithModel:message];

    // 头像暂时不可点击
//    __weak typeof(self) weakSelf = self;
//    cell.msgAvatarHandler = ^(GFMsgTableViewCell *cell) {
//        NSNumber *userId = message.relatedData.relatedUser.userId;
//        if (userId) {
//            GFProfileViewController *profileViewController = [[GFProfileViewController alloc] initWithUserID:userId];
//            [weakSelf.navigationController pushViewController:profileViewController animated:YES];
//        }
//    };
    
    return cell;
}

#pragma mark = UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id model = [self.messages objectAtIndex:indexPath.row];
    return [GFMsgTableViewCell heightWithModel:model];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GFMessageMTL *message = [self.messages objectAtIndex:indexPath.row];
    if (message.messageDetail.unread == YES) {
        [GFMessageCenter markReadMessage:message];
        message.messageDetail.unread = NO;
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [[AppDelegate appDelegate] handleRedirectMessage:message];
}

@end
