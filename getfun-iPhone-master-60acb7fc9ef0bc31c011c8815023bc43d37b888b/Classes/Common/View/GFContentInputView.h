//
//  GFContentInputView.h
//  GetFun
//
//  Created by muhuaxin on 15/11/29.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HPGrowingTextView.h>

typedef NS_ENUM(NSInteger, GFInputViewStyle) {
    GFInputViewStyleFun     = 0,
    GFInputViewStyleShare   = 1
};

#define kInputViewHeight 52.0f

@interface GFContentInputView : UIView

@property (nonatomic, assign) GFInputViewStyle style;

@property (nonatomic, assign) NSInteger funCount;
@property (nonatomic, assign, getter=isFunned) BOOL funned;

@property (nonatomic, copy) void (^funButtonHandler)();
@property (nonatomic, copy) void (^shareButtonHandler)();

@property (nonatomic, strong, readonly) HPGrowingTextView *textView;
@property (nonatomic, strong, readonly) UILabel *funCountLabel;
@end
