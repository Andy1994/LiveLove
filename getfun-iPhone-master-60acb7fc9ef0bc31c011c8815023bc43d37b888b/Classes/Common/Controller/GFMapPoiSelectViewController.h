//
//  GFMapPoiSelectViewController.h
//  GetFun
//
//  Created by zhouxz on 15/12/31.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFBaseViewController.h"
#import "GFLocationManager.h"

@interface GFMapPoiSelectViewController : GFBaseViewController

@property (nonatomic, copy) void(^mapPoiSelectHandler)(AMapPOI *poi);

@end
