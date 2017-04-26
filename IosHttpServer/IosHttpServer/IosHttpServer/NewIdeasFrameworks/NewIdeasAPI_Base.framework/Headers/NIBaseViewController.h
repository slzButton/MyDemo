//
//  NIBaseViewController.h
//  基础视图控制类,子UIViewController可以继承该类使用.
//  Created by 　罗若文 on 15/10/16.
//  Copyright © 2015年 罗若文. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NITextField.h"
#import "NITextView_custom.h"
#import "NILayoutView.h"

///回调
typedef void (^ NINavViewBlock)(id view);

///基础视图控制类,子UIViewController可以继承该类使用.
@interface NIBaseViewController : UIViewController<UITextViewDelegate,UITextFieldDelegate,NITextView_custom_Delegate>

#pragma mark - 布局
@property NILayoutView * layout;//默认有一个NILayoutView

#pragma mark - 方法
///除去导航部分中间屏幕的大小
@property CGSize centerScreen;

///(底部和顶部)的显隐
-(void)setNavToolShow:(BOOL)isShow;
///底边的显隐
-(void)setToolShow:(BOOL)isShow;
///顶部的显隐
-(void)setNavShow:(BOOL)isShow;

///设置标题(可以是字符串或视图)
-(void)setTitleView:(id)titleView;

///设置返回按钮图片或返回标题
-(void)setBackNavView:(UIImage *)backImg backText:(NSString *)backText;

///封装presentViewController方法
-(void)presentViewController:(UIViewController *)viewController animated:(BOOL)animated;

///封装pushViewController方法
-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;

///封装popViewControllerAnimated方法
-(void)popViewControllerAnimated:(BOOL)animated;

///返回(通过setBackNavView设置后,才能触发该返回方法,子类可通过覆写该方法实现监控返回按钮)
-(void)backAction;

///往前返回几页,超出范围都返回主页
-(void)backAction:(int)aboveIndex;

///添加左上角视图
-(void)addLeftNavView:(UIView *)leftNavView;
///添加左上角视图 block
-(void)addLeftNavView:(UIView *)leftNavView block:(NINavViewBlock)block;

///添加右上角视图
-(void)addRightNavView:(UIView *)rightNavView;
///添加右上角视图  block
-(void)addRightNavView:(UIView *)rightNavView  block:(NINavViewBlock)block;

///设置底部视图
-(void)addToolbarView:(NSArray *)toolbarList;

///点击layout关闭键盘
-(void)layoutClickBgDismissKeyboard;
@end
