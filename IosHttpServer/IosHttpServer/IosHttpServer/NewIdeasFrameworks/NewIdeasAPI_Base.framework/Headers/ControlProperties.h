//
//  ControlProperties.h
//  控件的通用属性,和settingPlist对应
//  Created by 　罗若文 on 16/3/31.
//  Copyright © 2016年 罗若文. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ControlProperties : NSObject

#pragma mark - 参数
@property NSInteger textAlignment;      //靠边0,1,2   默认0左边
@property UIColor * backgroundColor;    //背景颜色      默认透明
@property NSInteger numberOfLines;      //文字有几行显示   默认1
@property UIColor * textColor;          //文本颜色 默认黑色
@property UIColor * placeholderColor;   //placeholder的颜色,有就是用,没有就用系统默认的

@property BOOL upBorder;                //上边界       默认NO
@property BOOL downBorder;              //下边界       默认NO
@property BOOL leftBorder;              //左边界       默认NO
@property BOOL rightBorder;             //右边界       默认NO

@property UIFont * font;                //字体
@property NSString * fontName;          //字体名字      默认nil
@property float fontSize;               //字体大小 默认17

@property CALayer *layer;               //属性
@property float borderWidth;            //边框宽度      默认0
@property UIColor * borderColor;        //边框颜色      默认透明
@property float cornerRadius;           //拐角弧度      默认0
@property BOOL masksToBounds;

#pragma mark - 方法
-(instancetype)init:(NSString *)plistStyleKey;
@end
