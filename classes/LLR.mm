//
//  Task_.mm
//  Task+
//
//  Created by John Corbett on 8/20/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//
//  MobileSubstrate, libsubstrate.dylib, and substrate.h are
//  created and copyrighted by Jay Freeman a.k.a saurik and 
//  are protected by various means of open source licensing.
//
//  Additional defines courtesy Lance Fetters a.k.a ashikase
//



#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#include <substrate.h>

#define HOOK(class, name, type, args...) \
static IMP __ ## class ## $ ## name; \
type _ ## class ## $ ## name (id self, SEL _cmd, ## args)

#define CALL_ORIG(class, name, args...) \
__ ## class ## $ ## name(self, _cmd, ## args)

#define MS(selector, class, name) \
MSHookMessageEx( class , selector, \
(IMP) _ ## class ## $ ## name , (IMP *) &__ ## class ## $ ## name )

#pragma mark -
#pragma mark Hooked orientation lock messages

#define kInvalid -1

Class $SB_OrientationLockManager;

HOOK($SB_OrientationLockManager, lock, void, int lockPosition) {
 //	2
	 CALL_ORIG($SB_OrientationLockManager, lock, kInvalid);
 }
 

HOOK($SB_OrientationLockManager, setLockOverride, void, int override, int orientation) {
 //	3
	 if (objc_msgSend(self, @selector(isLocked))) 
		 CALL_ORIG($SB_OrientationLockManager, setLockOverride, kInvalid, kInvalid);
	 else 
		 CALL_ORIG($SB_OrientationLockManager, setLockOverride, override, orientation);
 } 

HOOK($SB_OrientationLockManager, deviceOrientationFromInterfaceOrientation, int, int inferface) {
	return (int) CALL_ORIG($SB_OrientationLockManager, deviceOrientationFromInterfaceOrientation, kInvalid);
}

HOOK($SB_NowPlayingBar, _displayOrientationStatus, void, BOOL status) {}

#pragma mark -
#pragma mark dylib initialization and initial hooks

extern "C" void hookInit() {	
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];	
	
	$SB_OrientationLockManager = objc_getClass("SBOrientationLockManager");
	 
	 MS(@selector(lock:), $SB_OrientationLockManager, lock);
	 MS(@selector(setLockOverride:orientation:), $SB_OrientationLockManager, setLockOverride); 
	 MS(@selector(_deviceOrientationFromInterfaceOrientation:), $SB_OrientationLockManager, deviceOrientationFromInterfaceOrientation);
	
	Class $SB_NowPlayingBar = objc_getClass("SBNowPlayingBar");
	
	MS(@selector(_displayOrientationStatus:), $SB_NowPlayingBar, _displayOrientationStatus);
	
	[pool release];
}
