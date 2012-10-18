//
//  AppDelegate.m
//  LockIt
//
//  Created by Brian Antonelli on 10/17/12.
//  Copyright (c) 2012 Brian Antonelli. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize lockEngine = _lockEngine,
            deviceToken = _deviceToken;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#if TARGET_IPHONE_SIMULATOR
    _deviceToken = @"IOS_SIM";
#endif

    // Add registration for remote notifications
    [[UIApplication sharedApplication]
     registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/**
 * Fetch and Format Device Token and Register Important Information to Remote Server
 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {

	UIDevice *dev = [UIDevice currentDevice];
	NSString *udid = dev.uniqueIdentifier;
    
	// Prepare the Device Token for Registration (remove spaces and < >)
	_deviceToken = [[[[devToken description]
                               stringByReplacingOccurrencesOfString:@"<"withString:@""]
                              stringByReplacingOccurrencesOfString:@">" withString:@""]
                             stringByReplacingOccurrencesOfString: @" " withString: @""];
	
    [_lockEngine registerToken:_deviceToken
                      withUDID:udid
    onCompletion:^(id jsonResponse) {
        NSLog(@"Device registration response: %@", jsonResponse);
    }
    onError:^(NSError *error) {
        NSLog(@"Error registering device: %@", [error localizedDescription]);
    }];
}

/**
 * Remote Notification Received while application was open.
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
#if !TARGET_IPHONE_SIMULATOR
    NSLog(@"remote notification: %@",[userInfo description]);
	NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
    
	NSString *alert = [apsInfo objectForKey:@"alert"];
	NSLog(@"Received Push Alert: %@", alert);
    
	NSString *sound = [apsInfo objectForKey:@"sound"];
	NSLog(@"Received Push Sound: %@", sound);
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
#endif
}


@end
