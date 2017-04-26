//
//  AppDelegate.m
//  IosHttpServer
//
//  Created by 　罗若文 on 16/6/24.
//  Copyright © 2016年 罗若文. All rights reserved.
//

#import "AppDelegate.h"
#import <NewIdeasAPI_LocHttpServer/NewIdeasAPI_LocHttpServer.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    //[NIHTTPServer setPort:8080 withAction:@[@"/",@"/1/1.do"]];//如果没有配置Settings.plist可以用此方法配置端口和action路径
    [[NIHTTPServer sharedNIHTTPServer] start];//开启http服务
    return YES;
}

#pragma mark - 程序意外暂行
- (void)applicationWillTerminate:(UIApplication *)application {
    [[NIHTTPServer sharedNIHTTPServer] stop];
}

@end
