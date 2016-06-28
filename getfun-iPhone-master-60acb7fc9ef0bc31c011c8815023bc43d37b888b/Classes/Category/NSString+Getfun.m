//
//  NSString+Getfun.m
//  getfun
//
//  Created by zhouxz on 15/11/11.
//  Copyright © 2015年 getfun. All rights reserved.
//

#import "NSString+Getfun.h"

@implementation NSString (Getfun)
- (BOOL)gf_isValidType:(GFValidateType)type {

    if (!self || [self length] == 0) {
        return NO;
    }
    
    if (type == GFValidateTypePhoneNumber) {
        return [self hasPrefix:@"1"] && [self length] == 11;
    } else if (type == GFValidateTypePassword) {
        return [self length] > 5 && [self length] < 21;
    } else if (type == GFValidateTypeEmail) {
        NSString *expression = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{1,5}";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", expression];
        return [predicate evaluateWithObject:self];
    } else if (type == GFValidateTypeURL) {
        NSString *expression = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", expression];
        return [predicate evaluateWithObject:self];
    } else if (type == GFValidateTypeNumber) {
        NSString *expression = @"^[0-9]*$";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", expression];
        return [predicate evaluateWithObject:self];
    } else if (type == GFValidateTypeCharacter) {

        return YES;
        // 带 # 号校验不通过，先不验了
//        NSString *expression = @"^[A-Za-z0-9]+$";
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", expression];
//        return [predicate evaluateWithObject:self];
    }
    
    return YES;
}

- (NSString *)gf_urlAppendWithHorizontalEdge:(NSUInteger)w verticalEdge:(NSUInteger)h mode:(GFImageProcessMode)mode {
    
    w *= [UIScreen mainScreen].scale;
    h *= [UIScreen mainScreen].scale;
    NSString *modeString = nil;
    switch (mode) {
        case GFImageProcessModeMaxLongEdgeAdaptiveShortEdgeAspect: //限定缩略图的长边最大值，短边自适应，等比缩放不裁剪，只有第一个参数有效
        {
            modeString = [NSString stringWithFormat:@"/0/w/%@", @(w)];
            break;
        }
        case GFImageProcessModeAdaptiveLongEdgeMaxShortEdgeAspect: //限定缩略图的短边最大值，长边自适应，等比缩放不裁剪，只有第二个参数有效
        {
            modeString = [NSString stringWithFormat:@"/0/h/%@", @(h)];
            break;
        }
        case GFImageProcessModeMaxLongEdgeMaxShortEdgeAspect://限定缩略图的长边和短边最大值，等比缩放不裁剪，两个参数均有效
        {
            modeString = [NSString stringWithFormat:@"/0/w/%@/h/%@", @(w), @(h)];
            break;
        }
            
        case GFImageProcessModeMinWidthMinHeightCut: //限定缩略图的长边和短边最小值，等比缩放，居中裁剪，两个参数均有效 normal
        {
            modeString = [NSString stringWithFormat:@"/1/w/%@/h/%@", @(w), @(h)];
            break;
        }
        case GFImageProcessModeMinEqualWHCut://限定缩略图的宽高最小值，且二者值相等。等比缩放，居中裁剪，只有第一个参数有效
        {
            modeString = [NSString stringWithFormat:@"/1/w/%@/", @(w)];
            break;
        }
            
        case GFImageProcessModeMaxWidthAdaptiveHeightAspect: //限定缩略图的宽最大值，高自适应，等比缩放不裁剪，只有第一个参数有效 normal
        {
            modeString = [NSString stringWithFormat:@"/2/w/%@", @(w)];
            break;

        }
        case GFImageProcessModeAdaptiveWidthMaxHeightAspect: //限定缩略图的高最大值，宽自适应，等比缩放不裁剪，只有第二个参数有效
        {
            modeString = [NSString stringWithFormat:@"/2/h/%@", @(h)];
            break;

        }
        case GFImageProcessModeMaxWidthMaxHeightAspect://限定缩略图的宽和高最大值，等比缩放不裁剪，两个参数均有效
        {
            modeString = [NSString stringWithFormat:@"/2/w/%@/h/%@", @(w), @(h)];
            break;
        }
            
        case GFImageProcessModeMinWidthMinHeightAspect: //限定缩略图的宽和高最小值，等比缩放不裁剪
        {
            modeString = [NSString stringWithFormat:@"/3/w/%@/h/%@", @(w), @(h)];
            break;
        }
        case GFImageProcessModeMinEqualWidthHeightAspect: //限定缩略图的宽高的最小值，且二者相等，等比缩放不裁剪，只有第一个参数有效
        {
            modeString = [NSString stringWithFormat:@"/3/w/%@", @(w)];
            break;
        }
            
        case GFImageProcessModeMinLongEdgeMinShortEdgeAspect: //限定缩略图的长边和短边最小值，等比缩放不裁剪
        {
            modeString = [NSString stringWithFormat:@"/4/w/%@/h/%@", @(w), @(h)];
            break;
        }
        case GFImageProcessModeMinEqualEdgeAspect://限定缩略图的短边和长边的最小值，且二者相等，等比缩放不裁剪，只有第一个参数有效
        {
            modeString = [NSString stringWithFormat:@"/4/w/%@", @(w)];
            break;
        }
            
            
        case GFImageProcessModeMinLongEdgeMinShortEdgeCut: //限定缩略图的长边和短边最小值，等比缩放，居中裁剪
        {
            modeString = [NSString stringWithFormat:@"/5/w/%@/h/%@", @(w), @(h)];
            break;
        }
        case GFImageProcessModeMinEqualEdgeCut://限定缩略图的短边和长边限定最小值，且二者相等，等比缩放，居中裁剪，只有第一个参数有效
        {
            modeString = [NSString stringWithFormat:@"/5/w/%@", @(w)];
            break;
        }
        default:
            break;
    }
    
    NSString *appendString = [@"?imageView2" stringByAppendingString:modeString];
    return [[self stringByAppendingString:appendString] stringByAppendingString:@"/ignore-error/1"];
}

