//
//  PushMessageHandle.m
//  VehicleWorld
//
//  Created by cltx on 2016/11/28.
//  Copyright © 2016年 cltx. All rights reserved.
//

#import "MessageHandle.h"
#import <MJExtension.h>

//NSString *const kMessageHandlePostNotification = @"kPushMessageHandlePostNotification";  //发送通知

static MessageHandle *messgaeHandle = nil;

@interface MessageHandle ()<MQTTSessionDelegate>

@property(nonatomic,strong)MQTTSession *mqttSession;
@property(nonatomic,assign)BOOL notFirstConnection;

@end


@implementation MessageHandle
+(instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (messgaeHandle == nil) {
            messgaeHandle = [[self alloc]init];
            messgaeHandle.notFirstConnection = NO;
        }
    });
    return messgaeHandle;
}
-(MQTTSession *)mqttSession{
    if (_mqttSession == nil) {
        NSString *clientId = [NSString stringWithFormat:@"iOS_%@",@"ksdefhsbgbgjkerbgjkrg"];
        
//        MQTTSSLSecurityPolicy *securityPolicy = [MQTTSSLSecurityPolicy policyWithPinningMode:MQTTSSLPinningModeCertificate];
//        
//        securityPolicy.pinnedCertificates = @[Resouce.pinnedCertificates];
//        
//        securityPolicy.allowInvalidCertificates = YES;
        
        MQTTSSLSecurityPolicyTransport *transport = [[MQTTSSLSecurityPolicyTransport alloc] init];//初始化对象
        transport.tls = YES;//ssl上层协议,ssl升级版
        
        transport.host = @"demo-xk-mqtt.auto-link.com.cn";//设置MQTT服务器的地址
        
        transport.port = 8883;//设置MQTT服务器的端口（默认是1883，当然，你也可以和你的后台好基友协商~）
        
//        transport.securityPolicy = securityPolicy;
        
        _mqttSession = [[MQTTSession alloc] initWithClientId:clientId];//初始化MQTTSession对象
        _mqttSession.transport = transport;//给mySession对象设置基本信息
        _mqttSession.delegate = self;
        _mqttSession.willFlag = YES;
        _mqttSession.willTopic = @"server/will";
        _mqttSession.willQoS = MQTTQosLevelExactlyOnce;
        _mqttSession.willMsg = [@"IOS_WILL "stringByAppendingString:clientId].mj_JSONData;
        
    }
    return _mqttSession;
}
+(void)messageHandleConnectAndWaitTimeout:(NSTimeInterval)timeout{
    [self messageHandleConnectAndWaitTimeout:timeout connectionSuccess:nil];
}
+(void)messageHandleConnectAndWaitTimeout:(NSTimeInterval)timeout connectionSuccess:(MessageHandlerConnectionSuccessBlock)connectionSuccess{
    [[[self shareInstance]mqttSession]connectAndWaitTimeout:timeout];
    [[self shareInstance]mqttSession].connectionHandler = ^(MQTTSessionEvent event) {
        if (event == MQTTSessionEventConnected) {
            if (connectionSuccess) {
                if (!messgaeHandle.notFirstConnection) {
                    messgaeHandle.notFirstConnection = YES;
                }
                connectionSuccess(messgaeHandle.notFirstConnection);
            }
        }
    };
}
+(void)messageHandleSubscribeTopic:(NSString *)topic{
    NSLog(@"%@",topic);
    [[[self shareInstance]mqttSession]subscribeToTopic:topic atLevel:MQTTQosLevelAtLeastOnce];
}
+(void)messageHandleUnsubscribeTopic:(NSString *)topic{
    [[[self shareInstance]mqttSession]unsubscribeTopic:topic];
}

