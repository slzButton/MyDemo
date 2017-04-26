//
//  NewIdeasAPI_LocHttpServer.h
//  NewIdeasAPI_LocHttpServer
//
//  Created by 　罗若文 on 16/6/23.
//  Copyright © 2016年 罗若文. All rights reserved.
//

#import <UIKit/UIKit.h>
//需要依赖的包 CFNetwork.framework 和 CoreGraphics.framework

//端口和action配置在Settings.plist中 如果没有配置Settings.plist 端口默认是8080端口  action默认是"/"存放index.do
//如果使用了没有配置的action会统一放到temporary.do
//如果有
/* Settings.plist中得配置
<dict>
    <key>HTTPServerConfigure</key>
    <dict>
        <key>HTTP_SERVER_PORT</key>
        <integer>8080</integer>
        <key>HTTP_SERVER_ACTION</key>
        <array>
            <string>/</string>
            <string>/login.do</string>
            <string>/user/*</string>
        </array>
    </dict>
 </dict>
 */

#import "NIHTTPServer.h"

FOUNDATION_EXPORT double NewIdeasAPI_LocHttpServerVersionNumber;

FOUNDATION_EXPORT const unsigned char NewIdeasAPI_LocHttpServerVersionString[];

