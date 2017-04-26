//
//  NITextField.h
//  NewIdeasBasicsProject
//
//  Created by 　罗若文 on 16/4/22.
//  Copyright © 2016年 罗若文. All rights reserved.
//

#import <UIKit/UIKit.h>

///回调
typedef void (^NITextFieldBlock)(id textField);

/// UITextField子类
@interface NITextField : UITextField

#pragma mark - 要想让Server层能够通过反射机制取值,就要定义name,value.并实现gettingValue和settingValue方法
@property NSString * name;
@property NSString * value;
-(NSString *)gettingValue;
-(void)settingValue:(id)value;
#pragma mark ------------------------------------------------------------------------------------

/// 根据Settings.plist配置文件中ControlProperties对应的plistStyleKey配置设置UITextField
-(instancetype)initWithFrame:(CGRect)frame placeholder:(NSString *)placeholder plistStyleKey:(NSString *)plistStyleKey;
/// plistStyleKey配置设置UITextField delegate
-(instancetype)initWithFrame:(CGRect)frame placeholder:(NSString *)placeholder plistStyleKey:(NSString *)plistStyleKey delegate:(id)delegate;

/// 根据Settings.plist配置文件中ControlProperties对应的plistStyleKey配置设置UITextField
-(instancetype)initWithFrame:(CGRect)frame placeholder:(NSString *)placeholder text:(NSString *)text plistStyleKey:(NSString *)plistStyleKey;
/// plistStyleKey配置设置UITextField delegate
-(instancetype)initWithFrame:(CGRect)frame placeholder:(NSString *)placeholder text:(NSString *)text plistStyleKey:(NSString *)plistStyleKey delegate:(id)delegate;

/// 根据Settings.plist配置文件中ControlProperties对应的plistStyleKey配置设置UITextField
-(instancetype)initWithFrame:(CGRect)frame placeholder:(NSString *)placeholder paddingLeft:(float)paddingLeft plistStyleKey:(NSString *)plistStyleKey;
/// plistStyleKey配置设置UITextField delegate
-(instancetype)initWithFrame:(CGRect)frame placeholder:(NSString *)placeholder paddingLeft:(float)paddingLeft plistStyleKey:(NSString *)plistStyleKey delegate:(id)delegate;

/// 根据Settings.plist配置文件中ControlProperties对应的plistStyleKey配置设置UITextField
-(instancetype)initWithFrame:(CGRect)frame placeholder:(NSString *)placeholder text:(NSString *)text paddingLeft:(float)paddingLeft plistStyleKey:(NSString *)plistStyleKey;
/// plistStyleKey配置设置UITextField delegate
-(instancetype)initWithFrame:(CGRect)frame placeholder:(NSString *)placeholder text:(NSString *)text paddingLeft:(float)paddingLeft plistStyleKey:(NSString *)plistStyleKey delegate:(id)delegate;

///设置输入框的点击 (之后是不能输入.点击出发该方法)
-(void)textFieldClick:(NITextFieldBlock)block;
@end
