
//
//  ViewController.m
//  MQTTChat
//
//  Created by Christoph Krey on 12.07.15.
//  Copyright (c) 2015-2016 Owntracks. All rights reserved.
//

#import "ViewController.h"
#import "ChatCell.h"
#import <CommonCrypto/CommonHMAC.h>
#import <MJExtension.h>
#import "MessageHandle.h"

@interface ViewController ()


@property (strong, nonatomic) NSDictionary *mqttSettings;
@property (strong, nonatomic) NSString *rootTopic;
@property (strong, nonatomic) NSString *accessKey;
@property (strong, nonatomic) NSString *secretKey;
@property (strong, nonatomic) NSString *groupId;
@property (strong, nonatomic) NSString *clientId;
@property (nonatomic) NSInteger *qos;

@property (strong, nonatomic) NSMutableArray *chat;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UITextField *message;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *connect;
@property (weak, nonatomic) IBOutlet UIButton *disconnect;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MessageHandle messageHandleConnectAndWaitTimeout:0];

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
//    NSLog(@"MQTT的返回信息 === %@",data.mj_JSONString);
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
            
//            [[AFNetworkReachabilityManager sharedManager]stopMonitoring];
//            [MessageHandle messageHandleSubscribeTopic:[NSString stringWithFormat:@"server/inner/app/%@/reply",User.userDeviceId]];
            
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)clear:(id)sender {
    [self.chat removeAllObjects];
    [self.tableView reloadData];
}
- (IBAction)connect:(id)sender {
    /*
     * MQTTClient: connect to same broker again
     */
    
//    [self.manager connectToLast];
}

- (IBAction)disconnect:(id)sender {
    /*
     * MQTTClient: gracefully disconnect
     */
//    [self.manager disconnect];
}

- (IBAction)send:(id)sender {
    /*
     * MQTTClient: send data to broker
     */
    
//    [self.manager sendData:[self.message.text dataUsingEncoding:NSUTF8StringEncoding]
//                     topic:[NSString stringWithFormat:@"%@/%@",
//                            self.rootTopic,
//                            @"IOS"]//此处设置多级子topic
//                       qos:self.qos
//                    retain:FALSE];
    [MessageHandle messageHandlePublishMessageAtMostOnce:@{@"ttt":@"ttt"} onTopic:@"server/inner/app/E5266B95-4666-43DA-8E42-32635F9ED649/reply"];
}

/*
 * MQTTSessionManagerDelegate
 */
- (void)handleMessage:(NSData *)data onTopic:(NSString *)topic retained:(BOOL)retained {
    /*
     * MQTTClient: process received message
     */
    
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [self.chat insertObject:[NSString stringWithFormat:@"RecvMsg from Topic: %@\nBody: %@", topic, dataString] atIndex:0];
    [self.tableView reloadData];
}

/*
 * UITableViewDelegate
 */
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"line"];
    cell.textView.text = self.chat[indexPath.row];
    return cell;
}

/*
 * UITableViewDataSource
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chat.count;
}

@end
