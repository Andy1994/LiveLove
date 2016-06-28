//
//  GFCollegeSelectViewController.m
//  GetFun
//
//  Created by zhouxz on 15/12/12.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFCollegeSelectViewController.h"
#import "GFCollegeMTL.h"
#import "GFNetworkManager+User.h"
#import "GFAccountManager.h"
#import "GFCollegeTableViewCell.h"
#import "GFSearchBar.h"

@interface GFCollegeSelectViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>


@property (nonatomic, strong) GFSearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchDisplayController;


@property (nonatomic, strong) NSArray<GFCollegeMTL *> *collegeDataSource;
@property (nonatomic, strong) NSArray<NSDictionary *> *allCollegesDataSource;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *filteredCollegesDataSource;
@property (nonatomic, strong) UITableView *collegeTableView;

@property (nonatomic, strong) GFCollegeMTL *selectedCollege;

@end

@implementation GFCollegeSelectViewController
- (UITableView *)collegeTableView {
    if (!_collegeTableView) {
        _collegeTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height-64) style:UITableViewStylePlain];
        _collegeTableView.delegate = self;
        _collegeTableView.dataSource = self;
        _collegeTableView.tableHeaderView = self.searchBar;
        _collegeTableView.separatorColor = [UIColor themeColorValue15];
        [_collegeTableView registerClass:[GFCollegeTableViewCell class] forCellReuseIdentifier:NSStringFromClass([GFCollegeTableViewCell class])];
    }
    return _collegeTableView;
}

- (GFSearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[GFSearchBar alloc] initWithFrame:CGRectZero];
        [_searchBar sizeToFit];
        _searchBar.layer.borderColor = [UIColor clearColor].CGColor;
        _searchBar.delegate = self;
    }
    return _searchBar;
}

- (UISearchDisplayController *)searchDisplayController {
    if (!_searchDisplayController) {
        _searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
        _searchDisplayController.delegate = self;
        _searchDisplayController.searchResultsDataSource = self;
        _searchDisplayController.searchResultsDelegate = self;
        [_searchDisplayController.searchResultsTableView registerClass:[GFCollegeTableViewCell class] forCellReuseIdentifier:NSStringFromClass([GFCollegeTableViewCell class])];
        
    }
    return _searchDisplayController;
}


- (NSMutableArray<NSDictionary *> *)filteredCollegesDataSource {
    if (!_filteredCollegesDataSource) {
        _filteredCollegesDataSource = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _filteredCollegesDataSource;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"选择学校";
        
    self.view.backgroundColor = [UIColor themeColorValue15];
    
    [self.view addSubview:self.collegeTableView];
    
    [self loadAllColleges];
    
    [self queryCollegeData:self.provinceId];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

- (void)queryCollegeData:(NSNumber *)provinceId {
    
    if (!self.provinceId) {
        self.provinceId = [GFAccountManager sharedManager].loginUser.provinceId;
    }
    
    //如果是不限地点，直接加载全部数据
    if ([self.provinceId isEqualToNumber:@(87)]) { //不限对应Id为87
        self.collegeDataSource = [self.allCollegesDataSource bk_map:^id(id obj) {
            GFCollegeMTL * college = [[GFCollegeMTL alloc] init];
            NSDictionary *model = obj;
            college.collegeId = (NSNumber *)[model objectForKey:@"id"];
            college.name = (NSString *)[model objectForKey:@"name"];
            return college;
        }];
        [self.collegeTableView reloadData];
    } else {
        __weak typeof(self) weakSelf = self;
        [GFNetworkManager queryCollegeWithProvinceID:self.provinceId
                                             success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, NSArray<GFCollegeMTL *> *colleges) {
                                                 weakSelf.collegeDataSource = colleges;
                                                 [weakSelf.collegeTableView reloadData];
                                             } failure:^(NSUInteger taskId, NSError *error) {
                                                 //
                                             }];
    }
    
}

/**
 *  加载所有学校
 */
- (void)loadAllColleges {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"allColleges" ofType:@"plist"];
    self.allCollegesDataSource = [[NSArray alloc] initWithContentsOfFile:plistPath];
}

- (void)backBarButtonItemSelected {
    if (self.collegeSelectHandler && self.selectedCollege) {
        self.collegeSelectHandler(self.selectedCollege);
    }
    [super backBarButtonItemSelected];
}


#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.collegeTableView) {
#if 0 // modified by lhc, 2016-01-21
        return self.collegeDataSource.count;
#else
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 0;
#endif
    } else {
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return self.filteredCollegesDataSource.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GFCollegeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([GFCollegeTableViewCell class])];
    GFCollegeMTL *college = nil;
    
    if (tableView == self.collegeTableView) {
       college = [self.collegeDataSource objectAtIndex:indexPath.row];
    } else {
        NSDictionary *model = self.filteredCollegesDataSource[indexPath.row];
        college = [[GFCollegeMTL alloc] init];
        college.collegeId = (NSNumber *)[model objectForKey:@"id"];
        college.name = (NSString *)[model objectForKey:@"name"];
    }
        
    [cell bindWithModel:college];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [MobClick event:@"gf_gr_03_02_04_1"];
    
    GFCollegeMTL *college = nil;
    
    if (tableView == self.collegeTableView) {
        college = [self.collegeDataSource objectAtIndex:indexPath.row];
    } else {
        NSDictionary *model = self.filteredCollegesDataSource[indexPath.row];
        college = [[GFCollegeMTL alloc] init];
        college.collegeId = (NSNumber *)[model objectForKey:@"id"];
        college.name = (NSString *)[model objectForKey:@"name"];
    }
    
    self.selectedCollege = college;
    
    [self backBarButtonItemSelected];
}



#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [MobClick event:@"gf_gr_03_02_03_1"];
    [self.filteredCollegesDataSource removeAllObjects];
    self.filteredCollegesDataSource = [[self.allCollegesDataSource bk_select:^BOOL(id obj) {
        NSString *name = [((NSDictionary *)obj) objectForKey:@"name"];
        NSRange range = [name rangeOfString:searchText];
        return range.location != NSNotFound;
    }] mutableCopy];
}

@end
