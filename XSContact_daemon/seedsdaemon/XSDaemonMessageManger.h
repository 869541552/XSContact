//
//  XSDaemonMessageManger.h
//  XSContact
//
//  Created by gyanping on 14-2-11.
//  Copyright (c) 2014年 Seeds. All rights reserved.
//

#import <Foundation/Foundation.h>


#define XS_UIToDaemon_MeassageCenter_Name  @"org.XS.UIToDaemonCenter"
#define XS_UIToDaemon_MeassageRegister_Name  @"org.XS.UIToDaemonRegister"

#define XS_CPPortMSG_Key @"XSPortName"

//进程间通讯的命令
typedef enum
{
    //UI -> dylib
    
    kCFDialcmdTypeUIAppBecomeActive =0x1,
    kCFDialcmdTypeUIAppResignActive,
    kCFDialcmdTypeStartCall,
    kCFDialcmdTypeStopCall,
    KCFDialcmdTypeInterceptCallStart,
    KCFDialcmdTypeInterceptCallStop,
    KCFDialcmdTypeModifyCallOutViewStart,
    KCFDialcmdTypeModifyCallOutViewStop,
    KCFDialcmdTypeUIAppDidFinishLaunch,
    KCFDialcmdTypeModifyPlist,
    
    //dylib -> UI
    kCFDialmsgTypeSysTestFail = 0x32,
    kCFDialcmdTypeShowDylibVersion,
    
    //UI -> deamon
    kCFDialcmdTypeModifyCalllogsEvent = 0X50,
    
    //deamon -> UI
    kCFDialmsgTypeSysCalllogsDeleFail = 0x64,
    
}XSPort_MSG_ID;


@interface XSDaemonMessageManger : NSObject

+(id)shareInstance;
-(void)createPortMessage;
-(void)releasePortMessage;


@end
