//
//  GFDatePicker.h
//  GetFun
//
//  Created by zhouxz on 15/12/12.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GFDatePicker : NSObject

+ (ActionSheetDatePicker *)gf_showDatePickerInitialDate:(NSDate *)date
                          completion:(void (^)(NSDate *selectedDate))completion
                              cancel:(void (^)())cancel;

+ (ActionSheetDatePicker *)gf_showDatePickerInitialDate:(NSDate *)date
                                             completion:(void (^)(NSDate *))completion
                                                 cancel:(void (^)())cancel
                                                 origin:(UIView *)view;
@end
