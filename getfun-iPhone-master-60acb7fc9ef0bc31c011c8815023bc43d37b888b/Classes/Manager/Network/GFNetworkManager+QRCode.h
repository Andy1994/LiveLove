//
//  GFNetworkManager+QRCode.h
//  GetFun
//
//  Created by Liu Peng on 15/12/9.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFNetworkManager.h"

typedef NS_ENUM(NSUInteger, GFQRCodeType) {
    GFQRCodeTypePreview, //内容预览
    GFQRCodeTypeDetail, //内容详情
    GFQRCodeTypeGroup, //get帮
};

@interface GFNetworkManager (QRCode)

/**
 *  获取二维码图片url
 *
 *  @param accessToken
 *  @param type        二维码类型
 *  @param content     二维码的内容,如内容ID、get帮ID等，最后生成的二维码的内容是协议+该内容
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)getQRCodeImageWithType:(GFQRCodeType)type
                             content:(NSString *)content
                             success:(void (^)(NSUInteger taskId, NSInteger code, NSString * imgUrl, NSString *errorMessage))success
                             failure:(void (^)(NSUInteger taskId, NSError *error))failure;
@end
