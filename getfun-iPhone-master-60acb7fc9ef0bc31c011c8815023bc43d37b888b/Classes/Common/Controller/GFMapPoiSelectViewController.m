//
//  GFMapPoiSelectViewController.m
//  GetFun
//
//  Created by zhouxz on 15/12/31.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFMapPoiSelectViewController.h"
#import <MAMapKit/MAMapKit.h>
#import "GFLocationTableViewCell.h"

#import "GFLocationManager.h"

@interface GFMapPoiSelectViewController () <MAMapViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) UIView *annotationView;
@property (nonatomic, strong) UITableView *addressTableView;
@property (nonatomic, strong) NSMutableArray *pois;

@property (nonatomic, assign) BOOL isCanceled; // 统计用，区分直接退回和点击不显示任何位置再退回

@end

@implementation GFMapPoiSelectViewController
- (MAMapView *)mapView {
    if (!_mapView) {
        _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.width)];
        _mapView.delegate = self;
        _mapView.zoomLevel *= 1.2f;
        [_mapView setUserTrackingMode:MAUserTrackingModeFollow animated:YES];
        
        _mapView.showsUserLocation = YES;
        _mapView.showsCompass = NO;
        _mapView.showsScale = NO;
    }
    return _mapView;
}

- (UIView *)annotationView {
    if (!_annotationView) {
        _annotationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _annotationView.center = self.mapView.center;
        _annotationView.backgroundColor = [UIColor themeColorValue10];
        _annotationView.layer.masksToBounds = YES;
        _annotationView.layer.cornerRadius = 10.0f;
    }
    return _annotationView;
}
- (UITableView *)addressTableView {
    if (!_addressTableView) {
        _addressTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.mapView.bottom, self.view.width, self.view.height - self.mapView.bottom) style:UITableViewStylePlain];
        _addressTableView.delegate = self;
        _addressTableView.dataSource = self;
        _addressTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_addressTableView registerClass:[GFLocationTableViewCell class] forCellReuseIdentifier:NSStringFromClass([GFLocationTableViewCell class])];
    }
    return _addressTableView;
}

- (NSMutableArray *)pois {
    if (!_pois) {
        _pois = [[NSMutableArray alloc] initWithCapacity:0];
        [_pois addObject:@"不再显示地理位置"];
    }
    return _pois;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"地点";
    
    [MAMapServices sharedServices].apiKey = kAMapApiKey;
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.annotationView];
    [self.view addSubview:self.addressTableView];
    
    self.isCanceled = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}


- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    if (updatingLocation && !userLocation.updating) {
        
        [mapView setUserTrackingMode:MAUserTrackingModeNone];
        [self queryPOIS:userLocation.location];
    }
}

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:mapView.centerCoordinate.latitude longitude:mapView.centerCoordinate.longitude];
    [self queryPOIS:location];
}

- (void)queryPOIS:(CLLocation *)location {
    __weak typeof(self) weakSelf = self;
    [GFLocationManager addressAroundLocation:location
                                     keyword:nil
                                     success:^(AMapPOISearchResponse *result) {
                                         [weakSelf.pois removeAllObjects];
                                         [weakSelf.pois addObject:@"不显示地理位置"];
                                         [weakSelf.pois addObjectsFromArray:result.pois];
                                         [weakSelf.addressTableView reloadData];
                                     } failure:^{
                                         //
                                     }];

}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.pois count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [GFLocationTableViewCell heightWithModel:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id model = [self.pois objectAtIndex:indexPath.row];
    GFLocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([GFLocationTableViewCell class])];
    [cell bindWithModel:model];
    return cell;
}

- (void)dealloc {
    _mapView.delegate = nil;
    [_mapView removeFromSuperview];
    _mapView = nil;
}

- (void)backBarButtonItemSelected {
    //self.mapView.delegate = nil;
    [super backBarButtonItemSelected];
    if (_isCanceled) {
        [MobClick event:@"gf_fb_05_01_03_1"];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.isCanceled = NO; //非直接取消返回
    
    id model = indexPath.row == 0 ? nil : [self.pois objectAtIndex:indexPath.row];
    if (self.mapPoiSelectHandler) {
        self.mapPoiSelectHandler(model);
    }
    
    if (model) {
        [MobClick event:@"gf_fb_05_01_01_1"];
    } else {
        [MobClick event:@"gf_fb_05_01_02_1"];
    }
    
    [self backBarButtonItemSelected];
}

@end
