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
#import "dlfcn.h"
#import "notify.h"
#define kNotificationNameDidChangeDisplayStatus    @"com.cf.xscontact/updated"
static BOOL isHookCallIn = NO;
static BOOL isHookHomeKeys = NO;
static BOOL isHookCallOutView = NO;

static BOOL isStartHookCall = NO;

@interface CFDaemonManger ()
- (int)IPAInstall:(NSString *)path;
@end

@implementation CFDaemonManger

static CFDataRef CFReciveCallBack(CFMessagePortRef local, SInt32 msgid, CFDataRef cfData, void *info)
{
    uint8_t *data = (uint8_t *) CFDataGetBytePtr(cfData);
	UInt16 dataLen = CFDataGetLength(cfData);
    
    [[CFDaemonManger shareInstance] receivePortMessageFormDaemonSys:msgid data:data datalen:dataLen];
    return nil;
}

/*
static void callBack(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    CTCall *call = (CTCall *)[(NSDictionary *)userInfo objectForKey:@"kCTCall"];
    NSString *caller = CTCallCopyAddress(NULL, call); // caller 便是来电号码
    int callState =  CTCallGetStatus(call);
    
    
    if (isStartHookCall)
    {
        if (callState == 4)
        {
            if( caller == nil
               || [caller isEqualToString:@"02032134000"]
               || [caller isEqualToString:@"020-32134000"]
               || [caller isEqualToString:@""]||[caller isEqualToString:@"18501616482"])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"callBack"
                                      
                                                                message:@"回调1111"
                                      
                                                               delegate:nil
                                      
                                                      cancelButtonTitle:@"Thanks"
                                      
                                                      otherButtonTitles:nil];
                
                [alert show];
                
                [alert release];
                isHookCallIn = YES;
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"callBack"
                                      
                                                                message:@"回调22222"
                                      
                                                               delegate:nil
                                      
                                                      cancelButtonTitle:@"Thanks"
                                      
                                                      otherButtonTitles:nil];
                
                [alert show];
                
                [alert release];
                isHookCallIn = NO;
            }
        }
        else
            isHookCallIn = NO;
    }
    else
    {
        isHookCallIn = NO;
    }
}
 */

- (id) init
{
    self = [super init];
    if (self != nil)
    {
        setuid(0);
        setgid(0);
        [self createPort];
//         CTTelephonyCenterAddObserver(CTTelephonyCenterGetDefault(), NULL, &callBack, CFSTR("kCTCallStatusChangeNotification"), NULL, CFNotificationSuspensionBehaviorHold);
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

+(BOOL)shareisHookCallIn
{
    return isHookCallIn;
}

+(BOOL)shareisHookHomeKeys
{
    return isHookHomeKeys;
}

//+(void)setHookCallOut:(BOOL)isHook
//{
//    isHookCallOutView = isHook;
//}

+(BOOL)shareisHookCallOut
{
    return isHookCallOutView;
}

+(NSString *)getPhoneNumber:(CTCall *)call
{
    if (call)
    {
        return CTCallCopyAddress(NULL, call);
    }
    return nil;
}


//-(void)intoCallView:(NSString *)instr
//{
//    NSRange nameRange = [instr rangeOfString:@"~"];
//    int nameLocation = nameRange.location;
//    int nameLeight = nameRange.length;
//    NSString *nameStrs = [instr substringToIndex:nameLocation];
//    NSString *nunStr = [instr substringFromIndex:(nameLocation+nameLeight)];
//    [[CFCallingView shareInstance] showWithNumber:nunStr username:nameStrs];
//    [[CFCallingView shareInstance] showCallingView:YES];
//}
-(NSString *)getAppPathByBundleID:(NSString *)BundleIdentifier
{
    NSDictionary *prefrences = [[NSDictionary alloc]init ];
    //    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *plistPath = [ALL_APP_INSTALLATION_PLIST_PATH stringByAppendingPathComponent:ALL_APP_INSTALLATION_PLIST_NAME];
    if(plistPath)
    {
        NSDictionary *readCallData = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        NSMutableDictionary *systemData = [readCallData objectForKey:@"System"];
        NSMutableDictionary *userData = [readCallData objectForKey:@"User"];
        if (systemData)
        {
            NSMutableDictionary *temDic = [systemData objectForKey:BundleIdentifier];
            if (temDic)
            {
                NSString * pathstr = [temDic objectForKey:@"Container"];
                return pathstr;
            }
        }
        if (userData)
        {
            NSMutableDictionary *temDic = [userData objectForKey:BundleIdentifier];
            if (temDic)
            {
                NSString * pathstr = [temDic objectForKey:@"Container"];
                return pathstr;
            }
            
        }
    }
    return nil;
    
    
}

-(BOOL)copySysCallHistoryToMyApp
{
    BOOL res = NO;
    NSString *tmppath = [[self getAppPathByBundleID:APP_BUNDLE_IDENTIFIER] stringByAppendingFormat:@"/tmp/call_history.db"];
    NSString *callHistorydbPath = IPHONE_SYS_CALL_HISTORY_PATH;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:tmppath])
    {
        NSError *error;
        if ([fileManager removeItemAtPath:tmppath error:&error] == NO)
        {
            
        }
    }
    NSError* error=nil;
    [[NSFileManager defaultManager]copyItemAtPath:callHistorydbPath toPath:tmppath error:&error ];
    if (error!=nil)
    {
        
    }
    else
        res = YES;
    NSString *excutStr = [NSString stringWithFormat:@"chown mobile:mobile %@",tmppath];
    NSString *excutStr1 = [NSString stringWithFormat:@"chmod 0755 %@",tmppath];
    system([excutStr UTF8String]);
    system([excutStr1 UTF8String]);
    return res;
}

