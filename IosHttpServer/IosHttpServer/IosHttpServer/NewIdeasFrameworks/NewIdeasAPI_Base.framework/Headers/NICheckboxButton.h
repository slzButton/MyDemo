//
//  NICheckboxButton.h
//  NewIdeasAPI_Base
//  复选按钮
//  Created by 　罗若文 on 16/5/12.
//  Copyright © 2016年 罗若文. All rights reserved.
//

#import <UIKit/UIKit.h>

///回调
typedef void (^NICheckboxButtonBlock)(id button);

///代理
@protocol NICheckboxButtonDelegate <NSObject>
@optional
////点击视图的时候触发
-(void)NICheckboxButtonDidClicked:(UIButton *)niCheckboxButton tag:(int)tag;
@end

/// Checkbox 按钮
@interface NICheckboxButton : UIButton

@property(nonatomic,copy)NICheckboxButtonBlock block;
@property (weak, nonatomic) id<NICheckboxButtonDelegate> delegate;
///checkbox/button
@property NSString * type;

#pragma mark - 要想让Server层能够通过反射机制取值,就要定义name,value.并实现gettingValue和settingValue方法
@property NSString * name;
@property NSString * value;
-(NSString *)gettingValue;
-(void)settingValue:(id)value;
#pragma mark ------------------------------------------------------------------------------------

#pragma mark - 选择框的按钮 可以做: checkbox
///checkbox
-(instancetype)initWithFrame:(CGRect)frame isCheck:(BOOL)yesOrNo text:(NSString *)text plistStyleKey:(NSString *)plistStyleKey checkedImg:(UIImage *)checkedImg unCheckImg:(UIImage *)unCheckImg;

///checkbox  delegate
-(instancetype)initWithFrame:(CGRect)frame isCheck:(BOOL)yesOrNo text:(NSString *)text plistStyleKey:(NSString *)plistStyleKey checkedImg:(UIImage *)checkedImg unCheckImg:(UIImage *)unCheckImg delegate:(id)delegate;

///checkbox  block
-(instancetype)initWithFrame:(CGRect)frame isCheck:(BOOL)yesOrNo text:(NSString *)text plistStyleKey:(NSString *)plistStyleKey checkedImg:(UIImage *)checkedImg unCheckImg:(UIImage *)unCheckImg block:(NICheckboxButtonBlock)block;

///图片和文字不变的按钮
-(instancetype)initWithFrame:(CGRect)frame isCheck:(BOOL)yesOrNo text:(NSString *)text plistStyleKey:(NSString *)plistStyleKey checkedImg:(UIImage *)checkedImg;

///设置图片位置
-(void)setImgToRight;
///设置图片位置
-(void)setImgToLeft;
///设置图片位置
-(void)setImgToTop;
///设置图片位置
-(void)setImgToBottom;
///设置选择时候字体的颜色
-(void)setCheckedTextColor:(UIColor *)color;
///设置选择时候背景的颜色
-(void)setCheckedBackgroundColor:(UIColor *)color;
///被选择的状态
@property Boolean checked;
///手动设置选中状态
-(void)setCheckValue:(BOOL)checked;
///按钮点击一次
-(void)btnClick;
///设置按钮标题
-(void)setBtnTitle:(NSString *)title;
///自动折行设置
-(void)setLineBreakMode:(NSLineBreakMode)lineBreakMode;
@end
