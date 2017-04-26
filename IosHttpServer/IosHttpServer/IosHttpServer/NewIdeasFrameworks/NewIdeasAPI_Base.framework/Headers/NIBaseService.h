//
//  NIBaseService.h
//  Service的基础类
//  将处理控制层和数据层间的逻辑  通过反射机制将有标记name的控件值收集到本类变量中
//  NIButton,NILabel,NITextField,NITextView,NITextView_custom
//  Created by 　罗若文 on 16/4/24.
//  Copyright © 2016年 罗若文. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIDBOperation.h"       //数据库操作类,增删改查
#import "NIHttpHelper.h"        //http请求
#import "NIBaseViewController.h"

/**
 Service的基础类
 将处理控制层和数据层间的逻辑  通过反射机制将有标记name的控件值收集到本类变量中

 #pragma mark - 要想让Server层能够通过反射机制取值,就要在控件中定义name,value.并实现gettingValue和settingValue方法
 @property NSString * name;      //用来标记server中对应的变量名
 @property NSString * value;     //记录该控件的值.如果初始化的时候不能赋予,也可以手动控制该值的变化
 -(NSString *)gettingValue;      //自己实现该控件将可以获取到得值应该要做什么处理
 -(void)settingValue:(id)value;  //自己实现设置该控件的值应该要有哪些操作
 #pragma mark ------------------------------------------------------------------------------------
 */
@interface NIBaseService : NSObject

///反射获取到得值
@property NSMutableDictionary * objDic;

///设置加载框是否要显示在最上层,yes显示在最上层,no就显示在当前视图
-(void)setHudShowTopLayer:(NSString *)promptStr isTopLayer:(BOOL)yesNo;
///开始显示提示
-(void)showHud:(BOOL)animated;
///关闭提示
-(void)hideHud:(BOOL)animated afterDelay:(NSTimeInterval)delay;

///初始化函数,要反射获取值,请用该方法初始化
- (instancetype)init:(id)object;
- (instancetype)init:(id)object isCheckTopLayer:(BOOL)yesNo;
///初始化函数,对象,参数
- (instancetype)init:(id)object parameter:(NSDictionary *)parameter;
- (instancetype)init:(id)object parameter:(NSDictionary *)parameter isCheckTopLayer:(BOOL)yesNo;

///设置控件对应name的值
-(void)setValueWihtName:(NSString *)name value:(id)value;


@end

