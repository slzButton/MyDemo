//
//  NIDrviceUtil.h
//
//  Created by 　罗若文 on 16/3/23.
//  Copyright © 2016年 罗若文. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NIKeyChain.h"

////获取运行商
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
////设备震动
#import <AudioToolbox/AudioToolbox.h>

///设备常用类
@interface NIDrviceUtil : NSObject

///获得设备型号  如:(iPhone 2G (A1203))
+ (NSString *)getCurrentDeviceModel;

///获取设备的信息  [设备所有者的名称,设备的类别,本地化版本,当前运行的系统,当前系统的版本,宽X长]
+(NSArray *)deviceInfo;

///获取设备的宽度
+(float)getDeviceWidth;

///获取设备的长度
+(float)getDeviceHeight;

///获取运营商的信息
+(NSString *)getOperator;

///判断系统网络 "无网络" "2G" "3G" "4G" "WIFI" nil
+ (NSString *) getNetworkStatus;

///判断手机号码格式是否正确
+ (BOOL) isMobileNumber:(NSString *)mobileNum;

///获取uuid
+(NSString*) uuid;

/**获取设备唯一标识
 利用uuid和KeyChain*/
+(NSString *)getIMEI;

/**
 1 调用自带mail              openStr = @"mailto://xxx@qq.com"
 2 直接拨打电话phone          openStr = @"tel://1234567890"
 3 调用SMS                  openStr = @"sms://888888888"
 4 调用自带的浏览器           openStr = @"http://www.baidu.com"
 5 调用电话phone选择拨打      openStr = @"telprompt://10086"
 6 打开第三方app             openStr = @"第三方app的调用字符串://传给第三方的参数"
 return 成功/失败
 */
+(BOOL)openSoft:(NSString *)openStr;

/** 判断应用是否能够打开
 1 mail                      openStr = @"mailto://"
 2 直接拨打电话phone           openStr = @"tel://"
 3 SMS                       openStr = @"sms://"
 4 浏览器                     openStr = @"http://"
 5 电话phone选择拨打           openStr = @"telprompt://"
 6 第三方app                  openStr = @"第三方app的调用字符串://"
 return 成功/失败
 */
+(BOOL)canOpenSoft:(NSString *)canOpenStr;

///获取Info.plist的value,根据key的值
+(NSString *)getInfo_Plist:(NSString *)key;

///获取wifi的{ BSSID = "64:9:80:46:72:df"; SSID = ChinaNet1; SSIDDATA = <4368696e 614e6574 31>;}
+ (id)fetchSSIDInfo;

///获取设备的ip地址 在路由器下能获取到
+ (NSString *)deviceIPAdress;

///读取项目中的plist文件的信息
+(id)readSettingsPlist:(NSString *)key;

///读取plist文件的信息 :一级目录名,二级key
+(id)readSettingsPlist:(NSString *)path key:(NSString *)key;

///重新读取setting配置文件
+(void)reloadSettingsPlist;

///播放系统声音,声音id:1000~2000之间,参考 http://iphonedevwiki.net/index.php/AudioServices
+(void)playSystemSound:(SystemSoundID)sysID;

///震动(在需要震动的地方调用)
+(void)drviceShock;

///获取电池的相关信息 0-1
+(double)batterMonitor;

///版本比较 1.2.1  -  1.2.3.1比较这样的版本 version1>version2 返回1  version1<version2 返回-1   相等返回0
+(int)versionComparison:(NSString *)version1 version2:(NSString *)version2;
@end
