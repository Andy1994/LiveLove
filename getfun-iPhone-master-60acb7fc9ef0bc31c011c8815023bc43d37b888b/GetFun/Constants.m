//
//  Constants.m
//  GetFun
//
//  Created by zhouxz on 16/1/27.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#ifndef _GF_CONSTANTS_H_
#define _GF_CONSTANTS_H_

#include "Constants.h"

NSString * userGenderKey(GFUserGender gender) {
    
    NSString *key = @"UNKNOWN";
    
    if (gender == GFUserGenderMale) key = @"MALE";
    if (gender == GFUserGenderFemale) key = @"FEMALE";
    
    return key;
}

GFUserGender userGender(NSString *key) {

    key = [key uppercaseString];
    GFUserGender gender = GFUserGenderUnknown;
    
    if ([key isEqualToString:userGenderKey(GFUserGenderMale)]) gender = GFUserGenderMale;
    if ([key isEqualToString:userGenderKey(GFUserGenderFemale)]) gender = GFUserGenderFemale;
    
    return gender;
}

NSString * unifiedFormatKey(NSString *key) {
    
    key = [key lowercaseString];
    NSString *unifiedKey = nil;

    if ([key isEqualToString:@"jpeg"] ||
        [key isEqualToString:@"jpg"]) {
        unifiedKey = @"jpg";
    } else if ([key isEqualToString:@"gif"]) {
        unifiedKey = @"gif";
    } else if ([key isEqualToString:@"png"]) {
        unifiedKey = @"png";
    }
    
    return unifiedKey;
}

NSString * pictureFormatKey(GFPictureFormat format) {
    
    NSString *key = nil;
    
    if (format == GFPictureFormatJPEG) key = @"jpg";
    if (format == GFPictureFormatGIF) key = @"gif";
    if (format == GFPictureFormatPNG) key = @"png";
    
    return key;
}

//format在JSON数据中均为小写
GFPictureFormat pictureFormat(NSString *key) {
    
    key = unifiedFormatKey(key);
    
    GFPictureFormat format = GFPictureFormatUnknown;
    if ([key isEqualToString:pictureFormatKey(GFPictureFormatJPEG)]) format = GFPictureFormatJPEG;
    if ([key isEqualToString:pictureFormatKey(GFPictureFormatGIF)]) format = GFPictureFormatGIF;
    if ([key isEqualToString:pictureFormatKey(GFPictureFormatPNG)]) format = GFPictureFormatPNG;
    
    return format;
}

NSString * contentTypeKey(GFContentType type) {
    
    NSString *key = @"unknown";
    
    if (type == GFContentTypeArticle) key = @"article";
    if (type == GFContentTypeLink) key = @"link";
    if (type == GFContentTypeVote) key = @"vote";
    if (type == GFContentTypePicture) key = @"album";
    
    return [key uppercaseString];
}

GFContentType contentType(NSString *key) {

    key = [key uppercaseString];
    GFContentType type = GFContentTypeUnknown;
    
    if ([key isEqualToString:contentTypeKey(GFContentTypeArticle)]) type = GFContentTypeArticle;
    if ([key isEqualToString:contentTypeKey(GFContentTypeLink)]) type = GFContentTypeLink;
    if ([key isEqualToString:contentTypeKey(GFContentTypeVote)]) type = GFContentTypeVote;
    if ([key isEqualToString:contentTypeKey(GFContentTypePicture)]) type = GFContentTypePicture;
    
    return type;
}

NSString * contentStatusKey(GFContentStatus status) {
    
    NSString *key = nil; //JSON没有未知类型
    
    if (status == GFContentStatusPoor) key = @"poor";
    if (status == GFContentStatusNormal) key = @"normal";
    if (status == GFContentStatusRefused) key = @"refused";
    if (status == GFContentStatusDeleted) key = @"deleted";
    
    return [key uppercaseString];
}

GFContentStatus contentStatus(NSString *key) {
    
    key = [key uppercaseString];
    GFContentStatus status = GFContentStatusUnknown;
    
    if ([key isEqualToString:contentStatusKey(GFContentStatusPoor)]) status = GFContentStatusPoor;
    if ([key isEqualToString:contentStatusKey(GFContentStatusNormal)]) status = GFContentStatusNormal;
    if ([key isEqualToString:contentStatusKey(GFContentStatusRefused)]) status = GFContentStatusRefused;
    if ([key isEqualToString:contentStatusKey(GFContentStatusDeleted)]) status = GFContentStatusDeleted;
    
    return status;
}

