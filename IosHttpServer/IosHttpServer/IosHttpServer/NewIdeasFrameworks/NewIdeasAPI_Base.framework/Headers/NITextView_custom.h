//
//  NITextView_custom.h
//  自定义UITextView对象,增加了placeholder属性
//
//  Created by 　罗若文 on 16/4/23.
//  Copyright © 2016年 罗若文. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NITextView.h"

#pragma mark - 定义代理
///定义布局代理
@protocol NITextView_custom_Delegate <NSObject>
@optional
- (void)NITextViewShouldBeginEditing:(UIView *)textView;
- (void)NITextViewShouldEndEditing:(UIView *)textView;
- (void)NITextViewDidChange:(UITextView *)textView;
@end

/// UITextView封装,加上placeholder属性
@interface NITextView_custom : UIView

///NITextView对象
@property NITextView * textView;

#pragma mark - 要想让Server层能够通过反射机制取值,就要定义name,value.并实现gettingValue和settingValue方法
@property NSString * name;
@property NSString * value;
-(NSString *)gettingValue;
-(void)settingValue:(id)value;
#pragma mark ------------------------------------------------------------------------------------

///代理
@property (weak, nonatomic) id<NITextView_custom_Delegate> delegate;

- (BOOL)resignFirstResponder;

///初始化自定义输入框
- (instancetype)initWithFrame:(CGRect)frame placeholder:(NSString *)placeholder text:(NSString *)text plistStyleKey:(NSString *)plistStyleKey;
///初始化自定义输入框 delegate
- (instancetype)initWithFrame:(CGRect)frame placeholder:(NSString *)placeholder text:(NSString *)text plistStyleKey:(NSString *)plistStyleKey delegate:(id)delegate;

@end
