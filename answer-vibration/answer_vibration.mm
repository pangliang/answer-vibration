//
//  liangwei_hooktweaktest.mm
//  liangwei-hooktweaktest
//
//  Created by liangwei on 12-11-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

// CaptainHook by Ryan Petrich
// see https://github.com/rpetrich/CaptainHook/

#import <Foundation/Foundation.h>
#import "CaptainHook/CaptainHook.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioServices.h>

extern "C" int CTCallGetStatus(CTCall *call); // 获得电话状态　拨出电话时为３，有呼入电话时为４，挂断电话时为５

// Objective-C runtime hooking using CaptainHook:
//   1. declare class using CHDeclareClass()
//   2. load class using CHLoadClass() or CHLoadLateClass() in CHConstructor
//   3. hook method using CHOptimizedMethod()
//   4. register hook using CHHook() in CHConstructor
//   5. (optionally) call old method using CHSuper()


@interface answer_vibration : NSObject

@end

@implementation answer_vibration

-(id)init
{
	if ((self = [super init]))
	{
	}
    
    return self;
}

@end


static int timesOfVibrate = 0;

static void completionCallback(SystemSoundID systemSoundID, void *myself)
{
    NSLog(@"========  completionCallback");
    //AudioServicesDisposeSystemSoundID(systemSoundID);
    
    timesOfVibrate--;
    if(timesOfVibrate>0)
    {
        [NSThread sleepForTimeInterval:0.3];
        NSLog(@"========  play again %d====",timesOfVibrate);
        //AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate,NULL,NULL,completionCallback,NULL);
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }else{
        AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
    }
}

static void callStatusChangeCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    
    NSLog(@"========name:%@",name);
    
    NSString *processName = [[NSProcessInfo processInfo] processName];
    NSLog(@"========  processName:%@",processName);
    if(![processName isEqualToString:@"SpringBoard"])
    {
        return;
    }
    
    if(NULL == userInfo)
        return;
        
	CTCall *ctCall= (CTCall *)[(NSDictionary *)userInfo objectForKey:@"kCTCall"];
    if(NULL == ctCall)
        return;
    int status=CTCallGetStatus(ctCall);
    NSLog(@"========  status:%d",status);
    
    Boolean switchcell=FALSE;
    CFPreferencesAppSynchronize(CFSTR("com.sharedream.answer-vibration"));
    if(1 == status)
    {
        timesOfVibrate=[(id)CFPreferencesCopyAppValue(CFSTR("answer-vibration-times"),CFSTR("com.sharedream.answer-vibration")) integerValue];
        
        switchcell=CFPreferencesGetAppBooleanValue(CFSTR("answer-vibration-switch"),CFSTR("com.sharedream.answer-vibration"),NULL);
    }
    else if (5 == status)
    {
        timesOfVibrate=[(id)CFPreferencesCopyAppValue(CFSTR("hangup-vibration-times"),CFSTR("com.sharedream.answer-vibration")) integerValue];
        switchcell=CFPreferencesGetAppBooleanValue(CFSTR("hangup-vibration-switch"),CFSTR("com.sharedream.answer-vibration"),NULL);
    }
    NSLog(@"======== switchcell:%d,timesOfVibrate:%d",switchcell,timesOfVibrate);

    if(switchcell)
    {
        AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate,NULL,NULL,completionCallback,NULL);
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    
}

static void preferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    NSString *processName = [[NSProcessInfo processInfo] processName];
    NSLog(@"========  processName:%@",processName);
    if(![processName isEqualToString:@"SpringBoard"])
    {
        return;
    }
    Boolean switchcell=FALSE;
    CFPreferencesAppSynchronize(CFSTR("com.sharedream.answer-vibration"));
    if([(id)name isEqualToString:@"com.sharedream.answer-vibration.preferencesChanged.hangup"])
    {
        timesOfVibrate=[(id)CFPreferencesCopyAppValue(CFSTR("hangup-vibration-times"),CFSTR("com.sharedream.answer-vibration")) integerValue];
        switchcell=CFPreferencesGetAppBooleanValue(CFSTR("hangup-vibration-switch"),CFSTR("com.sharedream.answer-vibration"),NULL);
    }
    else
    {
        timesOfVibrate=[(id)CFPreferencesCopyAppValue(CFSTR("answer-vibration-times"),CFSTR("com.sharedream.answer-vibration")) integerValue];
        switchcell=CFPreferencesGetAppBooleanValue(CFSTR("answer-vibration-switch"),CFSTR("com.sharedream.answer-vibration"),NULL);
    }
    NSLog(@"======== switchcell:%d,timesOfVibrate:%d",switchcell,timesOfVibrate);
    
    if(switchcell)
    {
        AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate,NULL,NULL,completionCallback,NULL);
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

CHConstructor // code block that runs immediately upon load
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// listen for local notification (not required; for example only)
    CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, callStatusChangeCallback, CFSTR("kCTCallStatusChangeNotification"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, preferencesChangedCallback, CFSTR("com.sharedream.answer-vibration.preferencesChanged.answer"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, preferencesChangedCallback, CFSTR("com.sharedream.answer-vibration.preferencesChanged.hangup"), NULL, CFNotificationSuspensionBehaviorCoalesce);
		
	[pool drain];
}
