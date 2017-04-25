//
//  AppDelegate.m
//  WeexDemo
//
//  Created by cltx on 2017/4/20.
//  Copyright © 2017年 刘志豪. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

#import <WeexSDK/WXSDKEngine.h>//SDK开放的绝大多数接口都在此有声明。
#import <WeexSDK/WXLog.h>//控制Log输出的级别，包括Verbose、Debug、Info、Warning、Error，开发者可以按需来设置输出级别。
#import <WeexSDK/WXDebugTool.h>
#import <WeexSDK/WXAppConfiguration.h>
//#import "WXImgLoaderDefaultImpl.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    UINavigationController *nac = [[UINavigationController alloc] initWithRootViewController:[ViewController new]];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = nac;
    [self.window makeKeyAndVisible];
    
    //初始化SDK环境
    [WXSDKEngine initSDKEnvironment];
    
    
    //设置Log输出等级：调试环境默认为Debug，正式发布会自动关闭。
    [WXLog setLogLevel:WXLogLevelAll];
    
    //开启debug模式
    [WXDebugTool setDebug:YES];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
