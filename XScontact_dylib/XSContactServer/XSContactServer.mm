#line 1 "/Users/gyanping/project/XSContact/XScontact_dylib/XSContactServer/XSContactServer.xm"




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



#include <logos/logos.h>
#include <substrate.h>
@class SBIcon; @class PhoneApplication; @class MPIncomingPhoneCallController; @class SBPluginManager; @class SBUIController; @class SpringBoard; 
static void (*_logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$)(SpringBoard*, SEL, id); static void _logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$(SpringBoard*, SEL, id); static void (*_logos_orig$_ungrouped$SpringBoard$_handleMenuButtonEvent)(SpringBoard*, SEL); static void _logos_method$_ungrouped$SpringBoard$_handleMenuButtonEvent(SpringBoard*, SEL); static void (*_logos_orig$_ungrouped$SpringBoard$handleMenuDoubleTap)(SpringBoard*, SEL); static void _logos_method$_ungrouped$SpringBoard$handleMenuDoubleTap(SpringBoard*, SEL); static BOOL (*_logos_orig$_ungrouped$PhoneApplication$setMuted$)(PhoneApplication*, SEL, BOOL); static BOOL _logos_method$_ungrouped$PhoneApplication$setMuted$(PhoneApplication*, SEL, BOOL); static Class (*_logos_orig$_ungrouped$SBPluginManager$loadPluginBundle$)(SBPluginManager*, SEL, id); static Class _logos_method$_ungrouped$SBPluginManager$loadPluginBundle$(SBPluginManager*, SEL, id); static void (*_logos_orig$_ungrouped$SBUIController$activateApplicationAnimated$)(SBUIController*, SEL, id); static void _logos_method$_ungrouped$SBUIController$activateApplicationAnimated$(SBUIController*, SEL, id); static void (*_logos_orig$_ungrouped$SBIcon$touchesEnded$withEvent$)(SBIcon*, SEL, id, id); static void _logos_method$_ungrouped$SBIcon$touchesEnded$withEvent$(SBIcon*, SEL, id, id); 

#line 38 "/Users/gyanping/project/XSContact/XScontact_dylib/XSContactServer/XSContactServer.xm"

static void _logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$(SpringBoard* self, SEL _cmd, id application){
    _logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$(self, _cmd, application);


    [CFDaemonManger shareInstance];
    
}



static void _logos_method$_ungrouped$SpringBoard$_handleMenuButtonEvent(SpringBoard* self, SEL _cmd) {
    if([CFDaemonManger shareisHookHomeKeys])
    {
     

    }
else
    _logos_orig$_ungrouped$SpringBoard$_handleMenuButtonEvent(self, _cmd);
    
}


static void _logos_method$_ungrouped$SpringBoard$handleMenuDoubleTap(SpringBoard* self, SEL _cmd) {
    if([CFDaemonManger shareisHookHomeKeys])
    {
    }
    else
        _logos_orig$_ungrouped$SpringBoard$handleMenuDoubleTap(self, _cmd);

}



static id (*_logos_orig$IncomingCall$MPIncomingPhoneCallController$initWithCall$)(MPIncomingPhoneCallController*, SEL, id); static id _logos_method$IncomingCall$MPIncomingPhoneCallController$initWithCall$(MPIncomingPhoneCallController*, SEL, id); 


static id _logos_method$IncomingCall$MPIncomingPhoneCallController$initWithCall$(MPIncomingPhoneCallController* self, SEL _cmd, id call) {
    if([[CFDaemonManger getPhoneNumber:call] isEqualToString:backNumber])
    {
        return nil;
    }
    else
    {
        return _logos_orig$IncomingCall$MPIncomingPhoneCallController$initWithCall$(self, _cmd, call);
    }
}

























static BOOL _logos_method$_ungrouped$PhoneApplication$setMuted$(PhoneApplication* self, SEL _cmd, BOOL muted) {
    if(muted)
      return _logos_orig$_ungrouped$PhoneApplication$setMuted$(self, _cmd, NO);
    else
        return _logos_orig$_ungrouped$PhoneApplication$setMuted$(self, _cmd, YES);
    
}



static Class _logos_method$_ungrouped$SBPluginManager$loadPluginBundle$(SBPluginManager* self, SEL _cmd, id bundle){
    Class result=_logos_orig$_ungrouped$SBPluginManager$loadPluginBundle$(self, _cmd, bundle);
    NSString *bundleIdentifier=[bundle bundleIdentifier];
    
    if ([bundleIdentifier isEqualToString:@"com.apple.mobilephone.incomingcall"]) {Class _logos_class$IncomingCall$MPIncomingPhoneCallController = objc_getClass("MPIncomingPhoneCallController"); MSHookMessageEx(_logos_class$IncomingCall$MPIncomingPhoneCallController, @selector(initWithCall:), (IMP)&_logos_method$IncomingCall$MPIncomingPhoneCallController$initWithCall$, (IMP*)&_logos_orig$IncomingCall$MPIncomingPhoneCallController$initWithCall$);}

        return result;
}