- (NSString *)gf_urlAppendWithHorizontalEdge:(NSUInteger)w verticalEdge:(NSUInteger)h mode:(GFImageProcessMode)mode convertGIF:(BOOL)convert {
    NSString *urlString = [self gf_urlAppendWithHorizontalEdge:w verticalEdge:h mode:mode];
    if (convert) {
        urlString = [NSString stringWithFormat:@"%@/format/jpg", urlString];
    }
    return urlString;
}

- (NSString *)gf_urlStandardizedWithType:(GFImageStandardizedType)type gifConverted:(BOOL)isGifConverted {
    NSString *cutFormat = @"?imageView2/1/w/%@/h/%@/interlace/1/ignore-error/1"; //裁剪模板
    NSString *aspectFormat =  @"?imageView2/2/w/%@/interlace/1/ignore-error/1"; //不裁剪模板
    NSString *component = nil;
//    NSUInteger w = (NSUInteger)([UIScreen mainScreen].scale);
//    NSUInteger h = (NSInteger)[UIScreen mainScreen].scale;
    NSUInteger w = 1;
    NSUInteger h = 1;
    switch (type) {
        case GFImageStandardizedTypeFeedOnePicture: {
            w *= 600;
            h *= 450;
            component = [NSString stringWithFormat:cutFormat, @(w), @(h)];
            break;
        }
        case GFImageStandardizedTypeFeedTwoPictures: {
            w *= 300;
            h *= 225;
            component = [NSString stringWithFormat:cutFormat, @(w), @(h)];
            break;
        }
        case GFImageStandardizedTypeFeedThreePictures: {
            w *= 200;
            h *= 200;
            component = [NSString stringWithFormat:cutFormat, @(w), @(h)];
            break;
        }
        case GFImageStandardizedTypeVote: {
            w *= 300;
            h *= 300;
            component = [NSString stringWithFormat:cutFormat, @(w), @(h)];
            break;
        }
        case GFImageStandardizedTypeFeedLink: {
            w *= 200;
            h *= 200;
            component = [NSString stringWithFormat:cutFormat, @(w), @(h)];
            break;
        }
        case GFImageStandardizedTypeFeedComment: {
            w *= 200;
            h *= 200;
            component = [NSString stringWithFormat:cutFormat, @(w), @(h)];
            break;
        }
        case GFImageStandardizedTypeFeedFun: {
            w *= 200;
            h *= 200;
            component = [NSString stringWithFormat:cutFormat, @(w), @(h)];
            break;
        }
        case GFImageStandardizedTypeAvatarFeed: {
            w *= 56;
            h *= 56;
            component = [NSString stringWithFormat:cutFormat, @(w), @(h)];
            break;
        }
        case GFImageStandardizedTypeAvatarProfile: {
            w *= 112;
            h *= 112;
            component = [NSString stringWithFormat:cutFormat, @(w), @(h)];
            break;
        }
        case GFImageStandardizedTypeAvatarMessage: {
            w *= 112;
            h *= 112;
            component = [NSString stringWithFormat:cutFormat, @(w), @(h)];
            break;
        }
        case GFImageStandardizedTypeAvatarFollower: {
            w *= 112;
            h *= 112;
            component = [NSString stringWithFormat:cutFormat, @(w), @(h)];
            break;
        }
        case GFImageStandardizedTypeAvatarGroup: {
            w *= 112;
            h *= 112;
            component = [NSString stringWithFormat:cutFormat, @(w), @(h)];
            break;
        }
        case GFImageStandardizedTypeCollectedTag: {
            w *= 112;
            h *= 112;
            component = [NSString stringWithFormat:cutFormat, @(w), @(h)];
            break;
        }
        case GFImageStandardizedTypeCollectedTagList: {
            w *= 200;
            h *= 200;
            component = [NSString stringWithFormat:cutFormat, @(w), @(h)];
            break;
        }
        case GFImageStandardizedTypeHotTag: {
            w *= 300;
            h *= 225;
            component = [NSString stringWithFormat:cutFormat, @(w), @(h)];
            break;
        }
        case GFImageStandardizedTypeContentDetailArticle: {
            w *= 600;
            component = [NSString stringWithFormat:aspectFormat, @(w)];
            break;
        }
        case GFImageStandardizedTypeContentDetailPicture: {
            w *= 600;
            component = [NSString stringWithFormat:aspectFormat, @(w)];
            break;
        }
        case GFImageStandardizedTypeLargePicuture: {
            w *= 600;
            component = [NSString stringWithFormat:aspectFormat, @(w)];
            break;
        }
    }
    
    if (isGifConverted) {
        component = [NSString stringWithFormat:@"%@/format/jpg", component];
    }
    
    return [self stringByAppendingString:component];
}

