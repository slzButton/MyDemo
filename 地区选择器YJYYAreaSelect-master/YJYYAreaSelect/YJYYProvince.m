//
//  YJYYProvince.m
//  地区选择器Demo
//
//  Created by 远洋 on 2015/10/20.
//  Copyright © 2015年 yuayang. All rights reserved.
//

#import "YJYYProvince.h"
#import "YJYYCity.h"

@implementation YJYYProvince

- (YJYYCity *)cityWithIndex:(NSInteger)index {
    if (index >= 0 && index < self.cities.count) {
        return self.cities[index];
    }
    return nil;
}

+ (instancetype)provinceWithDict:(NSDictionary *)dict {
    id obj = [[self alloc] init];
    
    [obj setValue:dict[@"name"] forKey:@"name"];
    [obj setValue:[YJYYCity citiesWithArray:dict[@"sub"]] forKey:@"cities"];
    
    return obj;
}

+ (NSArray *)provinces {
    
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"address" withExtension:@"plist"]];
    NSArray *list = dict[@"Provinces"];
    
    NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:list.count];
    
    for (NSDictionary *dict in list) {
        [arrayM addObject:[YJYYProvince provinceWithDict:dict]];
    }
    
    return arrayM.copy;
}

- (NSString *)description {
    return [self dictionaryWithValuesForKeys:@[@"name", @"cities"]].description;
}
@end
