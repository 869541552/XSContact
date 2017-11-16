//
//  CFHookInterface.xm
//  dialdeamon
//
//  Created by gyanping on 13-9-22.UIAlertView
//
//

#import <UIKit/UIKit.h>
//#import <SpringBoard/SpringBoard.h>
//#import <SpringBoard/SBIcon.h>
//#import "SpringBoardServices.h"
//#import <SpringBoardServices/SpringBoardServices.h>
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
BOOL enabled;
BOOL iconsEditing;
BOOL firstIcon = YES;
//CFDaemonManger *daemonManger;

%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)application{
    %orig;

//    daemonManger = [[CFDaemonManger alloc] init];
    
}

//home键单击
-(void)_handleMenuButtonEvent
{
    NSLog(@"单击 -- shareisHookHomeKeys = %d",[CFDaemonManger shareisHookHomeKeys]);
    if([CFDaemonManger shareisHookHomeKeys])
    {
     
        NSLog(@"hook 单击");
    }
else
    %orig;
    
}
//home 键双击
-(void)handleMenuDoubleTap
{
    if([CFDaemonManger shareisHookHomeKeys])
    {
         NSLog(@"hook 双击");
    }
    else
        %orig;

}
%end

//拦截来电
%group IncomingCall
%hook MPIncomingPhoneCallController
-(id)initWithCall:(id)call{
    if([CFDaemonManger shareisHookCallIn] == YES)
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

//修改通话界面

%hook InCallController
-(void)viewWillAppear:(BOOL)view
{

    if(1)//([CFDaemonManger shareisHookCallIn])
    {

//        [[CFCallingView shareInstance] showCallingView:YES];
        return ;
    }
    else
    {
        %orig;
        
    }
    
}

%end

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
    NSLog(@"LoadSettings");
#if 0
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
#endif
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

/*
#if 0
 //%group mobilephone
 
 
 //%hook PhoneViewController
 //-(void)viewWillAppear:(BOOL)view
 //{
 //    if([CFDaemonManger shareisHookHomeKeys])
 //    {
 //
 //        return ;
 //    }
 //   else
 //       %orig;
 //}
 //%end //PhoneViewController
 
 //%end //group mobilephone

//修改icon
%hook UIApplication

-(BOOL)launchApplicationWithIdentifier:(id)identifier suspended:(BOOL)suspended
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"替换"
                          
                                                    message:@"com.apple.MobileSMS hook"
                          
                                                   delegate:nil
                          
                                          cancelButtonTitle:@"Thanks"
                          
                                          otherButtonTitles:nil];
    
    [alert show];
    
    [alert release];
    
	if([identifier isEqualToString:@"com.apple.MobileSMS"])
    {
        return %orig(@"com.apple.mobilephone", suspended);
    }
    else
        
        return %orig;
}

%end

%hook PhoneRootViewController
-(void)loadView
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PhoneRootViewController"
                                                    message:@"loadView"
                          
                                                   delegate:nil
                          
                                          cancelButtonTitle:@"OK"
                          
                                          otherButtonTitles:nil];
    
    [alert show];
    
    [alert release];
    %orig ;
}
-(id)init
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PhoneRootViewController"
                                                    message:@"init"
                          
                                                   delegate:nil
                          
                                          cancelButtonTitle:@"OK"
                          
                                          otherButtonTitles:nil];
    
    [alert show];
    
    [alert release];
    return %orig;
}
%end

%hook PhoneApplication

-(void)applicationWillEnterForeground:(id)application
{
    NSString * srt;
      if([CFDaemonManger shareisHookCallIn] == YES)
            srt = @"shareisHookCallIn = YES";
        else
              srt = @"shareisHookCallIn = NO";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PhoneApplication"
                                                    message:srt
                          
                                                   delegate:nil
                          
                                          cancelButtonTitle:@"OK"
                          
                                          otherButtonTitles:nil];
    
    [alert show];
    
    [alert release];
    if([CFDaemonManger shareisHookCallIn] == NO)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cfdial://12"]];
    return;
}
%end
#endif




#if 0
extern "C" int SBSLaunchApplicationWithIdentifier(CFStringRef displayIdentifier, Boolean suspended) __OSX_AVAILABLE_STARTING(__MAC_NA, __IPHONE_3_0);

static int (*original_SBSLaunchApplicationWithIdentifier)(CFStringRef displayIdentifier, Boolean suspended);

static int replaced_SBSLaunchApplicationWithIdentifier(CFStringRef displayIdentifier, Boolean suspended)
{
	if ([(NSString *)displayIdentifier isEqualToString:@"com.apple.MobileSMS"])
	{
		displayIdentifier = (CFStringRef)@"com.apple.mobilephone";
}

	return original_SBSLaunchApplicationWithIdentifier(displayIdentifier, suspended);
}

__attribute__((constructor)) void Init()
{
MSHookFunction((int)SBSLaunchApplicationWithIdentifier,replaced_SBSLaunchApplicationWithIdentifier, &original_SBSLaunchApplicationWithIdentifier);
	//%init;
}


%hook UIApplication

-(BOOL)launchApplicationWithIdentifier:(id)identifier suspended:(BOOL)suspended
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"替换"
                          
                                                    message:@"com.apple.MobileSMS hook"
                          
                                                   delegate:nil
                          
                                          cancelButtonTitle:@"Thanks"
                          
                                          otherButtonTitles:nil];
    
    [alert show];
    
    [alert release];
    
	if([identifier isEqualToString:@"com.apple.MobileSMS"])
    {
        return %orig(@"com.apple.mobilephone", suspended);
    }
    else
        
        return %orig;
}

%end
#endif
*/