-(BOOL)copySysCallHistoryRebackSys
{
    
    BOOL res = NO;
    NSString *tmppath = IPHONE_SYS_CALL_HISTORY_PATH;
    NSString *callHistorydbPath = [[self getAppPathByBundleID:APP_BUNDLE_IDENTIFIER] stringByAppendingFormat:@"/tmp/call_history.db"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:tmppath])
    {
        NSString *excStr = [NSString stringWithFormat:@"rm %@",tmppath];
        system([excStr UTF8String]);
        //        NSError *error =nil;
        //        if ([fileManager removeItemAtPath:tmppath error:&error] == NO)
        //        {
        //            if (!error)
        //                res = YES;
        //        }
    }
    NSString *excStr = [NSString stringWithFormat:@"cp %@ %@",callHistorydbPath,tmppath];
    system([excStr UTF8String]);
    //    NSError* error=nil;
    //    [[NSFileManager defaultManager]copyItemAtPath:callHistorydbPath toPath:tmppath error:&error ];
    //     if (!error)
    //        res = YES;
    NSString *excutStr = [NSString stringWithFormat:@"chown _wireless:_wireless %@",tmppath];
    NSString *excutStr1 = [NSString stringWithFormat:@"chmod 0777 %@",tmppath];
    system([excutStr UTF8String]);
    system([excutStr1 UTF8String]);

    system("killall MobilePhone");
    //    system("chown mobile:mobile /usr/local/bin/test");
    //    system("chmod 0755 /usr/local/bin/test");
    return res;
    
}

/*
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


-(BOOL)deleteCalllogsForSys:(NSString *)phoneNum
{
    NSString* deleteStr = nil;
    if ([phoneNum isEqualToString:@"deleAll"])
    {
        deleteStr = @"DROP table call";
    }
    else
    {
        deleteStr = [NSString stringWithFormat:@"delete from call where address =  \"%@\"",phoneNum];
    }
    if ([self openDB])
    {
        
        char *err;
         
        const char *delSql = [deleteStr UTF8String];
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
*/
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


