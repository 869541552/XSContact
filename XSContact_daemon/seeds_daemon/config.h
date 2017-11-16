//
//  config.h
//  iTest_daemon
//
//  Created by Guoyanping on 13-5-9.
//
//
#define ALL_APP_INSTALLATION_PLIST_PATH @"/var/mobile/Library/Caches/" //app 安装路径
#define ALL_APP_INSTALLATION_PLIST_NAME @"com.apple.mobile.installation.plist"

#define APP_BUNDLE_IDENTIFIER @"com.cf.hft"

#ifdef DEBUG

#define NSLog(...) NSLog(__VA_ARGS__)

#define DLog(fmt, ...) NSLog((@"%s----Line:%d " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#else

#define NSLog(...) {}
#define DLog(...)

#endif

#define CF_DAIL_APP_PATH              @"/Applications/dial.app/"

#define CF_DAIL_APP_DATABASE_PATH    @"/usr/local/bin/"// @"/Applications/dial.app/database/"

#define IPHONE_SYS_CALL_HISTORY_PATH  @"/private/var/wireless/Library/CallHistory/call_history.db"

#define systemViersion [[[UIDevice currentDevice] systemVersion] floatValue]