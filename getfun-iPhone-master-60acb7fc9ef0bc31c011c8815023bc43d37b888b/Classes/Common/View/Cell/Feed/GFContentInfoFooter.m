//
//  GFContentInfoFooter.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/17.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFContentInfoFooter.h"

typedef NS_ENUM(NSUInteger, GFContentInfoFooterStyle) {
    GFContentInfoFooterStyleDelete,
    GFContentInfoFooterStyleComment,
};


@interface GFContentInfoFooter ()

@property (nonatomic, strong) GFContentMTL *content;

@property (nonatomic, strong) UIImageView *viewCountImageView;
@property (nonatomic, strong) UILabel *viewCountLabel;
@property (nonatomic, strong) UIImageView *funCountImageView;
@property (nonatomic, strong) UILabel *funCountLabel;
@property (nonatomic, strong) UIView *seperatorLine;
@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, assign) GFContentInfoFooterStyle style;
@property (nonatomic, strong) UILabel *deleteTipLabel;

@end

@implementation GFContentInfoFooter
- (UIImageView *)viewCountImageView {
    if (!_viewCountImageView) {
        _viewCountImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_viewCount"]];
        [_viewCountImageView sizeToFit];
    }
    return _viewCountImageView;
}
- (UILabel *)viewCountLabel {
    if (!_viewCountLabel) {
        _viewCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _viewCountLabel.font = [UIFont systemFontOfSize:12.0f];
        _viewCountLabel.textColor = [UIColor textColorValue4];
    }
    return _viewCountLabel;
}
- (UIImageView *)funCountImageView {
    if (!_funCountImageView) {
        _funCountImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_fun"]];
        [_funCountImageView sizeToFit];
    }
    return _funCountImageView;
}
- (UILabel *)funCountLabel {
    if (!_funCountLabel) {
        _funCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _funCountLabel.font = [UIFont systemFontOfSize:12.0f];
        _funCountLabel.textColor = [UIColor textColorValue4];
    }
    return _funCountLabel;
}
- (UIView *)seperatorLine {
    if (!_seperatorLine) {
        _seperatorLine = [[UIView alloc] initWithFrame:CGRectZero];
        _seperatorLine.backgroundColor = [UIColor themeColorValue15];
    }
    return _seperatorLine;
}
- (UILabel *)commentLabel {
    if (!_commentLabel) {
        _commentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _commentLabel.font = [UIFont systemFontOfSize:14.0f];
        _commentLabel.numberOfLines = 1;
        _commentLabel.textColor = [UIColor textColorValue4];
    }
    return _commentLabel;
}

- (UILabel *)deleteTipLabel {
    if (!_deleteTipLabel) {
        _deleteTipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _deleteTipLabel.font = [UIFont systemFontOfSize:16.0f];
        _deleteTipLabel.numberOfLines = 1;
        _deleteTipLabel.textColor = [UIColor textColorValue1];
    }
    return _deleteTipLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

        [self addSubview:self.viewCountImageView];
        [self addSubview:self.viewCountLabel];
        [self addSubview:self.funCountImageView];
        [self addSubview:self.funCountLabel];
        [self addSubview:self.seperatorLine];
        [self addSubview:self.commentLabel];
        [self addSubview:self.deleteTipLabel];
        self.style = GFContentInfoFooterStyleComment;
    }
    return self;
}

-(void)setStyle:(GFContentInfoFooterStyle)style {
    _style = style;
    self.viewCountImageView.hidden = style==GFContentInfoFooterStyleDelete;
    self.viewCountLabel.hidden = style==GFContentInfoFooterStyleDelete;
    self.funCountImageView.hidden = style==GFContentInfoFooterStyleDelete;
    self.funCountLabel.hidden = style==GFContentInfoFooterStyleDelete;
    self.seperatorLine.hidden = style==GFContentInfoFooterStyleDelete;
    self.commentLabel.hidden = style==GFContentInfoFooterStyleDelete;
    
    self.deleteTipLabel.hidden = style!=GFContentInfoFooterStyleDelete;
}

+ (CGFloat)heightWithContent:(GFContentMTL *)content {
    
    CGFloat height = 40.0f;
    GFCommentMTL *comment = [content.comments count] > 0 ? [content.comments objectAtIndex:0] : nil;
    if (comment && content.contentInfo.status!=GFContentStatusDeleted) {
        height = 80.0f;
    }
    return height;
}

