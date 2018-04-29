//
//  VpnInfo.m
//  VPNDemo
//
//  Created by Gin on 2017/1/3.
//  Copyright © 2017年 Gin. All rights reserved.
//

#import "VpnInfo.h"

@implementation VpnInfo

+ (instancetype)infoWithData:(id)data {
    
    VpnInfo *vpnInfo = [[VpnInfo alloc] init];
    if ([data isKindOfClass:[NSDictionary class]]) {
        data[@"serverAddress"] ? vpnInfo.serverAddress = data[@"serverAddress"] : 0;
        data[@"remoteID"] ? vpnInfo.remoteID = data[@"remoteID"] : 0;
        data[@"username"] ? vpnInfo.username = data[@"username"] : 0;
        data[@"password"] ? vpnInfo.password = data[@"password"] : 0;
        data[@"sharedSecret"] ? vpnInfo.sharedSecret = data[@"sharedSecret"] : 0;
        data[@"preferenceTitle"] ? vpnInfo.preferenceTitle = data[@"preferenceTitle"] : 0;
    } else if ([data isKindOfClass:[self class]]) {
        vpnInfo = data;
    }
    return vpnInfo;
}

@end
