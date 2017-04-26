//
//  NILabel.h
//  NewIdeasBasicsProject
//
//  Created by 　罗若文 on 16/4/22.
//  Copyright © 2016年 罗若文. All rights reserved.
//

#import <UIKit/UIKit.h>

///回调
typedef void (^NILabelBlock)(id label);

///UILabel子类
@interface NILabel : UILabel

#pragma mark - 要想让Server层能够通过反射机制取值,就要定义name,value.并实现gettingValue和settingValue方法
@property NSString * name;
@property NSString * value;
-(NSString *)gettingValue;
-(void)settingValue:(id)value;
#pragma mark ------------------------------------------------------------------------------------

/// 根据Settings.plist配置文件中ControlProperties对应的plistStyleKey配置设置UILabel (能自动伸展,显示成一行)
-(instancetype)initWithFrame:(CGRect)frame text:(NSString *)text autoWidth:(BOOL)autoWidth plistStyleKey:(NSString *)plistStyleKey;

/// 根据Settings.plist配置文件中ControlProperties对应的plistStyleKey配置设置UILabel
-(instancetype)initWithFrame:(CGRect)frame text:(NSString *)text plistStyleKey:(NSString *)plistStyleKey;

///设置label的点击 (之后是不能输入.点击出发该方法)
-(void)labelClick:(NILabelBlock)block;
@end
