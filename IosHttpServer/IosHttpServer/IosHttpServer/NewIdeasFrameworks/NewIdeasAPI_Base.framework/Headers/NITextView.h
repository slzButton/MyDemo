//
//  NITextView.h
//  NewIdeasBasicsProject
//
//  Created by 　罗若文 on 16/4/22.
//  Copyright © 2016年 罗若文. All rights reserved.
//

#import <UIKit/UIKit.h>

/// UITextView子类
@interface NITextView : UITextView

#pragma mark - 要想让Server层能够通过反射机制取值,就要定义name,value.并实现gettingValue和settingValue方法
@property NSString * name;
@property NSString * value;
-(NSString *)gettingValue;
-(void)settingValue:(id)value;
#pragma mark ------------------------------------------------------------------------------------

/// 根据Settings.plist配置文件中ControlProperties对应的plistStyleKey配置设置UITextView
-(instancetype)initWithFrame:(CGRect)frame text:(NSString *)text plistStyleKey:(NSString *)plistStyleKey;
/// plistStyleKey配置设置UITextView delegate
-(instancetype)initWithFrame:(CGRect)frame text:(NSString *)text plistStyleKey:(NSString *)plistStyleKey delegate:(id)delegate;

@end