- (NSString *)subStringWithPattern:(NSString *)pattern {
    NSError *error;
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *result = [reg firstMatchInString:self options:0 range:NSMakeRange(0, [self length])];
    if (result) {
        NSRange range = result.range;
        NSString *subString = [self substringWithRange:range];
        return subString;
    } else {
        return nil;
    }
}

/**
 *  根据字符串返回对应的分享类型
 *
 *  @return 
 */
- (GFShareType)gf_shareType {
    if ([self isEqualToString:@"WEIXIN"]) {
        return GFShareTypeWeChat;
    } else if ([self isEqualToString:@"CIRCLE"]) {
        return GFShareTypeTimeline;
    } else if ([self isEqualToString:@"WEIBO"]) {
        return GFShareTypeWeibo;
    } else if ([self isEqualToString:@"QQ"]) {
        return GFShareTypeQQ;
    } else if ([self isEqualToString:@"QZONE"]) {
        return GFShareTypeQZone;
    } else {
        return 0;
    }
}

- (NSDictionary *)urlQueryToDictionary {
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSArray *components = [self componentsSeparatedByString:@"&"];
    for (NSString *param in components) {
        NSArray *keyValues = [param componentsSeparatedByString:@"="];
        if ([keyValues count] == 2) {
            NSString *value = [[keyValues lastObject] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *key = [keyValues firstObject];
            
            [result setObject:value
                       forKey:key];
        }
    }
    
    return result;
}

@end


