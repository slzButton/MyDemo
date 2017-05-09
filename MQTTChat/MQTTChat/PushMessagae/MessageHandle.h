//
//  PushMessageHandle.h
//  VehicleWorld
//
//  Created by cltx on 2016/11/28.
//  Copyright © 2016年 cltx. All rights reserved.
//


#import <MQTTClient/MQTTClient.h> // MQTT库


/**
 @brief  消息信息回调
 */
typedef void (^MessageHandlerBlock)(NSString* message, NSString* topic);
/**
 @brief  MQTT连接成功
 */
typedef void (^MessageHandlerConnectionSuccessBlock)(BOOL notFirstConnection);
 
@interface MessageHandle : NSObject

@property(nonatomic,strong,readonly)MQTTSession *mqttSession;

/**
 @brief  获取单例
 */
+(instancetype)shareInstance;


/**
 @brief  开始连接并设置链接超时时间
 */
+(void)messageHandleConnectAndWaitTimeout:(NSTimeInterval)timeout;
/**
 @brief  开始连接并设置链接超时时间和连接成功回调
 */
+(void)messageHandleConnectAndWaitTimeout:(NSTimeInterval)timeout connectionSuccess:(MessageHandlerConnectionSuccessBlock)connectionSuccess;
/**
 @brief  订阅
 */
+(void)messageHandleSubscribeTopic:(NSString *)topic;
/**
 @brief  取消订阅
 */
+(void)messageHandleUnsubscribeTopic:(NSString *)topic;

/**
 @brief  发消息
 */
+(void)messageHandlePublishMessageAtMostOnce:(NSDictionary *)messgae onTopic:(NSString *)topic;
/**
 @brief  接收订阅消息
 */
+(void)messageHandleGetMessageWithMessageBlock:(MessageHandlerBlock)messageHandlerBlock;
@end