NSString *groupAuditStatusKey(GFGroupAuditStatus status) {
    
    NSString *key = nil;
    
    if (status == GFGroupAuditStatusAuditing) key = @"auditing";
    if (status == GFGroupAuditStatusPass) key = @"pass";
    if (status == GFGroupAuditStatusRefuse) key = @"refuse";
    if (status == GFGroupAuditStatusRefuseName) key = @"refuse_name";
    if (status == GFGroupAuditStatusRefuseImg) key = @"refuse_img";
    if (status == GFGroupAuditStatusRefuseDescription) key = @"refuse_description";
    
    return [key uppercaseString];
}

GFGroupAuditStatus groupAuditStatus(NSString *key) {
    
    key = [key uppercaseString];
    GFGroupAuditStatus status = GFGroupAuditStatusUnknown;
    
    if ([key isEqualToString:groupAuditStatusKey(GFGroupAuditStatusAuditing)]) status = GFGroupAuditStatusAuditing;
    if ([key isEqualToString:groupAuditStatusKey(GFGroupAuditStatusPass)]) status = GFGroupAuditStatusPass;
    if ([key isEqualToString:groupAuditStatusKey(GFGroupAuditStatusRefuse)]) status = GFGroupAuditStatusRefuse;
    if ([key isEqualToString:groupAuditStatusKey(GFGroupAuditStatusRefuseName)]) status = GFGroupAuditStatusRefuseName;
    if ([key isEqualToString:groupAuditStatusKey(GFGroupAuditStatusRefuseImg)]) status = GFGroupAuditStatusRefuseImg;
    if ([key isEqualToString:groupAuditStatusKey(GFGroupAuditStatusRefuseDescription)]) status = GFGroupAuditStatusRefuseDescription;
    
    return status;
}

NSString *userActionKey(GFUserAction action) {
    
    NSString *key = nil;
    if (action == GFUserActionPublish) key = @"publish";
    if (action == GFUserActionCheckin) key = @"checkin";
    
    return [key uppercaseString];
}

GFUserAction userAction(NSString *key) {
    
    key = [key uppercaseString];
    GFUserAction action = GFUserActionUnknown;
    
    if ([key isEqualToString:userActionKey(GFUserActionPublish)]) action = GFUserActionPublish;
    if ([key isEqualToString:userActionKey(GFUserActionCheckin)]) action = GFUserActionCheckin;
    
    return action;
}

NSString * basicMessageTypeKey(GFBasicMessageType type) {
    
    NSString *key = nil;
    
    if (type == GFBasicMessageTypeAudit) key = @"audit_msg";
    if (type == GFBasicMessageTypeComment) key = @"comment_msg";
    if (type == GFBasicMessageTypeFun) key = @"fun_msg";
    if (type == GFBasicMessageTypeParticipate) key = @"participate_msg";
    if (type == GFBasicMessageTypeFollow) key = @"follow";
    
    return [key uppercaseString];
}

GFBasicMessageType basicMessageType(NSString *key) {
    
    key = [key uppercaseString];
    GFBasicMessageType type = 0;
    
    if ([key isEqualToString:basicMessageTypeKey(GFBasicMessageTypeAudit)]) type = GFBasicMessageTypeAudit;
    if ([key isEqualToString:basicMessageTypeKey(GFBasicMessageTypeComment)]) type = GFBasicMessageTypeComment;
    if ([key isEqualToString:basicMessageTypeKey(GFBasicMessageTypeFun)]) type = GFBasicMessageTypeFun;
    if ([key isEqualToString:basicMessageTypeKey(GFBasicMessageTypeParticipate)]) type = GFBasicMessageTypeParticipate;
    if ([key isEqualToString:basicMessageTypeKey(GFBasicMessageTypeFollow)]) type = GFBasicMessageTypeFollow;
    
    return type;
}

