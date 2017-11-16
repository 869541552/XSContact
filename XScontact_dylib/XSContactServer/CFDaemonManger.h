//
//  CFDaemonManger.h
//  CFHookInterface
//
//  Created by gyanping on 13-9-24.
//
//

#import <Foundation/Foundation.h>
#import "TelephonyUtil.h"


#define CF_SERVICE_PORT_NAME "com.cf.XSContect.service"

#define CF_CLIENT_PORT_NAME "com.cf.XSContect.client_test"

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
    KCFDialcmdTypeUIAppDidFinishLaunch,
    KCFDialcmdTypeModifyPlist,
    
    //dylib -> UI
    kCFDialmsgTypeSysTestFail = 0x32,
     kCFDialcmdTypeShowDylibVersion,
    
    //UI -> deamon
    kCFDialcmdTypeModifyCalllogsEvent = 0X50,
    
    //deamon -> UI
    kCFDialmsgTypeSysCalllogsDeleFail = 0x64,
}CFHOOK_SYS_ID;

@interface CFDaemonManger : NSObject
{
    
}
+(CFDaemonManger *)shareInstance;
-(void)createPort;
-(void)receivePortMessageFormDaemonSys:(int)cmd data:(uint8_t*)data datalen:(uint16_t)dataLen;

+(BOOL)shareisHookHomeKeys;
+(BOOL)shareisHookCallIn;
//+(void)setHookCallOut:(BOOL)isHook; 
+(BOOL)shareisHookCallOut;
//daemon和动态库的通讯
- (void)sendMsgToDaemon:(int)cmd msg:(uint8_t*)data msgLen:(int)len;
+(NSString *)getPhoneNumber:(CTCall *)call;
@end