- (void)updateWithContent:(GFContentMTL *)content {
    
    _content = content;
    
    //处理该帖已经被删除
    if (content.contentInfo.status == GFContentStatusDeleted) {
        self.style = GFContentInfoFooterStyleDelete;
        self.deleteTipLabel.text = @"该内容已被删除";
    } else {
        self.style = GFContentInfoFooterStyleComment;
        // 从含义上来说，应该是viewCount~ BUT: 为了数据好看一点儿，用pullCount，数大!!! 问沈娜
        self.viewCountLabel.text = [NSString stringWithFormat:@"%ld", (long)[content.contentInfo.pullCount integerValue]];
        self.funCountLabel.text = [NSString stringWithFormat:@"%ld", (long)[content.contentInfo.funCount integerValue]];
        
        GFCommentMTL *comment = [content.comments count] > 0 ? [content.comments objectAtIndex:0] : nil;
        if (comment) {
            NSString *commentString = @"";
            NSString *nickName = comment.user.nickName;
            if (nickName) {
                commentString = [NSString stringWithFormat:@"%@: ", nickName];
            }
            NSString *commentContent = comment.commentInfo.commentContent;
            if (commentContent) {
                commentString = [commentString stringByAppendingString:commentContent];
            }
            
            const CGFloat fontSize = 14.0;
            NSMutableAttributedString *attrString = nil;
            if (commentString) {
                attrString = [[NSMutableAttributedString alloc] initWithString:commentString];
                NSUInteger nickNameLength = [nickName length];
                NSUInteger length = [attrString length];
                
                //设置字体
                UIFont *baseFont = [UIFont systemFontOfSize:fontSize];
                [attrString addAttribute:NSFontAttributeName value:baseFont range:NSMakeRange(0, length)];
                
                //设置颜色
                UIColor *nickNameColor = [UIColor textColorValue8];
                UIColor *textColor = [UIColor textColorValue1];
                
                [attrString addAttribute:NSForegroundColorAttributeName
                                   value:textColor
                                   range:NSMakeRange(0, length)];
                [attrString addAttribute:NSForegroundColorAttributeName
                                   value:nickNameColor
                                   range:NSMakeRange(0, nickNameLength)];
            } else {
                attrString = [[NSMutableAttributedString alloc] initWithString:@""];
            }
            self.commentLabel.attributedText = attrString;
        }
    }
    
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.content.contentInfo.status == GFContentStatusDeleted){
        [self.deleteTipLabel sizeToFit];
        self.deleteTipLabel.origin = CGPointMake(15, self.height/2 - self.deleteTipLabel.height/2);        
    } else{
        GFCommentMTL *comment = [self.content.comments count] > 0 ? [self.content.comments objectAtIndex:0] : nil;
        
        [self.viewCountImageView sizeToFit];
        [self.viewCountLabel sizeToFit];
        [self.funCountImageView sizeToFit];
        [self.funCountLabel sizeToFit];
        
        if (comment) {
            self.seperatorLine.hidden = NO;
            self.commentLabel.hidden = NO;
            
            self.viewCountImageView.frame = ({
                CGFloat y = self.height/4 - self.viewCountImageView.height/2;
                CGRect rect = CGRectMake(15,
                                         y,
                                         self.viewCountImageView.width,
                                         self.viewCountImageView.height);
                rect;
            });
            self.viewCountLabel.frame = ({
                CGFloat y = self.height/4 - self.viewCountLabel.height/2;
                CGRect rect = CGRectMake(self.viewCountImageView.right + 5,
                                         y,
                                         self.viewCountLabel.width,
                                         self.viewCountLabel.height);
                rect;
            });
            self.funCountImageView.frame = ({
                CGFloat y = self.height/4 - self.funCountImageView.height/2;
                CGRect rect = CGRectMake(90,
                                         y,
                                         self.funCountImageView.width,
                                         self.funCountImageView.height);
                rect;
            });
            self.funCountLabel.frame = ({
                CGFloat y = self.height/4 - self.funCountLabel.height/2;
                CGRect rect = CGRectMake(self.funCountImageView.right + 4,
                                         y,
                                         self.funCountLabel.width,
                                         self.funCountLabel.height);
                rect;
            });
            self.seperatorLine.frame = CGRectMake(0, self.height/2, self.width, 0.5f);
            self.commentLabel.size = CGSizeMake(self.width - 30, self.height/2);
            self.commentLabel.origin = CGPointMake(15, self.height*3/4 - self.commentLabel.height/2);
            
        } else {
            self.seperatorLine.hidden = YES;
            self.commentLabel.hidden = YES;
            
            self.viewCountImageView.frame = ({
                CGFloat y = self.height/2 - self.viewCountImageView.height/2;
                CGRect rect = CGRectMake(15,
                                         y,
                                         self.viewCountImageView.width,
                                         self.viewCountImageView.height);
                rect;
            });
            self.viewCountLabel.frame = ({
                CGFloat y = self.height/2 - self.viewCountLabel.height/2;
                CGRect rect = CGRectMake(self.viewCountImageView.right + 4,
                                         y,
                                         self.viewCountLabel.width,
                                         self.viewCountLabel.height);
                rect;
            });
            self.funCountImageView.frame = ({
                CGFloat y = self.height/2 - self.funCountImageView.height/2;
                CGRect rect = CGRectMake(70,
                                         y,
                                         self.funCountImageView.width,
                                         self.funCountImageView.height);
                rect;
            });
            self.funCountLabel.frame = ({
                CGFloat y = self.height/2 - self.funCountLabel.height/2;
                CGRect rect = CGRectMake(self.funCountImageView.right + 4,
                                         y,
                                         self.funCountLabel.width,
                                         self.funCountLabel.height);
                rect;
            });
        }

    }
    
}

@end
