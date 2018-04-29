//
//  YJYYDistrict.h
//  地区选择器Demo
//
//  Created by 远洋 on 2015/10/20.
//  Copyright © 2015年 yuayang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YJYYDistrict : NSObject
/// 地区名
@property (nonatomic, copy) NSString *name;

+ (NSArray *)districtsWithArray:(NSArray *)array;
@end
