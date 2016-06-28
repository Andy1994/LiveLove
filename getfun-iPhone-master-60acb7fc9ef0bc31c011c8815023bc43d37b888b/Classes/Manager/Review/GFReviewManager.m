//
//  GFReviewManager.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/3/23.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFReviewManager.h"

NSString * const GFUserDefaultsKeyReviewData = @"GFUserDefaultsKeyReviewData";

@implementation GFReviewMTL

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"launchCount" : @"launchCount",
             @"notifyCount" : @"notifyCount",
             @"nextNotifyTime" : @"nextNotifyTime"
             };
}

@end

@interface GFReviewManager ()

@end

@implementation GFReviewManager

+ (void)review {
    
    NSDictionary *dict = [GFUserDefaultsUtil objectForKey:GFUserDefaultsKeyReviewData];
    GFReviewMTL *reviewMTL = nil;
    if (dict) {
        reviewMTL = [MTLJSONAdapter modelOfClass:[GFReviewMTL class] fromJSONDictionary:dict error:nil];
    } else {
        reviewMTL = [[GFReviewMTL alloc] init];
        reviewMTL.nextNotifyTime = [NSDate todayReferenceTime];
    }
    
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    if (nowTime > reviewMTL.nextNotifyTime) {
        
        if (reviewMTL.launchCount == 5) {
            
            [UIAlertView bk_showAlertViewWithTitle:@""
                                           message:@"和盖小范感情这么好，去到app store给我个好评奖励下呗！"
                                 cancelButtonTitle:@"残忍的拒绝"
                                 otherButtonTitles:@[@"去好评奖励"]
                                           handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                               
                                               reviewMTL.notifyCount ++;
                                               reviewMTL.launchCount = 0;
                                               
                                               if (buttonIndex == 0) {
                                                   // 拒绝评论
                                                   [MobClick event:@"gf_pf_01_01_2_1"];
                                                   
                                                   if (reviewMTL.notifyCount == 3) {
                                                       // 已经拒绝三次，不再提示
                                                       reviewMTL.nextNotifyTime = [[NSDate distantFuture] timeIntervalSince1970];
                                                   } else {
                                                       NSDate *todayReferenceDate = [NSDate dateWithTimeIntervalSince1970:[NSDate todayReferenceTime]];
                                                       NSDate *nextNotifyDate = [todayReferenceDate dateByAddingDays:10];
                                                       reviewMTL.nextNotifyTime = [nextNotifyDate timeIntervalSince1970];
                                                   }
                                                   
                                                   [GFReviewManager saveReviewMTL:reviewMTL];
                                                   
                                               } else if (buttonIndex == 1) {
                                                   [MobClick event:@"gf_pf_01_01_1_1"];
                                                   reviewMTL.nextNotifyTime = [[NSDate distantFuture] timeIntervalSince1970];
                                                   [GFReviewManager saveReviewMTL:reviewMTL];
                                                   
                                                   // 去评论
                                                   NSString *reviewURL = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", kGetfunAppID];
                                                   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:reviewURL]];
                                               }
                                           }];
            
            
        } else {
            reviewMTL.launchCount ++;
            [GFReviewManager saveReviewMTL:reviewMTL];
        }
    } else {
        [GFReviewManager saveReviewMTL:reviewMTL];
    }
}

+ (void)saveReviewMTL:(GFReviewMTL *)reviewMTL {
    NSDictionary *dict = [MTLJSONAdapter JSONDictionaryFromModel:reviewMTL];
    [GFUserDefaultsUtil setObject:dict forKey:GFUserDefaultsKeyReviewData];
}

@end
