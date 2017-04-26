//
//  NISqlLiteConfigure.h
//  
//  数据库的版本控制 配置类 每次数据库的升级操作,修改该类
//  Created by 　罗若文 on 16/3/27.
//  Copyright © 2016年 罗若文. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NISqlLiteConfigure : NSObject

///返回数据库名
+(NSString *)getDbName;

///返回要更新到的最大版本号
+(int)getMaxVersion;

///根据版本号返回该版本要执行的sql
+(NSArray *)returnSql:(int)dbVersion;

@end
