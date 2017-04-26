//
//  NIObjectUtil.h
//
//  Created by 　罗若文 on 16/3/28.
//  Copyright © 2016年 罗若文. All rights reserved.
//

#import <Foundation/Foundation.h>

///对象常用类
@interface NIObjectUtil : NSObject

///检查对象是否存在该属性
+(BOOL)selAttributeIsExist:(Class)objClass attributeName:(NSString *)attributeName;

///获取对象属性值
+(id)selAttributeValue:(id)object attributeName:(NSString *)attributeName;

///查看class类中变量的类型:NSInteger,int,double,bool,BOOL,float,对象
+(NSString *)getAttributeType:(Class)objClass attributeName:(NSString *)attributeName;

///根据对象转换成key-value 采用runtime查找的
+(NSDictionary *)objectPropertys:(id)objectBean;

///将<NSMutableDictionary>类型转成新的<Bean>
+(id)objectPropertysForList:(Class)beanClass dic:(NSDictionary*)dic;

@end
