//
//  YJYYCity.h
//  地区选择器Demo
//
//  Created by 远洋 on 2015/10/20.
//  Copyright © 2015年 yuayang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YJYYDistrict.h"

@interface YJYYCity : NSObject
/// 城市名
@property (nonatomic, copy) NSString *name;
/// 邮政编码
@property (nonatomic, copy) NSString * postalcode;
/// 地区列表
@property (nonatomic, strong) NSArray *districts;

/// 返回索引对应的地区模型
- (YJYYDistrict *)districtWithIndex:(NSInteger)index;

+ (NSArray *)citiesWithArray:(NSArray *)array;
@end
