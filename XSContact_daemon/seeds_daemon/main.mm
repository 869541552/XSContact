//
//  main.c
//  iTest_daemon
//
//  Created by Guoyanping on 13-5-9.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#include <stdio.h>
#include <CoreFoundation/CoreFoundation.h>
#import "iTestDaemonManager.h"
#import "config.h"

int main (int argc, const char * argv[])
{
 NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    // insert code here...
    
    printf("start daemon!\n");
   [[CFDaemonManger shareInstance] createPort];
    CFRunLoopRun();
    printf("stop daemon!\n");
    [pool release];
	return 0;
}