NSString * messageTypeKey(GFMessageType type) {
    
    NSString *key = @"unknown";
    
    if (type == GFMessageTypeAuditUser) key = @"audit_user";
    if (type == GFMessageTypeAuditContent) key = @"audit_content";
    if (type == GFMessageTypeAuditComment) key = @"audit_comment";
    if (type == GFMessageTypeAuditGroup) key = @"audit_group";

    if (type == GFMessageTypeComment) key = @"comment";
    if (type == GFMessageTypeCommentReply) key = @"comment_reply";
    
    if (type == GFMessageTypeFunContent) key = @"fun_content";
    if (type == GFMessageTypeFunComment) key = @"fun_comment";
    
    if (type == GFMessageTypeParticipate) key = @"participate_vote";
    
    if (type == GFMessageTypeActivity) key = @"activity";
    
    if (type == GFMessageTypeNotify) key = @"notify";
    
    if (type == GFMessageTypeFollow) key = @"follow";
    
    return [key uppercaseString];
}

GFMessageType messageType(NSString *key) {
    
    key = [key uppercaseString];
    GFMessageType type = 0;

    if ([key isEqualToString:messageTypeKey(GFMessageTypeAuditUser)]) type = GFMessageTypeAuditUser;
    if ([key isEqualToString:messageTypeKey(GFMessageTypeAuditContent)]) type = GFMessageTypeAuditContent;
    if ([key isEqualToString:messageTypeKey(GFMessageTypeAuditComment)]) type = GFMessageTypeAuditComment;
    if ([key isEqualToString:messageTypeKey(GFMessageTypeAuditGroup)]) type = GFMessageTypeAuditGroup;
    if ([key isEqualToString:messageTypeKey(GFMessageTypeComment)]) type = GFMessageTypeComment;
    if ([key isEqualToString:messageTypeKey(GFMessageTypeCommentReply)]) type = GFMessageTypeCommentReply;
    if ([key isEqualToString:messageTypeKey(GFMessageTypeFunContent)]) type = GFMessageTypeFunContent;
    if ([key isEqualToString:messageTypeKey(GFMessageTypeFunComment)]) type = GFMessageTypeFunComment;
    if ([key isEqualToString:messageTypeKey(GFMessageTypeParticipate)]) type = GFMessageTypeParticipate;
    if ([key isEqualToString:messageTypeKey(GFMessageTypeActivity)]) type = GFMessageTypeActivity;
    if ([key isEqualToString:messageTypeKey(GFMessageTypeNotify)]) type = GFMessageTypeNotify;
    if ([key isEqualToString:messageTypeKey(GFMessageTypeFollow)]) type = GFMessageTypeFollow;
    
    return type;
}

NSString * acceptMessageTypeKey(GFAcceptMessageType type) {
    
    NSString *key = nil;
    
    if (type == GFAcceptMessageTypeSound) key = @"soundSwitch";
    if (type == GFAcceptMessageTypeContent) key = @"contentPushSwitch";
    if (type == GFAcceptMessageTypeComment) key = @"commentNotifySwitch";
    if (type == GFAcceptMessageTypeFun) key = @"funNotifySwitch";
    if (type == GFAcceptMessageTypeParticipate) key = @"participateNotifySwitch";
    if (type == GFAcceptMessageTypeNotify) key = @"systemNotifySwitch";
    
    return key;
}

GFAcceptMessageType acceptMessageType(NSString *key) {
    
    GFAcceptMessageType type = 0;
    
    if ([key isEqualToString:acceptMessageTypeKey(GFAcceptMessageTypeSound)]) type = GFAcceptMessageTypeSound;
    if ([key isEqualToString:acceptMessageTypeKey(GFAcceptMessageTypeContent)]) type = GFAcceptMessageTypeContent;
    if ([key isEqualToString:acceptMessageTypeKey(GFAcceptMessageTypeComment)]) type = GFAcceptMessageTypeComment;
    if ([key isEqualToString:acceptMessageTypeKey(GFAcceptMessageTypeFun)]) type = GFAcceptMessageTypeFun;
    if ([key isEqualToString:acceptMessageTypeKey(GFAcceptMessageTypeParticipate)]) type = GFAcceptMessageTypeParticipate;
    if ([key isEqualToString:acceptMessageTypeKey(GFAcceptMessageTypeNotify)]) type = GFAcceptMessageTypeNotify;
    
    return type;
}

#endif