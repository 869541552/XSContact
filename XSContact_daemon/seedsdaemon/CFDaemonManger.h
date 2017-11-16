//
//  CFDaemonManger.h
//  CFHookInterface
//
//  Created by gyanping on 13-9-24.
//
//

#import <CoreFoundation/CoreFoundation.h>
#import <sqlite3.h>

#define CF_DAEMON_SERVICE_PORT_NAME "com.seeds.XSContect_daemon.service"

#define CF_DAEMON_CLIENT_PORT_NAME "com.seeds.XSContect_daemon.client"

typedef struct
{
    SInt32 msgid;
    uint8_t *data;
    uint16_t dataLen;
    
}PortData;

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
    KCFDialcmdTypeModifyPlist,
    
    //dylib -> UI
    kCFDialmsgTypeSysTestFail = 0x32,
    
    
    //UI -> deamon
    kCFDialcmdTypeModifyCalllogsEvent = 0X50,
    
    //deamon -> UI
    kCFDialmsgTypeSysCalllogsDeleFail = 0x64,
}CFHOOK_SYS_ID;

@interface CFDaemonManger : NSObject
{
    sqlite3 *database;
}
+(CFDaemonManger *)shareInstance;
-(void)createPort;
-(void)receivePortMessageFormDaemonSys:(int)cmd data:(uint8_t*)data datalen:(uint16_t)dataLen;
//daemon和动态库的通讯
- (void)sendMsgToDaemon:(int)cmd msg:(uint8_t*)data msgLen:(int)len;

@end
