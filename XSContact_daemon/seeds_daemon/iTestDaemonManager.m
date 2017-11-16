//
//  iTestDaemonManager.m
//  iTest_daemon
//
//  Created by Guoyanping on 13-5-9.
//
//

#import "iTestDaemonManager.h"
#import "config.h"

static iTestDaemonManager *pDaemonManager = nil;

@implementation iTestDaemonManager


-(void)copySmsDb
{
    NSString *tmppath = [RC_ITEST_DB_PATH stringByAppendingFormat:@"sms.db"];
     NSString *smsdbPath = @"/private/var/mobile/Library/SMS/sms.db";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:tmppath])
    {
        NSError *error;
        if ([fileManager removeItemAtPath:tmppath error:&error] == NO)
        {
            NSLog(@"del OK");
        }
    }
    NSError* error=nil;
    [[NSFileManager defaultManager]copyItemAtPath:smsdbPath toPath:tmppath error:&error ];
    if (error!=nil) {
        NSLog(@"%@", error);
        NSLog(@"%@", [error userInfo]);
    }
       
}
static CFDataRef myCallBack(CFMessagePortRef local, SInt32 msgid, CFDataRef cfData, void *info)
{
    if (msgid == 0x64) {
        [[iTestDaemonManager sharedInstance] copySmsDb];
    }
    return nil;
}
static void initPort(){
 	CFMessagePortRef local = CFMessagePortCreateLocal(kCFAllocatorDefault, CFSTR("com.RC.telbook.message.port"), myCallBack, NULL, NULL);
	CFRunLoopSourceRef source = CFMessagePortCreateRunLoopSource(kCFAllocatorDefault, local, 0);
	CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
}
-(void)createiTestFolder:(NSString *)folderPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:folderPath isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) )
    {
        NSDictionary *attrib = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithUnsignedLong:0777], NSFilePosixPermissions, nil ];
        [fileManager
         createDirectoryAtPath:folderPath
         withIntermediateDirectories:YES
         attributes:attrib error:nil];
    }
    
}

-(iTestDaemonManager*)init
{
    self = [super init];
    if (!self) {
        return self;
    }
    cfMessagePort = 0;
    initPort();
    return self;
}
+(iTestDaemonManager *)sharedInstance
{
    if(!pDaemonManager)
    {
        pDaemonManager = [[iTestDaemonManager alloc]init];
    }
    return pDaemonManager;
}

-(void) portRefresh
{
    // still valid
	if (cfMessagePort && !CFMessagePortIsValid(cfMessagePort)){
		CFRelease(cfMessagePort);
		cfMessagePort = 0;
	}
	// create new one
	if (!cfMessagePort) {
		cfMessagePort = CFMessagePortCreateRemote(kCFAllocatorDefault, CFSTR("com.RC.telbook.server"));
	}
}

-(int)sendPortMessageToServer:(UInt8)cmd message:(UInt8*)data messageLen:(UInt16)dataLen 
{
    CFDataRef cfResultData;
    CFDataRef cfData;
    int result = 0;
    [self portRefresh];
    if (cfMessagePort && CFMessagePortIsValid(cfMessagePort)) {
        if (data != NULL){
            cfData = CFDataCreate(NULL, data, dataLen);
        }else{
            cfData = NULL;
        }
        CFStringRef replyMode = kCFRunLoopDefaultMode;
        
        result = CFMessagePortSendRequest(cfMessagePort, cmd, cfData, 1, 1, replyMode, &cfResultData);
        
        if (result == 0)
        {
            if (cfData != NULL)
            {
                CFRelease(cfData);
            }
        }
        else
        {
            
        }
	}
    else
    {
        result = -3;
    }
    
    return result;

}


-(void) dealloc
{
    [pDaemonManager release];
    [super dealloc];
}

@end
