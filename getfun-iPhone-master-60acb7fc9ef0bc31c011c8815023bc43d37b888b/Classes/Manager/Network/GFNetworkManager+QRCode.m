//
//  GFNetworkManager+QRCode.m
//  GetFun
//
//  Created by Liu Peng on 15/12/9.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFNetworkManager+QRCode.h"
#import "GFAccountManager.h"

#define GF_API_QUERY_QRCODE ApiAddress(@"/api/qr")

@implementation GFNetworkManager (QRCode)

+ (NSUInteger)getQRCodeImageWithType:(GFQRCodeType)type
                             content:(NSString *)content
                             success:(void (^)(NSUInteger taskId, NSInteger code, NSString * imgUrl, NSString *errorMessage))success
                             failure:(void (^)(NSUInteger taskId, NSError *error))failure {
    NSString *typeStr = @"";
    switch (type) {
        case GFQRCodeTypePreview: {
            typeStr = @"PREVIEW";
            break;
        }
        case GFQRCodeTypeDetail: {
            typeStr = @"DETAIL";
            break;
        }
        case GFQRCodeTypeGroup: {
            typeStr = @"GROUP";
            break;
        }
        default: {
            break;
        }
    }
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_QUERY_QRCODE
                                                    parameters:@{@"type" : typeStr,
                                                                 @"content" : content}
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           if (code == 1) {
                                                               NSString *url = [responseObject objectForKey:@"data"];
                                                               success(taskId, code, url, @"");
                                                           } else {
                                                               NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];
                                                               success(taskId, code, nil, apiErrorMessage);
                                                           }
                                                           
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           failure(taskId, error);
                                                       }];
    return taskId;
}

@end
