
//
//  CFHookInterface.xm
//  dialdeamon
//
//  Created by gyanping on 13-9-22.UIAlertView
//
//

#import <UIKit/UIKit.h>
#import "CFDaemonManger.h"
#include "substrate.h"
#import <MobilePhone/MobilePhone.h>
#import "config.h"

@interface SBApplicationController {}
+(id)sharedInstance;
-(id)applicationWithDisplayIdentifier:(id)bundleIdentifier;
@end

@interface SBApplication {}
-(id)displayIdentifier;
@end

@interface SBIcon {}
-(id)applicationBundleID;
@end

static NSString *directApp = @"com.apple.mobilephone";
static NSString *redirectTo = APP_BUNDLE_IDENTIFIER;
static NSString *backNumber = @"00000";
BOOL enabled;
BOOL iconsEditing;
BOOL firstIcon = YES;

//CFDaemonManger *daemonManger;

%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)application{
    %orig;
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"callBack"
//                          
//                                                    message:@"回调1111"
//                          
//                                                   delegate:nil
//                          
//                                          cancelButtonTitle:@"Thanks"
//                          
//                                          otherButtonTitles:nil];
//    
//    [alert show];
//    
//    [alert release];

//    daemonManger = [[CFDaemonManger alloc] init];
    [CFDaemonManger shareInstance];
    
}

//home键单击
-(void)_handleMenuButtonEvent
{
    if([CFDaemonManger shareisHookHomeKeys])
    {
     

    }
else
    %orig;
    
}
//home 键双击
-(void)handleMenuDoubleTap
{
    if([CFDaemonManger shareisHookHomeKeys])
    {
    }
    else
        %orig;

}
%end

//拦截来电
%group IncomingCall
%hook MPIncomingPhoneCallController
-(id)initWithCall:(id)call
{
    if([[CFDaemonManger getPhoneNumber:call] isEqualToString:backNumber])//(([CFDaemonManger shareisHookCallIn] == YES)&&([[CFDaemonManger getPhoneNumber:call] isEqualToString:backNumber]))//([[CFDaemonManger getPhoneNumber:call] isEqualToString:backNumber])
    {
        return nil;
    }
    else
    {
        return %orig;
    }
}
%end
%end

////修改通话界面
//
//%hook InCallController
//-(void)viewWillAppear:(BOOL)view
//{
//
//    if([CFDaemonManger shareisHookCallIn])
//    {
//        return ;
//    }
//    else
//    {
//        %orig;
//        
//    }
//    
//}
//
//%end

%hook PhoneApplication
-(BOOL)setMuted:(BOOL)muted
{
    if(muted)
      return %orig(NO);
    else
        return %orig(YES);
    
}
%end

%hook SBPluginManager
-(Class)loadPluginBundle:(id)bundle{
    Class result=%orig;
    NSString *bundleIdentifier=[bundle bundleIdentifier];
    
    if ([bundleIdentifier isEqualToString:@"com.apple.mobilephone.incomingcall"]) %init(IncomingCall);
//     if ([bundleIdentifier isEqualToString:@"com.apple.mobilephone"]) %init(mobilephone);
        return result;
}

%end

//icon 替换
%hook SBUIController

-(void)activateApplicationAnimated:(id)application {
    
	if(enabled&& [[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"XSContact://"]]) {
		
		if( [[application displayIdentifier] isEqualToString: directApp]) {
			SBApplication *app = [[objc_getClass("SBApplicationController") sharedInstance] applicationWithDisplayIdentifier:redirectTo];
			[[objc_getClass("SBUIController") sharedInstance] activateApplicationFromSwitcher:app];
		}
		else
		{
			%orig;
		}
		
	}
    else
    {
        %orig;
    }
}

%end


%hook SBIcon
NSString *appToDirect;
NSString *directAppToo;
-(void)touchesEnded:(id)ended withEvent:(id)event {
	%orig;
    if ([[objc_getClass("SBIconController") sharedInstance] isEditing]) {
		NSSet *touchSet = [event allTouches];
		switch ([touchSet count])
        {
            case 1: {
                UITouch *touchAmount = [[touchSet allObjects] objectAtIndex:0];
                switch ([touchAmount tapCount]) {
                    case 1: {
                        // No one likes a single tapp.... GET OUT OF HERE!
                    } break;
                        
                    case 2: {
                        // DOUBLE
//                        NSLog(@"Double Tap");
                        if(firstIcon) {
                            firstIcon = FALSE;
                            appToDirect = [self applicationBundleID];
//                            
                        }
                        else
                        {
                            firstIcon = TRUE;
                            directAppToo = [self applicationBundleID];
                            directApp = appToDirect;
                            redirectTo = directAppToo;
                            [appToDirect release];
                            [directAppToo release];
                        }
                    } break;
                        
                        
                }
            }
        }
	}
}

%end

static void LoadSettings()
{
#if 0
	NSDictionary *prefrences = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.cf.hft.plist"];

 
#endif
    NSString* prefrencesPathStr;
    NSString *plistPath = [ALL_APP_INSTALLATION_PLIST_PATH stringByAppendingString:ALL_APP_INSTALLATION_PLIST_NAME];
    
    NSDictionary *readCallData = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    if (readCallData)
    {
        NSMutableDictionary *systemData = [readCallData objectForKey:@"System"];
        NSMutableDictionary *userData = [readCallData objectForKey:@"User"];
        if (systemData)
        {
            NSMutableDictionary *temDic = [systemData objectForKey:APP_BUNDLE_IDENTIFIER];
            if (temDic)
            {
                prefrencesPathStr = [temDic objectForKey:@"Container"];
            }
        }
           
        if (userData)
        {
            NSMutableDictionary *temDic = [userData objectForKey:APP_BUNDLE_IDENTIFIER];
            if (temDic)
            {
                prefrencesPathStr = [temDic objectForKey:@"Container"];
            }
            
        }
       
        NSString* prefrencesStr =[prefrencesPathStr stringByAppendingString:@"/Library/Preferences/com.cf.hft.plist"];
        if (prefrencesStr)
        {
            NSDictionary *prefrences = [[NSDictionary alloc] initWithContentsOfFile:prefrencesStr];
            directApp = @"com.apple.mobilephone";//[[prefrences objectForKey:@"directApp"] retain];
            redirectTo = @"com.cf.hft";//[[prefrences objectForKey:@"redirect"] retain];
            enabled = [[prefrences objectForKey:@"cfBindingSysdail"] boolValue];
            backNumber = [prefrences objectForKey:@"sysCallBackNumber"]?[[prefrences objectForKey:@"sysCallBackNumber"] retain]:@"000000";
            [readCallData release];
            [prefrences release];
        }
        else
        {
            enabled = NO;
        }
        directApp = @"com.apple.mobilephone";//[[prefrences objectForKey:@"directApp"] retain];
        redirectTo = @"com.cf.hft";//[[prefrences objectForKey:@"redirect"] retain];
    }
}

static void SettingsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	[directApp release];
	[redirectTo release];
	LoadSettings();
}

__attribute__((constructor)) static void init()
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    %init;
    [pool release];
}

%ctor
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
     LoadSettings();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, SettingsChanged, CFSTR("com.cf.xscontact/updated"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	[pool drain];
}