+(void)messageHandlePublishMessageAtMostOnce:(NSDictionary *)messgae onTopic:(NSString *)topic{
    [[[self shareInstance]mqttSession]publishDataAtMostOnce:messgae.mj_JSONData onTopic:topic];
}
+(void)messageHandleGetMessageWithMessageBlock:(MessageHandlerBlock)messageHandlerBlock{
    [[[self shareInstance]mqttSession] setMessageHandler:^(NSData *data, NSString *topic) {
#ifdef TEXT
        [[[UIAlertView alloc]initWithTitle:nil message:data.mj_JSONString delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil] show];
#endif
        messageHandlerBlock(data.mj_JSONString,topic);
    }];
}
#pragma mark - MQTTSessionDelegate
/** gets called when a new message was received
 @param session the MQTTSession reporting the new message
 @param data the data received, might be zero length
 @param topic the topic the data was published to
 @param qos the qos of the message
 @param retained indicates if the data retransmitted from server storage
 @param mid the Message Identifier of the message if qos = 1 or 2, zero otherwise
 */
- (void)newMessage:(MQTTSession *)session
              data:(NSData *)data
           onTopic:(NSString *)topic
               qos:(MQTTQosLevel)qos
          retained:(BOOL)retained
               mid:(unsigned int)mid{
    NSLog(@"MQTT的返回信息 === %@",data.mj_JSONString);
}

/** gets called when a connection is established, closed or a problem occurred
 @param session the MQTTSession reporting the event
 @param eventCode the code of the event
 @param error an optional additional error object with additional information
 */
- (void)handleEvent:(MQTTSession *)session event:(MQTTSessionEvent)eventCode error:(NSError *)error{
    NSLog(@"MQTTSessionEvent === %ld",(long)eventCode);
    if (error) {
        NSLog(@"%@",error);
    }
//    MQTTSessionEventConnected,
//    MQTTSessionEventConnectionRefused,
//    MQTTSessionEventConnectionClosed,
//    MQTTSessionEventConnectionError,
//    MQTTSessionEventProtocolError,
//    MQTTSessionEventConnectionClosedByBroker
    
    switch (eventCode) {
        case MQTTSessionEventConnected:{
        }
            break;
        case MQTTSessionEventConnectionRefused:
        case MQTTSessionEventConnectionClosed:
        case MQTTSessionEventConnectionError:
        case MQTTSessionEventProtocolError:
        case MQTTSessionEventConnectionClosedByBroker:{
            
        }
            break;
    }
}

