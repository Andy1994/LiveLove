//
//  UIColor+Getfun.m
//  GetFun
//
//  Created by zhouxz on 15/11/20.
//  Copyright © 2015年 17GetFun. All rights reserved.
//
#import "UIColor+Getfun.h"

@implementation UIColor (Getfun)

+ (UIColor *)gf_colorWithHex:(NSString *)hexColor {
    
    if ([hexColor hasPrefix:@"0X"] || [hexColor hasPrefix:@"0x"])
        hexColor = [hexColor substringFromIndex:2];
    else if ([hexColor hasPrefix:@"#"])
        hexColor = [hexColor substringFromIndex:1];
    
    
    unsigned int red, green, blue, alpha = 1.0f;
    NSRange range;
    range.length = 2;
    
    range.location = 0;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt: &red];
    
    range.location = 2;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt: &green];
    
    range.location = 4;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt: &blue];
    
    if ([hexColor length] == 8) {
        range.location = 6;
        [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt: &alpha];
    }
    
    return [UIColor colorWithRed:red/255.0F green:green/255.0f blue:blue/255.0f alpha:alpha];
}

+ (UIColor *)gf_colorWithHex:(NSString *)hexColor alpha:(CGFloat)alpha {
    
    if ([hexColor hasPrefix:@"0X"] || [hexColor hasPrefix:@"0x"])
        hexColor = [hexColor substringFromIndex:2];
    else if ([hexColor hasPrefix:@"#"])
        hexColor = [hexColor substringFromIndex:1];
    
    
    unsigned int red, green, blue;
    NSRange range;
    range.length = 2;
    
    range.location = 0;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt: &red];
    
    range.location = 2;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt: &green];
    
    range.location = 4;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt: &blue];
    
    return [UIColor colorWithRed:red/255.0F green:green/255.0f blue:blue/255.0f alpha:alpha];
}

//判断颜色是不是亮色
- (BOOL)gf_isLightColor {
    CGFloat components[3];
    [self getRGBComponents:components];
    CGFloat num = components[0] + components[1] + components[2];
    return num > 382;
}

//获取RGB分量
- (void)getRGBComponents:(CGFloat [3])components {
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
    int bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
#else
    int bitmapInfo = kCGImageAlphaPremultipliedLast;
#endif
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char resultingPixel[4];
    CGContextRef context = CGBitmapContextCreate(&resultingPixel,
                                                 1,
                                                 1,
                                                 8,
                                                 4,
                                                 rgbColorSpace,
                                                 bitmapInfo);
    CGContextSetFillColorWithColor(context, [self CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextRelease(context);
    CGColorSpaceRelease(rgbColorSpace);
    
    for (int component = 0; component < 3; component++) {
        components[component] = resultingPixel[component];
    }
}

#pragma mark - 文字颜色
+(UIColor *)textColorValue1 {
    return RGBCOLOR(51, 51, 52);
}
+(UIColor *)textColorValue2 {
    return RGBCOLOR(115, 115, 115);

}
+(UIColor *)textColorValue3 {
    return RGBCOLOR(153,153, 153);

}
+(UIColor *)textColorValue4 {
    return RGBCOLOR(170, 170, 170);

}
+(UIColor *)textColorValue5 {
    return RGBCOLOR(204, 204, 204);

}
+(UIColor *)textColorValue6 {
    return RGBCOLOR(255, 255, 255);

}
+(UIColor *)textColorValue7 {
    return RGBCOLOR(111, 65, 235);

}
+(UIColor *)textColorValue8 {
    return RGBCOLOR(149, 144, 190);

}
+(UIColor *)textColorValue9 {
    return RGBCOLOR(47, 213, 156);

}
+(UIColor *)textColorValue0 {
    return RGBCOLOR(54, 54, 54);

}

#pragma mark - 界面色彩规范
+ (UIColor *)themeColorValue7 {
    return RGBCOLOR(111, 65, 235);
}
+ (UIColor *)themeColorValue9 {
    return RGBCOLOR(47, 213, 156);
}
+ (UIColor *)themeColorValue10 {
    return RGBCOLOR(151, 111, 240);
}
+ (UIColor *)themeColorValue11 {
    return RGBCOLOR(38, 214, 200);
}
+ (UIColor *)themeColorValue12 {
    return RGBCOLOR(222, 222, 222);
}
+ (UIColor *)themeColorValue13 {
    return RGBCOLOR(236, 237, 238);
}
+ (UIColor *)themeColorValue14 {
    return RGBCOLOR(241, 242, 243);
}
+ (UIColor *)themeColorValue15 {
    return RGBCOLOR(223, 223, 223);
}
@end
