//
//  VpnInfo.h
//  VPNDemo
//
//  Created by Gin on 2017/1/3.
//  Copyright © 2017年 Gin. All rights reserved.
//

#import <Foundation/Foundation.h>

/// VPN 配置信息
@interface VpnInfo : NSObject

@property (nonatomic, strong) NSString *serverAddress;      ///< 服务器地址
@property (nonatomic, strong) NSString *remoteID;           ///< 远程 ID
@property (nonatomic, strong) NSString *username;           ///< 用户名
@property (nonatomic, strong) NSString *password;           ///< 密码
@property (nonatomic, strong) NSString *sharedSecret;       ///< 共享密码
@property (nonatomic, strong) NSString *preferenceTitle;    ///< vpn 配置标题

+ (instancetype)infoWithData:(id)data;

@end
