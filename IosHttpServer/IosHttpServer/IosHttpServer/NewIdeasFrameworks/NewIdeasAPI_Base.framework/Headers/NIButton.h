//
//  NIButton.h
//  普通按钮
//  Created by 　罗若文 on 16/4/2.
//  Copyright © 2016年 罗若文. All rights reserved.
//

#import <UIKit/UIKit.h>

///回调
typedef void (^NIButtonBlock)(id button);

///代理
@protocol NIButtonDelegate <NSObject>
@optional
////点击视图的时候触发
-(void)NIButtonDidClicked:(UIButton *)niButton tag:(int)tag;
@end

///UIButton子类
@interface NIButton : UIButton

@property(nonatomic,copy)NIButtonBlock block;
@property (weak, nonatomic) id<NIButtonDelegate> delegate;
///checkbox/button   
@property NSString * type;

#pragma mark - 要想让Server层能够通过反射机制取值,就要定义name,value.并实现gettingValue和settingValue方法
@property NSString * name;
@property NSString * value;
-(NSString *)gettingValue;
-(void)settingValue:(id)value;
#pragma mark ------------------------------------------------------------------------------------

#pragma mark - 普通按钮
/// 根据Settings.plist配置文件中ControlProperties对应的plistStyleKey配置设置UIButton
-(instancetype)initWithFrame:(CGRect)frame text:(NSString *)text plistStyleKey:(NSString *)plistStyleKey;

///UIButton,按钮点击block
-(instancetype)initWithFrame:(CGRect)frame text:(NSString *)text plistStyleKey:(NSString *)plistStyleKey block:(NIButtonBlock)block;

///UIButton 点击用代理的方式
-(instancetype)initWithFrame:(CGRect)frame text:(NSString *)text plistStyleKey:(NSString *)plistStyleKey delegate:(id)delegate;

///高亮的时候的属性
-(void)setHighlightedStyleWithText:(NSString *)text textColor:(UIColor *)textColor bgColor:(UIColor *)backgroundColor;

///按钮点击一次
-(void)btnClick;

///自动折行设置 
-(void)setLineBreakMode:(NSLineBreakMode)lineBreakMode;
@end
