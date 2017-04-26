//
//  NIHttpHelper.h
//
//  Created by oyf on 16/3/28.
//  Copyright © 2016年 罗若文. All rights reserved.
//

#import <Foundation/Foundation.h>

///http请求代理
@protocol NIhttpDelegate <NSObject>
///请求成功
-(void)success:(id)jsonData tag:(NSString *)tag;
///请求失败
-(void)fail:(NSString *)jsonData tag:(NSString *)tag;
@end

/*
 错误描述：
 
 App Transport Security has blocked a cleartext HTTP (http://) resource load since it is insecure. Temporary exceptions can be configured via your app‘s Info.plist file.
 在iOS9 beta中，苹果将原http协议改成了https协议，使用 TLS1.2 SSL加密请求数据。
 
 解决方法：
 
 在info.plist 加入key
 <key>NSAppTransportSecurity</key>
 <dict>
 <key>NSAllowsArbitraryLoads</key>
 <true/>
 </dict>
 
 */

///http帮助类
@interface NIHttpHelper : NSObject

@property id<NIhttpDelegate> delegate;

///网络请求超时时间（秒）
-(void)setTimeoutInterval:(int)timeout;

///设置设置缓存协议
-(void)setCachePolicy:(NSURLRequestCachePolicy)cachePolicy;

///特殊字符转义
-(NSString *)transcoding:(NSString * )str;

#pragma mark - http常用请求

///get同步http请求
-(NSString *)httpGetSync:(NSString *)getUrl;

///post同步http请求
-(NSString *)httpPostSync:(NSString *)postUrl httpBody:(NSDictionary *)dict;

///post异步http请求(代理)
-(void)httpPostAsync:(NSString *)postUrl httpBody:(NSDictionary *)dict tag:(NSString *)tag;

///post异步http请求(采用block)
-(void)httpPostAsync:(NSString *)postUrl httpBody:(NSDictionary *)dict success:(void (^)(id data))success fail:(void(^)(NSString * msg))fail;

///get异步http请求(代理)
-(void)httpGetAsync:(NSString *)getUrl tag:(NSString *)tag;

///get异步http请求(采用block)
-(void)httpGetAsync:(NSString *)getUrl success:(void (^)(id data))success fail:(void(^)(NSString * msg))fail;

@end
