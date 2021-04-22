//
//  EMColor.h
//  emlearn-ios
//
//  Created by ictc on 2020/10/20.
//  Copyright © 2020 ictc. All rights reserved.
//

#ifndef EMDefines_h
#define EMDefines_h

#define IS_iPhoneX (\
{\
BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);}\
)

#define EMVIEWTOPMARGIN (IS_iPhoneX ? 22.f : 0.f)
#define EMVIEWBOTTOMMARGIN (IS_iPhoneX ? 34.f : 0.f)

#define kColor_LightGray [UIColor colorWithRed:247 / 255.0 green:247 / 255.0 blue:249 / 255.0 alpha:1.0]

#define kColor_Gray [UIColor colorWithRed:229 / 255.0 green:229 / 255.0 blue:229 / 255.0 alpha:1.0]

//#define kColor_Blue [UIColor colorWithRed:45 / 255.0 green:116 / 255.0 blue:215 / 255.0 alpha:1.0]

#define kColor_Purple [UIColor colorWithRed:178 / 255.0 green:178 / 255.0 blue:232 / 255.0 alpha:1.0]

#define kColor_DeepPurple [UIColor colorWithRed:112 / 255.0 green:102 / 255.0 blue:209 / 255.0 alpha:1.0]

#define kColor_Blue [UIColor colorWithRed:198 / 255.0 green:202 / 255.0 blue:215 / 255.0 alpha:1.0]

#define kColor_DeepBlue [UIColor colorWithRed:97 / 255.0 green:108 / 255.0 blue:143 / 255.0 alpha:1.0]

#define gSmallVideoSize 100

//消息动图
#define MSG_EXT_GIF_ID @"em_expression_id"
#define MSG_EXT_GIF @"em_is_big_expression"
#define MSG_EXT_READ_RECEIPT @"em_read_receipt"
#define MSG_EXT_UN_READ_RECEIPT @"em_read_unreceipt"

//消息撤回
#define MSG_EXT_RECALL @"em_recall"

//多人会议邀请
#define MSG_EXT_CALLOP @"em_conference_op"
#define MSG_EXT_CALLID @"em_conference_id"
#define MSG_EXT_CALLPSWD @"em_conference_password"

#define ROLE_TYPE_STUDENT @"student"
#define ROLE_TYPE_TEACHER @"teacher"

#define CONFR_TYPE_SMALL @"small"
#define CONFR_TYPE_ONE @"one"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width;
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height;
#endif /* EMDefines_h */
