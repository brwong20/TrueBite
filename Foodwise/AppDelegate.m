//
//  AppDelegate.m
//  Foodwise
//
//  Created by Brian Wong on 8/19/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import "AppDelegate.h"
#import "LocationManager.h"

@import Firebase;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GMSServices provideAPIKey:GOOGLE_MAPS_API_KEY];
    [GMSPlacesClient provideAPIKey:GOOGLE_PLACES_API_KEY];
    
    //Firebase
    [FIRApp configure];
    
    //FB Login
    [[FBSDKApplicationDelegate sharedInstance]application:application didFinishLaunchingWithOptions:launchOptions];
    
    //Google Login
    [GIDSignIn sharedInstance].clientID = [FIRApp defaultApp].options.clientID;
    
    //Shared cache
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024
                                                         diskCapacity:20 * 1024 * 1024
                                                            diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[LocationManager sharedLocationInstance]stopUpdatingLocation];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[LocationManager sharedLocationInstance]startUpdatingLocation];
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
//{
//        return [[GIDSignIn sharedInstance] handleURL:url
//                           sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
//                                  annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
//    return [[FBSDKApplicationDelegate sharedInstance]application:app openURL:url sourceApplication:options[UIApplicationLaunchOptionsSourceApplicationKey] annotation:options[UIApplicationLaunchOptionsAnnotationKey]];
//
//}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //Either Facebook or Google login is used...
    return ([[GIDSignIn sharedInstance] handleURL:url sourceApplication:sourceApplication annotation:annotation] ||
            [[FBSDKApplicationDelegate sharedInstance]application:application openURL:url sourceApplication:sourceApplication annotation:annotation]);
}


@end
