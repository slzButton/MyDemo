//
//  NewIdeasAPI_Base.h
//  NewIdeasAPI_Base
//
//  Created by 　罗若文 on 16/5/12.
//  Copyright © 2016年 罗若文. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NIString.h"            //字符串常用类
#import "NIDate.h"              //时间常用类
#import "NIDrviceUtil.h"        //设置信息的常用类
#import "NIPromptUtil.h"        //对MBProgressHUD提示方法的一种封装
#import "NIJsonUtil.h"          //json和object对象的转换:objWithJsonString,jsonStringWithObj
#import "NIFileUtil.h"          //文件操作类(下载,判断文件存在,删除文件)
#import "NIObjectUtil.h"        //对象和列表的转换类,例如可将bean对象转成NSDictionary
#import "NIDes3Util.h"          //des加密/解密
#import "NIReadClass.h"         //读取类的方法名,打印在控制台
#import "NIKeyChain.h"          //keychain操作
#import "NIImage.h"             //图片操作
#import "NIColor.h"             //颜色操作
#import "ControlProperties.h"   //Settings.plist中ControlProperties配置类
#import "NISound.h"             //声音类

#pragma mark - 视图类导入
#import "NILabel.h"             //label控件
#import "NITextView.h"          //TextView控件
#import "NITextField.h"         //TextField控件
#import "NILayoutView.h"        //垂直和水平布局视图
#import "NIScrollView.h"        //滚动的视图
#import "NICollectionView.h"    //UICollectionView的封装
#import "NIButton.h"            //UIButton子类(普通按钮点击block实现,选择按钮的实现)
#import "NIRadioButton.h"       //单选按钮控件
#import "NICheckboxButton.h"    //复选框按钮控件
#import "NIWebView.h"           //webview视图控件
#import "NIContactsView.h"      //联系人视图,可以选择电话号码
#import "NISendMessageView.h"   //发送短信的视图,可以设置标题和内容以及电话号码
#import "NISendMailView.h"      //邮件发送
#import "NIFileViewer.h"        //简易的文件查看器
#import "NITextView_custom.h"   //带有placeholder属性的TextView控件
#import "NISegmentedControl.h"  //选择按钮控件
#import "NIPhotoSelectionView.h"//图片选择视图

#pragma mark - 基础类
#import "NIDBBase.h"            //数据库类
#import "NIDBOperation.h"       //数据库操作类,增删改查
#import "NISqlLiteConfigure.h"  //数据库的基本信息
#import "NIHttpHelper.h"        //http请求
#import "NIBaseViewController.h"//基础的视图控制类,可作为ViewController的父类使用
#import "NIBaseService.h"       //基础的server类,作为其他server类的父类

#pragma mark - 公共的代理
///公共的代理
@protocol NIPublicDelegate <NSObject>
@optional
-(void)NIPublicTrigger:(id)obj tag:(int)tag;
@end

#pragma mark - define
///获取设备屏幕的长
#define NIVIEW_HEIGHT [UIScreen mainScreen].bounds.size.height
///获取设备屏幕的宽
#define NIVIEW_WIDTH [UIScreen mainScreen].bounds.size.width

///RGB颜色(红,绿,蓝,透明度1)
#define NIRGB(r, g, b, a)[NIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:(a)*1.f]
///RGB颜色 16进制(16进制颜色,透明度1)
#define NIRGB_HEX(hexcolor,a)[NIColor hexStringToColor:(hexcolor) alpha:a*1.f]

///服务器的ip和端口
#define NIBASE_SERVER_URL [(NSArray *)[NIDrviceUtil readSettingsPlist:@"NI_BASE_SERVER_URL"] objectAtIndex:0]  //现场
#define NIBASE_SERVER_URL_LIST [NIDrviceUtil readSettingsPlist:@"NI_BASE_SERVER_URL"]  //Settings.plist中url列表


//! Project version number for NewIdeasAPI_Base.
FOUNDATION_EXPORT double NewIdeasAPI_BaseVersionNumber;

//! Project version string for NewIdeasAPI_Base.
FOUNDATION_EXPORT const unsigned char NewIdeasAPI_BaseVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <NewIdeasAPI_Base/PublicHeader.h>


