//
//  GFDatePicker.m
//  GetFun
//
//  Created by zhouxz on 15/12/12.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFDatePicker.h"
#import <ActionSheetPicker-3.0/ActionSheetPicker.h>

@interface GFDatePicker ()

@end

@implementation GFDatePicker
+ (ActionSheetDatePicker *)gf_showDatePickerInitialDate:(NSDate *)date
                                             completion:(void (^)(NSDate *))completion
                                                 cancel:(void (^)())cancel
                                                 origin:(UIView *)view {
    
    NSDate *initialDate = date;
    if (!initialDate) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd";
        initialDate = [formatter dateFromString:@"1990-01-01"];
    }
    
    ActionSheetDatePicker *datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@""
                                                                      datePickerMode:UIDatePickerModeDate
                                                                        selectedDate:initialDate
                                                                           doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
                                                                               if (completion) {
                                                                                   completion(selectedDate);
                                                                               }
                                                                           } cancelBlock:^(ActionSheetDatePicker *picker) {
                                                                               if (cancel) {
                                                                                   cancel();
                                                                               }
                                                                           } origin:view];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *minimumDateComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    [minimumDateComponents setYear:1900];
    [minimumDateComponents setMonth:1];
    [minimumDateComponents setDay:1];
    NSDate *minDate = [calendar dateFromComponents:minimumDateComponents];
    NSDate *maxDate = [NSDate date];
    [datePicker setMinimumDate:minDate];
    [datePicker setMaximumDate:maxDate];
    
    [datePicker setCancelButton:[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:nil action:nil]];
    [datePicker setDoneButton:[[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:nil action:nil]];
    [datePicker showActionSheetPicker];
    return datePicker;
}

+ (ActionSheetDatePicker *)gf_showDatePickerInitialDate:(NSDate *)date
                          completion:(void (^)(NSDate *))completion
                              cancel:(void (^)())cancel {
    
    NSDate *initialDate = date;
    if (!initialDate) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd";
        initialDate = [formatter dateFromString:@"1990-01-01"];
    }
    
    ActionSheetDatePicker *datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@""
                                                                      datePickerMode:UIDatePickerModeDate
                                                                        selectedDate:initialDate
                                                                           doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
                                                                               if (completion) {
                                                                                   completion(selectedDate);
                                                                               }
                                                                           } cancelBlock:^(ActionSheetDatePicker *picker) {
                                                                               if (cancel) {
                                                                                   cancel();
                                                                               }
                                                                           } origin:[UIApplication sharedApplication].keyWindow];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *minimumDateComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    [minimumDateComponents setYear:1900];
    [minimumDateComponents setMonth:1];
    [minimumDateComponents setDay:1];
    NSDate *minDate = [calendar dateFromComponents:minimumDateComponents];
    NSDate *maxDate = [NSDate date];
    [datePicker setMinimumDate:minDate];
    [datePicker setMaximumDate:maxDate];
    
    [datePicker setCancelButton:[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:nil action:nil]];
    [datePicker setDoneButton:[[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:nil action:nil]];
    [datePicker showActionSheetPicker];
    return datePicker;
}

@end
