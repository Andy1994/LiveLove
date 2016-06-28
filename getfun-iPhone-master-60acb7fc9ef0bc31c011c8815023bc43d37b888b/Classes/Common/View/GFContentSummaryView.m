//
//  GFContentSummaryView.m
//  GetFun
//
//  Created by zhouxz on 15/11/19.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFContentSummaryView.h"
#import "GFPictureMTL.h"
#import "GFHomeDefine.h"

@interface GFContentSummaryView ()

@property (nonatomic, strong) GFContentMTL *content;

@property (nonatomic, strong) UIImageView *picImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;

@end

@implementation GFContentSummaryView

- (UIImageView *)picImageView {
    if (!_picImageView) {
        _picImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _picImageView.clipsToBounds = YES;
        _picImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _picImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:16.0f];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.numberOfLines = 2;
        _titleLabel.textColor = [UIColor textColorValue1];
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subtitleLabel.font = [UIFont systemFontOfSize:13.0f];
        _subtitleLabel.backgroundColor = [UIColor clearColor];
        _subtitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _subtitleLabel.numberOfLines = 1;
        _subtitleLabel.textColor = [UIColor textColorValue3];
    }
    return _subtitleLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 2.0f;
        self.backgroundColor = [UIColor themeColorValue14];        
        [self addSubview:self.picImageView];
        [self addSubview:self.titleLabel];
        [self addSubview:self.subtitleLabel];
    }
    return self;
}

- (void)updateWithContent:(GFContentMTL *)content {
    switch (content.contentInfo.type) {
        case GFContentTypePicture:
        case GFContentTypeArticle: {
            
            GFPictureMTL *picture = nil;
            
            NSArray *pictureSummary = [content.contentSummary valueForKey:@"pictureSummary"];
            if ([pictureSummary count] > 0) {
                NSString *pictureKey = [pictureSummary objectAtIndex:0];
                picture = [content.pictures objectForKey:pictureKey];
            }
            [self.picImageView setImageWithURL:[NSURL URLWithString:[picture.url gf_urlStandardizedWithType:GFImageStandardizedTypeFeedLink gifConverted:YES]] placeholder:[UIImage imageNamed:@"placeholder_image"]];
            
            self.titleLabel.text = content.contentSummary.title;
            NSString *summary = @"";
            if ([content.contentSummary respondsToSelector:@selector(summary)]) {
                summary = [content.contentSummary valueForKey:@"summary"];
            }
            //KVC方式获取summary，不会调用getter方法，因此在这里单独转换编码(需要修改，不使用KVC编码)
            self.subtitleLabel.text = [summary stringByReplacingHTMLEntities];
            break;
        }
        case GFContentTypeLink: {
            
            GFContentSummaryLinkMTL *linkSummary = (GFContentSummaryLinkMTL *)content.contentSummary;
            
            GFPictureMTL *picture = [content.pictures objectForKey:linkSummary.urlImageUrl];

            NSString *urlTitle = linkSummary.urlTitle;
            if ([urlTitle length] == 0) {
                urlTitle = @"分享了一篇文章";
            }
            [self.picImageView setImageWithURL:[NSURL URLWithString:[picture.url gf_urlStandardizedWithType:GFImageStandardizedTypeFeedLink gifConverted:YES]] placeholder:[UIImage imageNamed:@"placeholder_link_image"]];
            self.titleLabel.text = urlTitle;
            
            NSString *urlSummary = linkSummary.urlSummary;
            if ([urlSummary length] == 0) {
                urlSummary = linkSummary.url;
            }
            self.subtitleLabel.text = urlSummary;
            break;
        }
        case GFContentTypeVote: {
            NSArray *voteItems = nil;
            if (content.contentDetail) {
                voteItems = [(GFContentDetailVoteMTL *)content.contentDetail voteItems];
                self.titleLabel.text = content.contentDetail.title;
                self.subtitleLabel.text = content.contentSummary.title;
            } else if (content.contentSummary) {
                voteItems = [(GFContentSummaryVoteMTL *)content.contentSummary voteItems];
                self.titleLabel.text = content.contentSummary.title;
                self.subtitleLabel.text = content.contentSummary.title;
            }
            
            GFVoteItemMTL *leftItem = nil;
            //GFVoteItemMTL *rightItem = nil;
            if (voteItems.count >=2) {
                leftItem = voteItems[0];
                //rightItem = voteItems[1];
            }
            
            NSString *url = nil;
            NSString *imageStorekey = leftItem.imageUrl;
            //NSString *imageStorekey = rightItem.imageUrl;
            if (imageStorekey.length > 0) {
                GFPictureMTL *picture = content.pictures[imageStorekey];

                url = [picture.url gf_urlStandardizedWithType:GFImageStandardizedTypeFeedLink gifConverted:YES];
            }
            [self.picImageView setImageWithURL:[NSURL URLWithString:url] placeholder:[UIImage imageNamed:@"placeholder_image"]];            
            break;
        }
            
        default: {
            break;
        }
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.picImageView.frame = CGRectMake(0, 0, self.height, self.height);

    CGFloat width = self.width-22-83-13;
    
    CGSize titleSize = [self.titleLabel sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    CGSize subTitleSize = [self.subtitleLabel sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    
    self.titleLabel.frame = CGRectMake(self.picImageView.right + 13.0f,
                                       self.height/2 - subTitleSize.height/2 - titleSize.height/2 - 4,
                                       width,
                                       titleSize.height);
    self.subtitleLabel.frame = CGRectMake(self.picImageView.right + 13.0f,
                                          self.height/2 + titleSize.height/2 - subTitleSize.height/2 + 4,
                                          width,
                                          subTitleSize.height);

//    //如果副标题为空，需要将标题居中显示
//    if ([self.subtitleLabel.text isEqualToString:@""]) {
//        self.titleLabel.frame = ({
//            CGFloat width = self.width-22-83-13;
//            CGSize size = [self.titleLabel sizeThatFits:CGSizeMake(width, MAXFLOAT)];
//            CGFloat y = self.height/2 - size.height/2;
//            CGRect rect = CGRectMake(self.picImageView.right+13, y, width, size.height);
//            rect;
//        });
//        
//    } else {
//        self.titleLabel.frame = ({
//            CGFloat width = self.width-22-83-13;
//            CGSize size = [self.titleLabel sizeThatFits:CGSizeMake(width, MAXFLOAT)];
//            CGFloat y = self.height/2 - size.height;
//            CGRect rect = CGRectMake(self.picImageView.right+13, y, width, size.height);
//            rect;
//        });
//        
//        self.subtitleLabel.frame = CGRectMake(self.titleLabel.x, self.titleLabel.bottom+5, self.titleLabel.width, 15);
//    }
}
@end
