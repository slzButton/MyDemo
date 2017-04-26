//
//  NIDBOperation.h
//  本地数据的操作类
//
//  Created by 　罗若文 on 16/3/24.
//  Copyright © 2016年 罗若文. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIDBBase.h"

///本地数据的操作类  Bean对象的属性尽量用NSString
@interface NIDBOperation : NIDBBase

///增改(bean对象) 增加的对象如果存在,会完全覆盖
-(int)saveData:(id)objectBean;

///增改(NSDictionary对象) tableName:表名  增加的对象如果存在,会完全覆盖
-(int)saveData:(NSDictionary *)object tableName:(NSString *)tableName;

///删除(bean对象)
-(int)deleteData:(id)objectBean;

///删除(NSDictionary对象) tableName:表名
-(int)deleteData:(NSDictionary *)object tableName:(NSString *)tableName;

///查询(bean对象) orderByColumnName: 字段名称 desc/asc
-(NSArray *)selectData:(id)objectBean orderByColumnName:(NSString *)orderByColumnName;

///查询(NSDictionary对象) tableName:表名  orderByColumnName: 字段名称 desc/asc
-(NSArray *)selectData:(NSDictionary *)object tableName:(NSString *)tableName orderByColumnName:(NSString *)orderByColumnName;

///查询表返回对应的一个对象
-(id)selectObj:(id)objectBean;
@end
