//
//  CFDaemonManger.m
//  CFHookInterface
//
//  Created by gyanping on 13-9-24.
//
//

#import "CFDaemonManger.h"
#import <UIKit/UIKit.h>
#import "config.h"

@interface CFDaemonManger ()

@end

@implementation CFDaemonManger

static CFDataRef CFReciveCallBack(CFMessagePortRef local, SInt32 msgid, CFDataRef cfData, void *info)
{
    uint8_t *data = (uint8_t *)CFDataGetBytePtr(cfData);
	UInt16 dataLen = CFDataGetLength(cfData);
    [[CFDaemonManger shareInstance] receivePortMessageFormDaemonSys:msgid data:data datalen:dataLen];
    return nil;
}

- (id) init
{
    self = [super init];
    if (self != nil)
    {
//        setuid(0);
//        setgid(0);
//        [self createPort];
    }
    return self;
}

+(CFDaemonManger *)shareInstance
{
    
    static CFDaemonManger *_singletion;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        _singletion=[[CFDaemonManger alloc] init];
        
    });
     return _singletion;
 }


-(BOOL)openDB
{
    
    NSFileManager*fileManager=[NSFileManager defaultManager];
    BOOL find=[fileManager fileExistsAtPath:IPHONE_SYS_CALL_HISTORY_PATH];
    if(find)
    {
        //        LOG_IBLUE(@"OK, I find db");
        if (sqlite3_open([IPHONE_SYS_CALL_HISTORY_PATH UTF8String], &database)!= SQLITE_OK)
        {
            sqlite3_close(database);
            NSLog( @"Open database fail!");
        }
        return YES;
    }
    
    if(sqlite3_open([IPHONE_SYS_CALL_HISTORY_PATH UTF8String], &database) == SQLITE_OK)
    {
        return YES;
    }
    else
    {
        
        sqlite3_close(database);
        NSLog(@"can't fint db");
        return NO;
    }
    return NO;
}


-(BOOL)executeCalllogsForSys:(NSString *)sqlStr
{
//    NSString* deleteStr = sqlStr;
//    if ([phoneNum isEqualToString:@"deleAll"])
//    {
//        deleteStr = @"delete from call";
//    }
//    else
//    {
//        deleteStr = [NSString stringWithFormat:@"delete from call where address =  \"%@\"",phoneNum];
//    }
    if ([self openDB])
    {
        
        char *err;
         
        const char *delSql = [sqlStr UTF8String];
        if(sqlite3_exec(database, delSql, NULL, NULL, &err) == SQLITE_OK)
        {
            
            sqlite3_close(database);
            
            system("killall MobilePhone"); 
            return YES;
        }
        else
        {
            sqlite3_close(database);
//            NSLog(@"deleteMessageData fail!");
            [self sendMsgToDaemon:kCFDialmsgTypeSysCalllogsDeleFail msg:nil msgLen:0];
            return NO;
        }
        
    }
    else
    {
        [self sendMsgToDaemon:kCFDialmsgTypeSysCalllogsDeleFail msg:nil msgLen:0];
        return NO;
    }
    
}


-(void)receivePortMessageFormDaemonSys:(int)cmd data:(uint8_t*)data datalen:(uint16_t)dataLen
{
    
    switch (cmd) {
        case kCFDialcmdTypeModifyCalllogsEvent:
        {
            NSString *sqlstr = [NSString stringWithUTF8String:(const char *)data];
            if (sqlstr)
            {
                [self executeCalllogsForSys:sqlstr];
            }
            else
            {
                [self sendMsgToDaemon:kCFDialmsgTypeSysCalllogsDeleFail msg:nil msgLen:0];
            }
            
        }
            break;
        default:
            break;
    }
}

-(void)createPort
{
    //    NSLog(@"DaemonPort --- createPort");
    CFMessagePortRef local = CFMessagePortCreateLocal(kCFAllocatorDefault, CFSTR(CF_DAEMON_CLIENT_PORT_NAME),CFReciveCallBack, NULL, NULL);
	CFRunLoopSourceRef source = CFMessagePortCreateRunLoopSource(kCFAllocatorDefault, local, 0);
	CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
    //    NSLog(@"DaemonPort --- createPort  end");
}


//daemon和动态库的通讯
- (void)sendMsgToDaemon:(int)cmd msg:(uint8_t*)data msgLen:(int)len
{
    CFDataRef cfResultData = NULL;
    CFDataRef cfData = NULL;
    
    if (len!=0){
        cfData = CFDataCreate(NULL, data, len);
    }
    CFMessagePortRef sMessageSys = CFMessagePortCreateRemote(kCFAllocatorDefault, CFSTR(CF_DAEMON_SERVICE_PORT_NAME));
    if (sMessageSys == nil) {
        //        NSLog(@"CFMessagePortCreateRemote fail!");
    }
    int res = CFMessagePortSendRequest(sMessageSys, cmd, cfData, 1, 1, kCFRunLoopDefaultMode, &cfResultData);
    if (res == 0){
        if (cfResultData){
            CFRelease(cfResultData);
        }
    }
    
    if (len!=0){
        CFRelease(cfData);
    }
}

-(void)dealloc
{
    [super dealloc];
}

@end
