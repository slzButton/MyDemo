//
//  NIJsonUtil.h
//
//  Created by 　罗若文 on 16/3/24.
//  Copyright © 2016年 罗若文. All rights reserved.
//

#import <Foundation/Foundation.h>

///Json常用转换类
@interface NIJsonUtil : NSObject

///解析json转为object
+ (NSObject *)objWithJsonString:(NSString *)jsonString ;

///转换为json
+(NSString *)jsonStringWithObj:(NSObject *)params;

@end
