//
//  NIDate.h
//  NewIdeasBasicsProject
//
//  Created by 　罗若文 on 16/4/22.
//  Copyright © 2016年 罗若文. All rights reserved.
//

#import <Foundation/Foundation.h>

///时间常用类
@interface NIDate : NSDate

///对应格式的字符串转换成时间
+(NSDate *)getDateForString:(NSString *) senddate dateFormatStr:(NSString *) dateFormatStr;

///两时间相差多少秒 开始时间-结束时间
+(long)getDateInterval:(NSDate *)beginDate andEndDay:(NSDate *)endDate;

///时间转成对应格式的字符串
+(NSString *)dateFormat:(NSDate *)date dateFormatStr:(NSString *) dateFormatStr;

///时间转成对应格式的字符串  并添加或减少多少秒
+(NSString *)dateFormat:(NSDate *)date dateFormatStr:(NSString *)dateFormatStr addOrReduceTime:(NSTimeInterval) interval;

///将GMT时间转换成当前时区时间
+(NSDate *)getLocaleDate:(NSDate *)date;
@end
