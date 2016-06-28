//
//  GFAllInterestTableViewController.m
//  GetFun
//
//  Created by Liu Peng on 15/12/9.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFCreateGroupAllInterestViewController.h"
#import "GFNetworkManager+Tag.h"
#import "GFGroupUpdateViewController.h"

@interface GFCreateGroupAllInterestTableViewCell : GFBaseTableViewCell
@property (nonatomic, strong) CALayer *border;
@end

@implementation GFCreateGroupAllInterestTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _border = [CALayer layer];
        _border.backgroundColor = [UIColor themeColorValue15].CGColor;
        CGFloat borderWidth = 0.5f;
        CGFloat x = 20.0f;
        _border.frame = CGRectMake(x, self.height - borderWidth, SCREEN_WIDTH - x, borderWidth);
        [self.layer addSublayer:_border];
    }
    return self;
}


@end



@interface GFCreateGroupAllInterestViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *interestTableView;
@property (nonatomic, strong) NSArray<GFTagInfoMTL *> *interestDataSource;

@end

@implementation GFCreateGroupAllInterestViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"全部兴趣";
    
    [self.view addSubview: self.interestTableView];
    [self queryAllInterests];
}

- (void)backBarButtonItemSelected {
    [MobClick event:@"gf_gb_03_06_01_1"];
    [super backBarButtonItemSelected];
}

-(void)queryAllInterests {
    
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager getAllInterestTagsSuccess:^(NSUInteger taskId, NSInteger code, NSArray<GFTagInfoMTL *> *tags, NSString *errorMessage) {
        if (code == 1) {
            weakSelf.interestDataSource = tags;
            [weakSelf.interestTableView reloadData];
        } else {
            [MBProgressHUD showHUDWithTitle:errorMessage duration:kCommonHudDuration inView:self.view];
        }
    } failure:^(NSUInteger taskId, NSError *error) {
        [MBProgressHUD showHUDWithTitle:@"获取兴趣列表失败" duration:kCommonHudDuration inView:self.view];
    }];
}

- (UITableView *)interestTableView {
    if (!_interestTableView) {
        _interestTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height-64)];
        _interestTableView.delegate = self;
        _interestTableView.dataSource = self;
        _interestTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_interestTableView registerClass:[GFCreateGroupAllInterestTableViewCell class] forCellReuseIdentifier:NSStringFromClass([GFCreateGroupAllInterestTableViewCell class])];
    }
    return _interestTableView;
}

- (NSArray<GFTagInfoMTL*> *)interestDataSource {
    if (!_interestDataSource) {
        _interestDataSource = [[NSArray alloc] init];
    }
    return _interestDataSource;
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return [self.interestDataSource count];
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
//    GFTagInfoMTL *tag = [self.interestDataSource objectAtIndex:section];
//    return [tag.children count];
    return [self.interestDataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GFTagInfoMTL *tag = [self.interestDataSource objectAtIndex:indexPath.row];
//    NSArray *childTags = tag.children;
//    GFTagInfoMTL *subTag = [childTags objectAtIndex:indexPath.row];
//    
    GFCreateGroupAllInterestTableViewCell *cell = [self.interestTableView dequeueReusableCellWithIdentifier:NSStringFromClass([GFCreateGroupAllInterestTableViewCell class])];
    cell.textLabel.text = tag.tagName;
    cell.textLabel.font = [UIFont systemFontOfSize:17.0f];
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 30.0f;
//}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    
//    GFTagInfoMTL *tag = [self.interestDataSource objectAtIndex:section];
//    return tag.tagName;
//}


//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
//    // Background color
//    view.tintColor = [UIColor whiteColor];
//    // Text Color
//    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
//    [header gf_AddBottomBorderWithColor:[UIColor themeColorValue15] andWidth:1];
//    [header.textLabel setTextColor:[UIColor textColorValue7]];
//    header.textLabel.font = [UIFont systemFontOfSize:14.0f];
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GFTagInfoMTL *tag = [self.interestDataSource objectAtIndex:indexPath.row];
    
//    NSArray *childTags = tag.children;
//    GFTagInfoMTL *subTag = [childTags objectAtIndex:indexPath.row];
    [MobClick event:@"gf_gb_03_01_01_1"];
    if (self.interestSelectHandler) {
        self.interestSelectHandler(tag);
        if (_needPopTwoCtl) {
            NSArray *arr = [self.navigationController viewControllers];
            NSInteger index = [arr indexOfObject:self];
            if (index >= 2) {
                UIViewController *ctl = [arr objectAtIndex:index-2];
                [self.navigationController popToViewController:ctl animated:YES];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        GFGroupUpdateViewController *groupUpdateViewController = [[GFGroupUpdateViewController alloc] initWithTag:tag];
        [self.navigationController pushViewController:groupUpdateViewController animated:YES];
    }
}

@end
