//
//  ViewController.m
//  VPNDemo
//
//  Created by Gin on 2017/1/3.
//  Copyright © 2017年 Gin. All rights reserved.
//

#import "ViewController.h"
#import "VpnConnector.h"

@interface ViewController () <VpnConnectorDelegate>

/// VPN 连接工具
@property (nonatomic, strong) VpnConnector *connector;

/// VPN 连接信息
@property (nonatomic, strong) VpnInfo *vpnInfo;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _connector = [VpnConnector vpnConnector];
    _connector.delegate = (id)self;
}

#pragma mark - Lazy Load

- (VpnInfo *)vpnInfo {
    
    if (_vpnInfo == nil) {
#warning Complete vpn info
        VpnInfo *vpnInfo = [[VpnInfo alloc] init];
        vpnInfo.serverAddress = @"";
        vpnInfo.remoteID = @"";
        vpnInfo.username = @"";
        vpnInfo.password = @"";
        vpnInfo.sharedSecret = @"";
        _vpnInfo = vpnInfo;
    }
    return _vpnInfo;
}

#pragma mark - Button Action
- (IBAction)buttonClick:(id)sender {
    
    if (self.vpnInfo.serverAddress.length < 1) {
        // Alert
        UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:@"VPN 信息不完整" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertCtrl addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertCtrl animated:YES completion:nil];
        return ;
    }
    
    [_connector checkVPNPreferenceSuccess:^(BOOL isInstalled) {
        if (isInstalled) {
            // 判断当前连接状态是否为正在连接，或者已连接上
            VPNStatus status = [_connector getCurrentStatus];
            if (status == VPNStatusConnecting || status == VPNStatusConnected) {
                // 断开 VPN 连接
                [_connector stopVPNConnectSuccess:^{
                    
                }];
            } else {
                // 开始之前刷新一下信息
                [_connector modifyVPNPreferenceWithData:_vpnInfo success:^{
                    [_connector startVPNConnectSuccess:^{
                        
                    }];
                }];
            }
        } else {
            // 安装 VPN 配置
            [_connector createVPNPreferenceWithData:_vpnInfo success:^{
                // 安装完成之后，开始连接 VPN
                [_connector startVPNConnectSuccess:^{
                    
                }];
            }];
        }
    }];
}

#pragma mark - VpnConnectorDelegate

- (void)vpnConnectionDidRecieveError:(VpnConnectorError)error {

    switch (error) {
        case VpnConnectorErrorNone:
            break;
        case VpnConnectorErrorLoadPrefrence:
            break;
        case VpnConnectorErrorSavePrefrence:
            break;
        case VpnConnectorErrorRemovePrefrence:
            break;
        case VpnConnectorErrorStartVPNConnect:
            break;
        default:
            break;
    }
}

#pragma mark - Notification

- (void)vpnStatusDidChange:(VPNStatus)status {
    
    switch (status) {
        case VPNStatusInvalid:
            break;
        case VPNStatusConnected:
            break;
        case VPNStatusDisconnected:
            break;
        case VPNStatusConnecting:
            break;
        case VPNStatusDisconnecting:
            break;
        default:
            break;
    }
}

@end
