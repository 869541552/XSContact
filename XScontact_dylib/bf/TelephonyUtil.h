//
//  TelephonyUtil.h
//  XSContact
//
//  Created by CF on 13-7-16.
//  Copyright (c) 2013年 CF All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

@interface TelephonyUtil : NSObject

extern  CFNotificationCenterRef CTTelephonyCenterGetDefault(void); // 获得 TelephonyCenter (电话消息中心) 的引用
extern  void CTTelephonyCenterAddObserver(CFNotificationCenterRef center, const void *observer, CFNotificationCallback callBack, CFStringRef name, const void *object, CFNotificationSuspensionBehavior suspensionBehavior);
extern  void CTTelephonyCenterRemoveObserver(CFNotificationCenterRef center, const void *observer, CFStringRef name, const void *object);
extern  NSString *CTCallCopyAddress(void *, CTCall *call); //获得来电号码
extern  void CTCallDisconnect(CTCall *call); // 挂断电话
extern  void CTCallAnswer(CTCall *call); // 接电话
extern  void CTCallAddressBlocked(CTCall *call);
extern  int CTCallGetStatus(CTCall *call); // 获得电话状态　拨出电话时为３，有呼入电话时为４，挂断电话时为５
extern  int CTCallGetGetRowIDOfLastInsert(void); // 获得最近一条电话记录在电话记录数据库中的位置
extern NSString *CTSettingCopyMyPhoneNumber();
extern void CTCallDial(NSString * number);


@end
