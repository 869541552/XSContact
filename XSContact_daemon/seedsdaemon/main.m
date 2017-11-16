//
//  main.m
//  seedsdaemon
//
//  Created by gyanping on 13-10-29.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>
#import "CFDaemonManger.h"

int main (int argc, const char * argv[])
{

    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    	// insert code here...
    [[CFDaemonManger shareInstance] createPort];
    	NSLog(@"Hello, World!");
    CFRunLoopRun();
   [pool release];
	return 0;
}

