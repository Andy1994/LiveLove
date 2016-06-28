//
//  GFLocationPicker.m
//  GetFun
//
//  Created by zhouxz on 15/12/12.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFProvinceAndCityPicker.h"
#import <ActionSheetPicker-3.0/ActionSheetPicker.h>

@interface GFProvinceAndCityPicker () <ActionSheetCustomPickerDelegate>

@property (nonatomic, assign) NSInteger selectedProvinceIndex;
@property (nonatomic, assign) NSInteger selectedCityIndex;

@property (nonatomic, strong) NSArray *provincesAndCities;

@property (nonatomic, copy) void (^completion)(NSNumber *, NSString *, NSNumber *, NSString *);
@property (nonatomic, copy) void (^cancel)();

@end

@implementation GFProvinceAndCityPicker
- (NSArray *)provincesAndCities {
    if (!_provincesAndCities) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"provinces_cities" ofType:@"plist"];
        _provincesAndCities = [[NSArray alloc] initWithContentsOfFile:plistPath];
    }
    return _provincesAndCities;
}

+ (void)gf_showProvinceAndCityPickerInitialProvinceId:(NSNumber *)iniProvinceId
                                        initialCityId:(NSNumber *)iniCityId
                                           completion:(void (^)(NSNumber *, NSString *, NSNumber *, NSString *))completion
                                               cancel:(void (^)())cancel {
    
    GFProvinceAndCityPicker *picker = [[GFProvinceAndCityPicker alloc] init];
    picker.completion = completion;
    picker.cancel = cancel;
    
    // 初始位置不再选择
//    NSInteger provinceIndex = 0;
//    NSInteger cityIndex = 0;
//    if (iniProvinceId && iniCityId) {
//        for (NSDictionary *provinceDict in picker.provincesAndCities) {
//            
//            NSNumber *provinceId = [provinceDict objectForKey:@"id"];
//            if ([provinceId isEqualToNumber:iniProvinceId]) {
//                provinceIndex = [picker.provincesAndCities indexOfObject:provinceDict];
//                
//                NSArray *cities = [provinceDict objectForKey:@"cities"];
//                for (NSDictionary *cityDict in cities) {
//                    
//                    NSNumber *cityId = [cityDict objectForKey:@"id"];
//                    if ([cityId isEqualToNumber:iniCityId]) {
//                        cityIndex = [cities indexOfObject:cityDict];
//                        break;
//                    }
//                }
//                break;
//            }
//        }
//    }
    
    ActionSheetCustomPicker *locationPicker = [[ActionSheetCustomPicker alloc] initWithTitle:@"选择位置"
                                                                                    delegate:picker
                                                                            showCancelButton:YES
                                                                                      origin:[UIApplication sharedApplication].keyWindow];
    
    [locationPicker setCancelButton:[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:nil action:nil]];
    [locationPicker setDoneButton:[[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:nil action:nil]];
    
    [locationPicker showActionSheetPicker];
}

#pragma mark - UIPickerViewDataSource Implementation
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    NSInteger numberOfRows = 0;
    switch (component) {
        case 0: {
            numberOfRows = [self.provincesAndCities count];
            break;
        }
            
        case 1: {
            NSDictionary *province = [self.provincesAndCities objectAtIndex:[pickerView selectedRowInComponent:0]];
            NSArray *cities = [province objectForKey:@"cities"];
            numberOfRows = [cities count];
            break;
        }
        default:
            break;
    }
    return numberOfRows;
}

#pragma mark UIPickerViewDelegate Implementation
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return SCREEN_WIDTH/2;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSString *title = @"";
    switch (component) {
        case 0: {
            title = [[self.provincesAndCities objectAtIndex:row] objectForKey:@"name"];
            break;
        }
        case 1: {
            NSDictionary *province = [self.provincesAndCities objectAtIndex:[pickerView selectedRowInComponent:0]];
            NSArray *cities = [province objectForKey:@"cities"];
            if ([cities count] > row) {
                title = [[cities objectAtIndex:row] objectForKey:@"name"];
            } else {
//                [pickerView reloadAllComponents];
                title = [[cities objectAtIndex:0] objectForKey:@"name"];
            }
            break;
        }
        default:
            break;
    }
    return title;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        [pickerView reloadComponent:1];
        [pickerView selectRow:0 inComponent:1 animated:NO];
    }
}

#pragma mark - ActionSheetCustomPickerDelegate
- (void)configurePickerView:(UIPickerView *)pickerView {
    pickerView.showsSelectionIndicator = NO;
}

- (void)actionSheetPicker:(AbstractActionSheetPicker *)actionSheetPicker configurePickerView:(UIPickerView *)pickerView{
    pickerView.showsSelectionIndicator = NO;
}

- (void)actionSheetPickerDidSucceed:(AbstractActionSheetPicker *)actionSheetPicker origin:(id)origin {
    
    if (self.completion) {
        
        UIPickerView *pickerView = (UIPickerView *)actionSheetPicker.pickerView;
        
        NSInteger firstComponentIndex = [pickerView selectedRowInComponent:0];
        NSDictionary *provinceInfo = [self.provincesAndCities objectAtIndex:firstComponentIndex];
        NSNumber *provinceId = [provinceInfo objectForKey:@"id"];
        NSString *provinceName = [provinceInfo objectForKey:@"name"];
        
        NSArray *cityList = [provinceInfo objectForKey:@"cities"];
        NSInteger secondComponentIndex = [pickerView selectedRowInComponent:1];
        if (secondComponentIndex >= [cityList count]) {
            secondComponentIndex = 0;
        }
        NSDictionary *cityInfo = [cityList objectAtIndex:secondComponentIndex];
        NSNumber *cityId = [cityInfo objectForKey:@"id"];
        NSString *cityName = [cityInfo objectForKey:@"name"];
        
        self.completion(provinceId, provinceName, cityId, cityName);
    }
}

- (void)actionSheetPickerDidCancel:(AbstractActionSheetPicker *)actionSheetPicker origin:(id)origin {
    if (self.cancel) {
        self.cancel();
    }
}

+ (NSString *)gf_getProvinceAndCityByProvinceId:(NSNumber *)provinceId cityId:(NSNumber *)cityId {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"provinces_cities" ofType:@"plist"];
    NSArray *provincesAndCities = [[NSArray alloc] initWithContentsOfFile:plistPath];
    
    NSDictionary *provinceDict = [provincesAndCities bk_match:^BOOL(id obj) {
        NSDictionary *dict = (NSDictionary *)obj;
        return provinceId && [dict[@"id"] isEqualToNumber:provinceId];
    }];
    NSString *selectedProvinceName = [provinceDict objectForKey:@"name"];
    
    NSArray *cities = [provinceDict objectForKey:@"cities"];
    NSDictionary *cityDict = [cities bk_match:^BOOL(id obj) {
        NSDictionary *dict = (NSDictionary *)obj;
        return cityId && [dict[@"id"] isEqualToNumber:cityId];
    }];
    
    NSString *selectedCityName = [cityDict objectForKey:@"name"];
    if (selectedProvinceName && selectedCityName && ![selectedCityName isEqualToString:@""] && ![selectedProvinceName isEqualToString:@""]) {
        return [[selectedProvinceName stringByAppendingString:@"|"] stringByAppendingString:selectedCityName];
    } else {
        return @"";
    }
}


@end
