//
//  YJYYDistrict.m
//  地区选择器Demo
//
//  Created by 远洋 on 2015/10/20.
//  Copyright © 2015年 yuayang. All rights reserved.
//

#import "YJYYDistrict.h"

@implementation YJYYDistrict
//字典转模型
+ (instancetype)districtWithName:(NSString *)name {
    id obj = [[self alloc] init];
    
    [obj setValue:name forKey:@"name"];
    
    return obj;
}

+ (NSArray *)districtsWithArray:(NSArray *)array {
    
    NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:array.count];
    
    for (NSString *name in array) {
        [arrayM addObject:[YJYYDistrict districtWithName:name]];
    }
    
    return arrayM.copy;
}

- (NSString *)description {
    return [self dictionaryWithValuesForKeys:@[@"name"]].description;
}
@end
