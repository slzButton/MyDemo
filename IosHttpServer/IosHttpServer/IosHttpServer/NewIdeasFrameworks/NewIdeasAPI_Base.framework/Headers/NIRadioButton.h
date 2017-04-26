//
//  NIRadioButton.h
//  NewIdeasBasicsProject
//  单选按钮u
//  Created by luoruowen on 16/4/28.
//  Copyright © 2016年 罗若文. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NICheckboxButton.h"
#import "NILayoutView.h"

///回调
typedef void (^NIRadioButtonBlock)(id radioButton);

//定义代理
@protocol NIRadioButtonDelegate <NSObject>
@optional
///点击列表的时候
-(void)NIRadioButtonDidClicked:(UIView *)radioButton tag:(int)tag;
@end

/// radio 按钮
@interface NIRadioButton : UIView

@property (nonatomic,copy) NIRadioButtonBlock block;
@property (weak, nonatomic) id<NIRadioButtonDelegate> delegate;
///radio
@property NSString * type;
///选项对应的值.没有对应就直接取title值
@property (nonatomic) NSArray * btnTitleValueList;

#pragma mark - 要想让Server层能够通过反射机制取值,就要定义name,value.并实现gettingValue和settingValue方法
@property NSString * name;
@property NSString * value;
-(NSString *)gettingValue;
-(void)settingValue:(id)value;
#pragma mark ------------------------------------------------------------------------------------

///初始化函数,frame为每个按钮的radio的大小,和整个控件的位置. (checkedImg和unCheckImg可以是一个或多个)
- (instancetype)initWithFrame:(CGRect)frame titleList:(NSArray *)titleList defaultSelected:(int)defaultSelected plistStyleKey:(NSString *)plistStyleKey checkedImg:(id)checkedImg unCheckImg:(id)unCheckImg LayoutStyle:(NILayoutStyle)LayoutStyle;

///初始化函数2,frame为每个按钮的radio的大小,和整个控件的位置. delegate (checkedImg和unCheckImg可以是一个或多个)
- (instancetype)initWithFrame:(CGRect)frame titleList:(NSArray *)titleList defaultSelected:(int)defaultSelected plistStyleKey:(NSString *)plistStyleKey checkedImg:(id)checkedImg unCheckImg:(id)unCheckImg LayoutStyle:(NILayoutStyle)LayoutStyle delegate:(id)delegate;

///初始化函数3,frame为每个按钮的radio的大小,和整个控件的位置. block (checkedImg和unCheckImg可以是一个或多个)
- (instancetype)initWithFrame:(CGRect)frame titleList:(NSArray *)titleList defaultSelected:(int)defaultSelected plistStyleKey:(NSString *)plistStyleKey checkedImg:(id)checkedImg unCheckImg:(id)unCheckImg LayoutStyle:(NILayoutStyle)LayoutStyle block:(NIRadioButtonBlock)block;

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

///指定按钮点击一次
-(void)btnClick:(int)index;

///设置按钮的显示标题
-(void)setBtnTitles:(NSArray *)titleList;

///自动折行设置
-(void)setLineBreakMode:(NSLineBreakMode)lineBreakMode;
@end
