//
//  AppDelegate.m
//  WeexDemo
//
//  Created by cltx on 2017/6/14.
//  Copyright © 2017年 刘志豪. All rights reserved.
//

#import "AppDelegate.h"
#import <WeexSDK/WeexSDK.h>

#import "ViewController.h"
#import "WXEventModule.h"
#import "WXImgLoaderDefaultImpl.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [self initWeexSDK];
    
    ViewController *vc = [ViewController new];
    
    vc.url = @"http://192.168.16.242:9010/dist/app.weex.js";
    
    self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:vc];
    [self.window makeKeyAndVisible];
    
    return YES;
}

#pragma mark weex
- (void)initWeexSDK
{
    [WXAppConfiguration setAppGroup:@"AliApp"];
    [WXAppConfiguration setAppName:@"WeexDemo"];
    [WXAppConfiguration setExternalUserAgent:@"ExternalUA"];
    
    [WXSDKEngine initSDKEnvironment];
    
    [WXSDKEngine registerHandler:[WXImgLoaderDefaultImpl new] withProtocol:@protocol(WXImgLoaderProtocol)];
    
//    [WXSDKEngine registerHandler:[WXEventModule new] withProtocol:@protocol(WXEventModuleProtocol)];
    
    [WXSDKEngine registerModule:@"event" withClass:[WXEventModule class]];
    
}

@end
