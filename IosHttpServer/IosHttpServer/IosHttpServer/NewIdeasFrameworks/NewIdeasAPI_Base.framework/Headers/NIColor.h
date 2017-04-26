//
//  NIColor.h
//  NewIdeasBasicsProject
//
//  Created by 　罗若文 on 16/4/22.
//  Copyright © 2016年 罗若文. All rights reserved.
//

#import <UIKit/UIKit.h>

///rgb及透明度 颜色结构体
struct RGBColor {
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
};
typedef struct RGBColor RGBColor;

CG_INLINE RGBColor
RGBColorMake(CGFloat red,CGFloat green,CGFloat blue,CGFloat alpha)
{
    RGBColor color;
    color.red=red;
    color.green=green;
    color.blue=blue;
    color.alpha=alpha;
    return color;
}

///颜色常用类
@interface NIColor : UIColor

///hexStringToColor:16进制颜色值 或 (r,g,b)
+(UIColor *) hexStringToColor:(NSString *)hexColor;

///hexStringToColor:16进制颜色值 或 (r,g,b) alpha:透明度
+(UIColor *) hexStringToColor:(NSString *)hexColor alpha:(float)alpha;

///根据红绿蓝获取颜色
+(UIColor *)rgbToColor:(int)red green:(int)green blue:(int)blue;

///根据红绿蓝获取颜色
+(UIColor *)rgbToColor:(int)red green:(int)green blue:(int)blue alpha:(float)alpha;

@end
