//
//  iTestDaemonManager.h
//  iTest_daemon
//
//  Created by Guoyanping on 13-5-9.
//
//

#import <UIKit/UIKit.h>

@interface iTestDaemonManager : NSObject
{
    BOOL bConnectedToDaemon;
    CFMessagePortRef cfMessagePort;
}

+(iTestDaemonManager *)sharedInstance;
-(int)sendPortMessageToServer:(UInt8)cmd message:(UInt8*)data messageLen:(UInt16)dataLen;
-(void)createiTestFolder:(NSString *)folderPath;
-(void)copySmsDb;
@end
