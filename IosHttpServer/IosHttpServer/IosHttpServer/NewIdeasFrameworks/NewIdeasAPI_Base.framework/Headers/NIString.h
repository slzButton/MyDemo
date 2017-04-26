//
//  NIString.h
//    
//  Created by 　罗若文 on 16/4/22.
//  Copyright © 2016年 罗若文. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

///字符常用类
@interface NIString : NSString

///判断字符串是否为空
+(BOOL) isEmpty:(NSString *)str;

///去掉字符串的前后空格
+ (NSString *) trim:(NSString *)str;

///计算字符串的字节
+(int)strConvertToInt:(NSString*)strtemp;

///获取UIFont大小字符串在界面中所占的大小
+(CGSize)getStringCGSize:(NSString *)string uiFont:(UIFont *)uiFont;

///判断是否可转为整形
+(BOOL)isPureInt:(NSString *)str;

///判断是否可转为浮点形
+(BOOL)isPureFloat:(NSString *)str;

///正则表达式匹配(判断是否符合格式)
+(BOOL)regexToBool:(NSString *)string regex:(NSString *)regex;

///正则表达式匹配(查找字符串,会返回第一个匹配结果的位置)
+(NSString *)regexToString:(NSString *)string regex:(NSString *)regex;

///正则表达式匹配(会返回第一个匹配结果的位置)
+(NSArray *)regexToList:(NSString *)string regex:(NSString *)regex;

///汉字转拼音
+(NSString *)ChineseToPinyin:(NSString *)Chinese;
@end