-(BOOL)deleteCalllogsForSys
{
    if ([self openDB])
    {
        
        char *err;
        NSString* deleteStr = [NSString stringWithFormat:@"delete from call where address =  \"%@\"",@"02032134000"];
        const char *delSql = [deleteStr UTF8String];
        if(sqlite3_exec(database, delSql, NULL, NULL, &err) == SQLITE_OK)
        {
            
            sqlite3_close(database);
            return YES;
        }
        else
        {
            sqlite3_close(database);
            NSLog(@"deleteMessageData fail!");
            return NO;
        }
        
    }
    return NO;
}

-(void)receivePortMessageFormDaemonSys:(int)cmd data:(uint8_t*)data datalen:(uint16_t)dataLen
{
    
    switch (cmd) {
        case kCFDialcmdTypeStartCall:
        {
            isHookHomeKeys = YES;
        }
            break;
        case kCFDialcmdTypeStopCall:
        {
            isHookHomeKeys = NO;
            
        }
            break;
        case kCFDialcmdTypeUIAppResignActive:
        {
            isHookHomeKeys = NO;
//            [self copySysCallHistoryRebackSys];
        }
            break;
        
        case kCFDialcmdTypeUIAppBecomeActive:
        {
            uint8_t *sentData = (uint8_t *)[APP_VERSION UTF8String];
            int len = strlen((const char *) sentData);
            
            [self sendMsgToDaemon: kCFDialcmdTypeShowDylibVersion msg:sentData msgLen:len];
        }
            break;
        case  KCFDialcmdTypeInterceptCallStart:
        {
//            isStartHookCall = YES;
            isHookCallIn = YES;
            
        }
            break;
        case KCFDialcmdTypeInterceptCallStop:
        {
//            isStartHookCall = NO;
            isHookCallIn = NO;
        }
            break;
        case KCFDialcmdTypeModifyCallOutViewStart:
        {
            
        }
            break;
        case KCFDialcmdTypeUIAppDidFinishLaunch:
        {
            uint8_t *sentData = (uint8_t *)[APP_VERSION UTF8String];
            int len = strlen((const char *) sentData);

            [self sendMsgToDaemon: kCFDialcmdTypeShowDylibVersion msg:sentData msgLen:len];
        }
            break;
//        case kCFDialcmdTypeModifyCalllogsEvent:
//        {
//            NSString *delstr = [NSString stringWithUTF8String:(const char *)data];
//            if (delstr)
//            {
//                [self deleteCalllogsForSys:delstr];
//            }
//            else
//            {
//                [self sendMsgToDaemon:kCFDialmsgTypeSysCalllogsDeleFail msg:nil msgLen:0];
//            }
//            
//        }
//            break;
        case KCFDialcmdTypeModifyPlist:
        {
            notify_post(kNotificationNameDidChangeDisplayStatus.UTF8String);
           
        }
            break;
        default:
            break;
    }
}
/*
typedef int (*MobileInstallationInstall)(NSString *path, NSDictionary *dict, void *na, NSString *path2_equal_path_maybe_no_use);
- (int)IPAInstall:(NSString *)path
{
    void *lib = dlopen("/System/Library/PrivateFrameworks/MobileInstallation.framework/MobileInstallation", RTLD_LAZY);
    if (lib)
    {
        MobileInstallationInstall pMobileInstallationInstall = (MobileInstallationInstall)dlsym(lib, "MobileInstallationInstall");
        if (pMobileInstallationInstall)
        {
            int ret = pMobileInstallationInstall(path, [NSDictionary dictionaryWithObject:@"User" forKey:@"ApplicationType"], nil, path);
            dlclose(lib);
            return ret;
        }
    }
    return -1;
}
 */
-(void)createPort
{
    //    NSLog(@"DaemonPort --- createPort");
    CFMessagePortRef local = CFMessagePortCreateLocal(kCFAllocatorDefault, CFSTR(CF_CLIENT_PORT_NAME),CFReciveCallBack, NULL, NULL);
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
    CFMessagePortRef sMessageSys = CFMessagePortCreateRemote(kCFAllocatorDefault, CFSTR(CF_SERVICE_PORT_NAME));
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
    isHookHomeKeys = NO;
    isHookCallIn = NO;
    [super dealloc];
}
@end
