//
//  HTTPServer.h
//  TextTransfer
//
//  Created by Matt Gallagher on 2009/07/13.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <UIKit/UIKit.h>

///http文件存放路径的根目录
#define NIHttpFileDir ([NSString stringWithFormat:@"%@",[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,NSUserDomainMask,YES)objectAtIndex:0]])

typedef enum
{
	SERVER_STATE_IDLE,
	SERVER_STATE_STARTING,
	SERVER_STATE_RUNNING,
	SERVER_STATE_STOPPING
} HTTPServerState;

@class HTTPResponseHandler;

@interface NIHTTPServer : NSObject
{
	NSError *lastError;
	NSFileHandle *listeningHandle;
	CFSocketRef socket;
	HTTPServerState state;
	CFMutableDictionaryRef incomingRequests;
	NSMutableSet *responseHandlers;
}

@property (nonatomic, readonly, retain) NSError *lastError;
@property (readonly, assign) HTTPServerState state;

#pragma mark - 第一步
///实例化httpserver   (1)
+ (NIHTTPServer *)sharedNIHTTPServer;

#pragma mark - 第二步
///在没有Settings.plist HTTPServerConfigure配置情况下手动配置端口和action路径
///在star之前设置   (2)
+(void)setPort:(int)port withAction:(NSArray *)actionList;

#pragma mark - 第三步
///启动服务   (3)
- (void)start;

#pragma mark - 第四步(可选)
///设置Response之前执行的方法  (4)
+(void)setMethodForHTTPServer:(SEL)method methodObject:(id)object;

#pragma mark - 第五步①
///设置对应的action路径下得json字符串
+(void)setActionResponseJson:(NSString *)jsonData action:(NSString *)actionPath;

#pragma mark - 第五步②
///设置对应的action路径下得html数据 (5)
+(void)setActionResponseHtml:(NSString *)html action:(NSString *)actionPath;

#pragma mark - 第五步③
///设置对应的action路径下得数据  (5)
+(void)setActionResponseData:(NSData *)responseData action:(NSString *)actionPath;

#pragma mark - 第五步④
///设置对应的action路径下的数据(实际本地根目录,服务器相对目录要以/开头)
+(void)setActionResponseWithFolder:(NSString *)rootFolder RelativeDirectory:(NSString *)relativeDirectory;

#pragma mark - 第六步
///停止服务 (6)
- (void)stop;

- (void)closeHandler:(HTTPResponseHandler *)aHandler;

@end

extern NSString * const HTTPServerNotificationStateChanged;
