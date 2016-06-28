//
//  GFContentDetailTagContainerView.m
//  GetFun
//
//  Created by muhuaxin on 15/12/7.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFContentDetailTagContainerView.h"

#import "GFTagMTL.h"
#import "GFContentMTL.h"

static NSInteger const kPadding = 17;

@implementation GFContentDetailTagContainerView
- (void)setContent:(GFContentMTL *)content {
    _content = content;
    [self generateTagPanelWithTags:self.content.tags];
}

- (void)generateTagPanelWithTags:(NSArray *)tags {
    
    [self.subviews bk_each:^(id obj) {
        [(UILabel *)obj removeFromSuperview];
    }];
    self.firstLabel = nil;
    
    
    for (GFTagInfoMTL *tagInfo in tags) {
        UILabel *label = [[self class] tagLabelWithTagInfo:tagInfo];
        if (!self.firstLabel) {
            self.firstLabel = label;
        }
        label.userInteractionEnabled = YES;
        __weak typeof(self) weakSelf = self;
        [label bk_whenTapped:^{
            if (weakSelf.tagHandler) {
                weakSelf.tagHandler(tagInfo,[tags indexOfObject:tagInfo]);
            }
        }];
        
        [self addSubview:label];
        
        if ([tags indexOfObject:tagInfo] == 2) break;
    }
}

+ (UILabel *)tagLabelWithTagInfo:(GFTagInfoMTL *)tagInfo {
    UILabel *label = [[UILabel alloc] init];
    label.userInteractionEnabled = YES;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor gf_colorWithHex:tagInfo.tagHexColor];
    label.layer.cornerRadius = 2.0f;
    label.layer.masksToBounds = YES;
    label.layer.borderWidth = 0.5f;
    label.text = tagInfo.tagName;
    label.layer.borderColor = [UIColor gf_colorWithHex:tagInfo.tagHexColor].CGColor;
    
    [label sizeToFit];
    label.width += 9 * 2;
    label.height = 22;
    
    return label;
}

+ (CGFloat)heightWithModel:(GFContentMTL *)content {
    NSArray *array = content.tags;
    if (array.count == 0) {
        return 0;
    } else {
        CGFloat lastX = kPadding;
        CGFloat lastY = 1.5;
        
        for (GFTagInfoMTL *tagInfo in content.tags) {
            UILabel *label = [GFContentDetailTagContainerView tagLabelWithTagInfo:tagInfo];
            
            if (lastX + label.width > SCREEN_WIDTH - 2 * kPadding) {
                lastX = kPadding;
                lastY += 22 + 5;
            }
            
            lastX += 5 + label.width;
            
            if ([content.tags indexOfObject:tagInfo] == 2) break;
        }
        return lastY + 22 + 1.5;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat lastX = kPadding;
    CGFloat lastY = 1.5;
    
    for (UILabel *label in [self subviews]) {
        
        if (lastX + label.width > SCREEN_WIDTH - 2 * kPadding) {
            lastX = kPadding;
            lastY += 22 + 5;
        }
        
        label.frame = CGRectMake(lastX, lastY, label.width, label.height);
        
        lastX += 5 + label.width;
    }
}
@end
