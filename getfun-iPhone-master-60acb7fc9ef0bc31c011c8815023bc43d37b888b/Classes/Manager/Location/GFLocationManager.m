//
//  GFLocationManager.m
//  GetFun
//
//  Created by zhouxz on 15/11/28.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFLocationManager.h"
#import "GFNetworkManager+Common.h"

NSString * const kAMapApiKey = @"08ce42733376a1eaa1a6d938db19b97d";

NSString * const GFNotificationLocationUpdated = @"GFNotificationLocationUpdated";

@interface GFLocationManager () <AMapSearchDelegate>

@property (nonatomic, strong) CLLocation *lastLocation;

@property (nonatomic, strong) AMapLocationManager *locationManager;
@property (nonatomic, strong) AMapSearchAPI *searchAPI;

// 地理编码
@property (nonatomic, copy) void (^geoSuccessHandler)(AMapGeocode *location);
@property (nonatomic, copy) void (^geoFailureHandler)();

// 反向地理编码
@property (nonatomic, copy) void (^reGeoSuccessHandler)(AMapReGeocode *address);
@property (nonatomic, copy) void (^reGeoFailureHandler)();

// POI搜索
@property (nonatomic, copy) void (^poiSearchSuccessHandler)(AMapPOISearchResponse *result);
@property (nonatomic, copy) void (^poiSearchFailureHandler)();

+ (instancetype)sharedManager;

@end

@implementation GFLocationManager

+ (instancetype)sharedManager {
    static GFLocationManager *sharedManager;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        // 定位
        [AMapLocationServices sharedServices].apiKey = kAMapApiKey;
        // 搜索
        [AMapSearchServices sharedServices].apiKey = kAMapApiKey;
        sharedManager = [[GFLocationManager alloc] init];
    });
    return sharedManager;
}

- (AMapLocationManager *)locationManager {
    
    if (!_locationManager) {
        _locationManager = [[AMapLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    }
    return _locationManager;
}

- (AMapSearchAPI *)searchAPI {
    if (!_searchAPI) {
        _searchAPI = [[AMapSearchAPI alloc] init];
        _searchAPI.delegate = self;
    }
    return _searchAPI;
}

#pragma mark - class method
+ (void)initManager {
    [GFLocationManager startUpdateLocationSuccess:NULL failure:NULL];
}

+ (CLLocation *)lastLocation {
    CLLocation *location = [GFLocationManager sharedManager].lastLocation;
    
    if (!location) {
        [self startUpdateLocationSuccess:NULL failure:NULL];
    }
    
    return location;
}

+ (void)startUpdateLocationSuccess:(void (^)(CLLocation *, AMapLocationReGeocode *))success failure:(void (^)(NSError *))failure {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        GFLocationManager *manager = [GFLocationManager sharedManager];
        __weak typeof(manager) weakManager = manager;
        [manager.locationManager requestLocationWithReGeocode:YES
                                              completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      if (error) {
                                                          if (failure) {
                                                              failure(error);
                                                          }
                                                          return ;
                                                      }
                                                     else {
                                                          weakManager.lastLocation = location;
                                                          [weakManager.locationManager stopUpdatingLocation];
                                                          [[NSNotificationCenter defaultCenter] postNotificationName:GFNotificationLocationUpdated object:location];
                                                          if (success) {
                                                              success(location, regeocode);
                                                          }
#warning bug 3512 这里只是通过location来过滤，并没有解决频繁上报（频繁定位）的问题
                                                          if (location.coordinate.latitude > 0.01 || location.coordinate.longitude  > 0.01) {
                                                              [GFNetworkManager reportLocationLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
                                                          }
                                                      }
                                                  });
                                              }];
    });
}
         
+ (void)locationFromAddress:(NSString *)address
                    success:(void (^)(AMapGeocode *))success
                    failure:(void (^)())failure {
    
    AMapGeocodeSearchRequest *geoRequest = [[AMapGeocodeSearchRequest alloc] init];
    geoRequest.address = address;
    [GFLocationManager sharedManager].geoSuccessHandler = success;
    [GFLocationManager sharedManager].geoFailureHandler = failure;
    [[GFLocationManager sharedManager].searchAPI AMapGeocodeSearch:geoRequest];
}

- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response {
    if(response.geocodes.count == 0) {
        if (self.geoFailureHandler) {
            self.geoFailureHandler();
        }
    } else {
        if (self.geoSuccessHandler) {
            AMapGeocode *geoCode = [response.geocodes firstObject];
            self.geoSuccessHandler(geoCode);
        }
    }
}

+ (void)addressFromLocation:(CLLocation *)location
                    success:(void (^)(AMapReGeocode *))success
                    failure:(void (^)())failure {
    
    AMapReGeocodeSearchRequest *reGeoRequest = [[AMapReGeocodeSearchRequest alloc] init];
    reGeoRequest.location = [AMapGeoPoint locationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    reGeoRequest.radius = 200.0f;
    reGeoRequest.requireExtension = YES;
    [GFLocationManager sharedManager].reGeoSuccessHandler = success;
    [GFLocationManager sharedManager].reGeoFailureHandler = failure;
    [[GFLocationManager sharedManager].searchAPI AMapReGoecodeSearch:reGeoRequest];
}

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response {
    if(response.regeocode != nil) {
        if (self.reGeoSuccessHandler) {
            self.reGeoSuccessHandler(response.regeocode);
        }
    } else {
        if (self.reGeoFailureHandler) {
            self.reGeoFailureHandler();
        }
    }
}

+ (void)addressAroundLocation:(CLLocation *)location
                      keyword:(NSString *)keyword
                      success:(void (^)(AMapPOISearchResponse *))success
                      failure:(void (^)())failure {
    
    AMapPOIAroundSearchRequest *poiRequest = [[AMapPOIAroundSearchRequest alloc] init];
    poiRequest.location = [AMapGeoPoint locationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    if (keyword && [keyword length] > 0) {
        poiRequest.keywords = keyword;
    }
    //    types属性表示限定搜索POI的类别，默认为：餐饮服务|商务住宅|生活服务
    //    poiRequest.types = @"汽车服务|汽车销售|汽车维修|摩托车服务|餐饮服务|购物服务|生活服务|体育休闲服务|医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|交通设施服务|金融保险服务|公司企业|地名地址信息";
    poiRequest.requireExtension = YES;
    [GFLocationManager sharedManager].poiSearchSuccessHandler = success;
    [GFLocationManager sharedManager].poiSearchFailureHandler = failure;
    [[GFLocationManager sharedManager].searchAPI AMapPOIAroundSearch:poiRequest];
}

- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response {
    if(response.pois.count == 0) {
        [GFLocationManager sharedManager].poiSearchFailureHandler();
    } else {
        [GFLocationManager sharedManager].poiSearchSuccessHandler(response);
    }
}

@end