//+(void)pushMessageHandlePostMessageWith:(NSDictionary *)message{
//    [[NSNotificationCenter defaultCenter]postNotificationOnMainThreadWithName:kMessageHandlePostNotification userInfo:message];
//}
//+(void)pushMessageHandleDidReceivePushMessageWith:(NSDictionary *)message success:(PushMessageHandleBlock)success failure:(PushMessageHandleBlock)failure{
////    @try {
////        User.userBadgeValue ++;
////        NSDictionary *userInfo = [message[kContent] mj_JSONObject];
////        NSString *taskid = [NSString stringWithString:[message[kContent] mj_JSONObject][@"taskid"]];
////        if (taskid && ![taskid isEqualToString:@""]) {
////            /**
////             *  推送的描述
////             */
////            NSString *desc =userInfo[@"desc"];
////            /**
////             *  创建推送对象
////             */
////            PushMessage *pushMessage = [PushMessage mj_objectWithKeyValues:userInfo];
////            pushMessage.pushID = taskid;
////            pushMessage.submitStatu = STATU_UNSUBMIT;
////            pushMessage.stime = [[NSDate date] formattedTime];
////            pushMessage.readStatu = UNREAD;
////            pushMessage.userName = User.userName;
////            pushMessage.type = 3;
////            pushMessage.contents = desc;
////            /**
////             *  用户名
////             */
////            NSString *username = User.userName;
////            /**
////             *  NSUD中存取值的key
////             */
////            NSArray<NSString *> *UDKeyArray = @[kZKlockKey,kFindcarKey,kEngineKey,kAircondKey];
////            NSArray<NSString *> *sendToJsValueArray = @[kZKlockValue,kFindcarValue,kEngineValue,kAircondValue];
////            [UDKeyArray enumerateObjectsUsingBlock:^(NSString *const obj, NSUInteger idx, BOOL * _Nonnull stop) {
////                NSString *UDKey = [username stringByAppendingString:obj];
////                NSString *UDTaskID = [[NSUserDefaults standardUserDefaults]objectForKey:UDKey];
////                NSString *sendToJsValue = sendToJsValueArray[idx];
////                if ([taskid isEqualToString:UDTaskID]) {
////                    [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:UDKey];
////                    pushMessage.title = sendToJsValue;
////                }
////            }];
////            
////            //                NSString *zklockUDKey = [username stringByAppendingString:zklockKey];
////            //                NSString *findcarUDKey = [username stringByAppendingString:findcarKey];
////            //                NSString *engineUDKey = [username stringByAppendingString:engineKey];
////            //                NSString *aircondUDKey = [username stringByAppendingString:aircondKey];
////            //                /**
////            //                 *  NSUD中根据key取到value
////            //                 */
////            //                NSString *zklockTaskID = [[NSUserDefaults standardUserDefaults]objectForKey:zklockUDKey];
////            //                NSString *findcarTaskID = [[NSUserDefaults standardUserDefaults]objectForKey:findcarUDKey];
////            //                NSString *engineTaskID = [[NSUserDefaults standardUserDefaults]objectForKey:engineUDKey];
////            //                NSString *aircondTaskID = [[NSUserDefaults standardUserDefaults]objectForKey:aircondUDKey];
////            //                /**
////            //                 *  对比值
////            //                 */
////            //                if ([taskid isEqualToString:zklockTaskID]) {
////            //                    [self mainViewControllerCallToJSWithApiCodeValue:CODE_DEFULT_ERROR context:[@"中控:" stringByAppendingString:desc] status:ERROR_STATUS];
////            //                    [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:zklockUDKey];
////            //                    pushMessage.title = @"中控";
////            //                }else if ([taskid isEqualToString:findcarTaskID]){
////            //                    [self mainViewControllerCallToJSWithApiCodeValue:CODE_DEFULT_ERROR context:[@"寻车:" stringByAppendingString:desc] status:ERROR_STATUS];
////            //                    [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:findcarUDKey];
////            //                    pushMessage.title = @"寻车";
////            //                }else if ([taskid isEqualToString:engineTaskID]){
////            //                    [self mainViewControllerCallToJSWithApiCodeValue:CODE_DEFULT_ERROR context:[@"发动机:" stringByAppendingString:desc] status:ERROR_STATUS];
////            //                    [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:engineUDKey];
////            //                    pushMessage.title = @"发动机";
////            //
////            //                }else if ([taskid isEqualToString:aircondTaskID]){
////            //                    [self mainViewControllerCallToJSWithApiCodeValue:CODE_DEFULT_ERROR context:[@"空调:" stringByAppendingString:desc] status:ERROR_STATUS];
////            //                    [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:aircondUDKey];
////            //                    pushMessage.title = @"空调";
////            //                }
////            
////            success(desc);
////            
//////            [PushMessage insert:pushMessage resBlock:^(BOOL res) {
//////                if (res) {
//////                    if (success) {
//////                        success(desc);
//////                    }
//////                }else{
//////                    if (failure) {
//////                        failure(Resouce.pushMessageLoadFailContext);
//////                    }
//////                }
//////            }];
////        }
////    } @catch (NSException *exception) {
////        if (failure) {
////            failure(Resouce.pushMessageLoadFailContext);
////        }
////    } @finally {
////        NSLog(@"收到后台推送消息");
////    }
//}
//
//+(void)pushMessageHandleSelectPushMessageWithWhere:(NSString *)where groupBy:(NSString *)groupBy orderBy:(NSString *)orderBy limit:(NSString *)limit selectResultsBlock:(void(^)(NSArray *selectResults))selectResultsBlock{
////    [PushMessage selectWhere:where groupBy:groupBy orderBy:orderBy limit:limit selectResultsBlock:selectResultsBlock];
//}
@end
