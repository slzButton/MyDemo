//
//  NIPromptUtil.h
//  提示常用类
//  Created by 　罗若文 on 16/1/15.
//  Copyright © 2016年 newland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

///对MBProgressHUD提示方法的一种封装
@interface NIPromptUtil : NSObject

///显示在showUIView图层
+(void)showLong:(UIView *)showUIView msg:(NSString *)msg;
///显示提示
+(void)showLong:(UIView *)showUIView msg:(NSString *)msg afterDelay:(NSTimeInterval)delay;
///显示在最上层
+(void)showLong:(NSString *)msg;

///加载HUD提示
-(void)setHudWithShowView:(UIView *)showUIView promptStr:(NSString *)promptStr;
///显示提示
-(void)showHud:(BOOL)animated;
///关闭提示
-(void)hideHud:(BOOL)animated afterDelay:(NSTimeInterval)delay;
@end
