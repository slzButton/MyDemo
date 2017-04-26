//
//  NIDBBase.h
//  数据库基础类
//  Created by 　罗若文 on 15/9/10.
//  Copyright (c) 2015年 罗若文. All rights reserved.
//

#import <Foundation/Foundation.h>

///数据库基础类
@interface NIDBBase : NSObject

///记录被改变的行数
@property (nonatomic) int affectedRows;
///记录最后插入行的id
@property (nonatomic) long lastInsertedRowID;
///存储刚执行的数据结果   第0行是字段名
@property (nonatomic, strong) NSMutableArray * arrayData;

/**
 * 查询sql语句
 * return  NSArray<NSMutableDictionary>
 */
-(NSArray *)querySql:(NSString *)sqlStr;
///执行sql语句
-(void)executeSql:(NSString *)sqlStr;
///获取数据库路径
- (NSString*)getFilePath;
@end
