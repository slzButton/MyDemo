//
//  YJYYProvince.h
//  地区选择器Demo
//
//  Created by 远洋 on 2015/10/20.
//  Copyright © 2015年 yuayang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YJYYCity.h"

@interface YJYYProvince : NSObject

/// 省名
@property (nonatomic, copy) NSString *name;
/// 城市列表
@property (nonatomic, strong) NSArray *cities;

/// 返回索引对应的城市模型
- (YJYYCity *)cityWithIndex:(NSInteger)index;

/// 从 plist 加载省份列表
+ (NSArray *)provinces;

@end