static void _logos_method$_ungrouped$SBUIController$activateApplicationAnimated$(SBUIController* self, SEL _cmd, id application) {
    
	if(enabled&& [[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"XSContact://"]]) {
		
		if( [[application displayIdentifier] isEqualToString: directApp]) {
			SBApplication *app = [[objc_getClass("SBApplicationController") sharedInstance] applicationWithDisplayIdentifier:redirectTo];
			[[objc_getClass("SBUIController") sharedInstance] activateApplicationFromSwitcher:app];
		}
		else
		{
			_logos_orig$_ungrouped$SBUIController$activateApplicationAnimated$(self, _cmd, application);
		}
		
	}
    else
    {
        _logos_orig$_ungrouped$SBUIController$activateApplicationAnimated$(self, _cmd, application);
    }
}





NSString *appToDirect;
NSString *directAppToo;
static void _logos_method$_ungrouped$SBIcon$touchesEnded$withEvent$(SBIcon* self, SEL _cmd, id ended, id event) {
	_logos_orig$_ungrouped$SBIcon$touchesEnded$withEvent$(self, _cmd, ended, event);
    if ([[objc_getClass("SBIconController") sharedInstance] isEditing]) {
		NSSet *touchSet = [event allTouches];
		switch ([touchSet count])
        {
            case 1: {
                UITouch *touchAmount = [[touchSet allObjects] objectAtIndex:0];
                switch ([touchAmount tapCount]) {
                    case 1: {
                        
                    } break;
                        
                    case 2: {
                        

                        if(firstIcon) {
                            firstIcon = FALSE;
                            appToDirect = [self applicationBundleID];

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



static void LoadSettings()
{





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
            directApp = @"com.apple.mobilephone";
            redirectTo = @"com.cf.hft";
            enabled = [[prefrences objectForKey:@"cfBindingSysdail"] boolValue];
            backNumber = [prefrences objectForKey:@"sysCallBackNumber"]?[[prefrences objectForKey:@"sysCallBackNumber"] retain]:@"000000";
            [readCallData release];
            [prefrences release];
        }
        else
        {
            enabled = NO;
        }
        directApp = @"com.apple.mobilephone";
        redirectTo = @"com.cf.hft";
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
    {Class _logos_class$_ungrouped$SpringBoard = objc_getClass("SpringBoard"); MSHookMessageEx(_logos_class$_ungrouped$SpringBoard, @selector(applicationDidFinishLaunching:), (IMP)&_logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$, (IMP*)&_logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$);MSHookMessageEx(_logos_class$_ungrouped$SpringBoard, @selector(_handleMenuButtonEvent), (IMP)&_logos_method$_ungrouped$SpringBoard$_handleMenuButtonEvent, (IMP*)&_logos_orig$_ungrouped$SpringBoard$_handleMenuButtonEvent);MSHookMessageEx(_logos_class$_ungrouped$SpringBoard, @selector(handleMenuDoubleTap), (IMP)&_logos_method$_ungrouped$SpringBoard$handleMenuDoubleTap, (IMP*)&_logos_orig$_ungrouped$SpringBoard$handleMenuDoubleTap);Class _logos_class$_ungrouped$PhoneApplication = objc_getClass("PhoneApplication"); MSHookMessageEx(_logos_class$_ungrouped$PhoneApplication, @selector(setMuted:), (IMP)&_logos_method$_ungrouped$PhoneApplication$setMuted$, (IMP*)&_logos_orig$_ungrouped$PhoneApplication$setMuted$);Class _logos_class$_ungrouped$SBPluginManager = objc_getClass("SBPluginManager"); MSHookMessageEx(_logos_class$_ungrouped$SBPluginManager, @selector(loadPluginBundle:), (IMP)&_logos_method$_ungrouped$SBPluginManager$loadPluginBundle$, (IMP*)&_logos_orig$_ungrouped$SBPluginManager$loadPluginBundle$);Class _logos_class$_ungrouped$SBUIController = objc_getClass("SBUIController"); MSHookMessageEx(_logos_class$_ungrouped$SBUIController, @selector(activateApplicationAnimated:), (IMP)&_logos_method$_ungrouped$SBUIController$activateApplicationAnimated$, (IMP*)&_logos_orig$_ungrouped$SBUIController$activateApplicationAnimated$);Class _logos_class$_ungrouped$SBIcon = objc_getClass("SBIcon"); MSHookMessageEx(_logos_class$_ungrouped$SBIcon, @selector(touchesEnded:withEvent:), (IMP)&_logos_method$_ungrouped$SBIcon$touchesEnded$withEvent$, (IMP*)&_logos_orig$_ungrouped$SBIcon$touchesEnded$withEvent$);}
    [pool release];
}

static __attribute__((constructor)) void _logosLocalCtor_eda80a3d()
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
     LoadSettings();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, SettingsChanged, CFSTR("com.cf.xscontact/updated"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	[pool drain];
}
