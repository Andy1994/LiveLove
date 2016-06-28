//
//  UIDevice+Getfun.m
//  GetFun
//
//  Created by zhouxz on 15/11/14.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "UIDevice+Getfun.h"
#import <sys/socket.h>
#import <sys/sysctl.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <sys/utsname.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import <mach/machine.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

@implementation UIDevice (Getfun)

+ (NSString *)gf_idfv {
    NSString *deviceID = [GFUserDefaultsUtil objectForKey:GFUserDefaultsKeyGetfunIdentifierForVendor];
    if (!deviceID) {
        deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [GFUserDefaultsUtil setObject:deviceID forKey:GFUserDefaultsKeyGetfunIdentifierForVendor];
    }
    return deviceID;
}

+ (NSString *)gf_device_model {
    return [self sysInfoByName:"hw.machine"];
}

+ (NSString*)sysInfoByName:(char*)typeSpecifier
{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
    
    free(answer);
    return results;
}

@end
