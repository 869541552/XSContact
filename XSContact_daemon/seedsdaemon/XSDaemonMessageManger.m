//
//  XSDaemonMessageManger.m
//  XSContact
//
//  Created by gyanping on 14-2-11.
//  Copyright (c) 2014年 Seeds. All rights reserved.
//

#import "XSDaemonMessageManger.h"
#import <AppSupport/CPDistributedMessagingCenter.h>
#import <sqlite3.h>
#import "config.h"

@interface XSDaemonMessageManger ()
{
    CPDistributedMessagingCenter *XSDaemonCenter;
    sqlite3 *database;
}
@end

@implementation XSDaemonMessageManger


+(id)shareInstance
{
    static XSDaemonMessageManger *_singletion;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singletion = [[XSDaemonMessageManger alloc] init];
    });
    
    return _singletion;
}

-(BOOL)openDB
{
    
    NSFileManager*fileManager=[NSFileManager defaultManager];
    BOOL find=[fileManager fileExistsAtPath:IPHONE_SYS_CALL_HISTORY_PATH];
    if(find)
    {
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
           NSLog(@"deleteMessageData fail!");
//            [self sendMsgToDaemon:kCFDialmsgTypeSysCalllogsDeleFail msg:nil msgLen:0];
            return NO;
        }
        
    }
    else
    {
//        [self sendMsgToDaemon:kCFDialmsgTypeSysCalllogsDeleFail msg:nil msgLen:0];
         NSLog(@"open db fail!");
        return NO;
    }
    
}

- (NSDictionary *)handleMessageNamed:(NSString *)name userInfo:(NSDictionary *)info
{
    NSUInteger type = [[info objectForKey:XS_CPPortMSG_Key] integerValue];
    if (type == 0X50)
    {
        NSString *sqlstr = [info objectForKey:@"executeStr"];
        if ([sqlstr length]) {
            [self executeCalllogsForSys:sqlstr];
        }
        else
            NSLog(@"executeStr = nil!");
    }
    
    return nil;
}


-(void)createPortMessage
{
   
    XSDaemonCenter = [CPDistributedMessagingCenter centerNamed:XS_UIToDaemon_MeassageCenter_Name];
     [XSDaemonCenter registerForMessageName:XS_UIToDaemon_MeassageRegister_Name target:self selector:@selector(handleMessageNamed:userInfo:)];
    [XSDaemonCenter runServerOnCurrentThread];
}

-(void)releasePortMessage
{

    [XSDaemonCenter unregisterForMessageName:XS_UIToDaemon_MeassageCenter_Name];
    XSDaemonCenter = nil;
}


@end
