//
//  CFDaemonManger.h
//  CFHookInterface
//
//  Created by gyanping on 13-9-24.
//
//

#import <Foundation/Foundation.h>
@interface CFDaemonManger : NSObject


+(void)setisHookCallIn:(BOOL)isHook;


+(void)setisHookHomeKeys:(BOOL)isHook;

+(void)setisHookCallOut:(BOOL)isHook;


+(void)setBindDialIcon:(BOOL)isbd;

+(BOOL)shareisHookHomeKeys;
+(BOOL)shareisHookCallIn;
+(BOOL)shareisHookHomeKeys;
+(BOOL)shareisHookCallOut;
@end
