//
//  YJYYCity.m
//  地区选择器Demo
//
//  Created by 远洋 on 2015/10/20.
//  Copyright © 2015年 yuayang. All rights reserved.
//

#import "YJYYCity.h"
#import "YJYYDistrict.h"

@implementation YJYYCity

- (YJYYDistrict *)districtWithIndex:(NSInteger)index {
    if (index >= 0 && index < self.districts.count) {
        return self.districts[index];
    }
    return nil;
}

+ (instancetype)cityWithDict:(NSDictionary *)dict {
    id obj = [[self alloc] init];
    
    [obj setValue:dict[@"name"] forKey:@"name"];
    [obj setValue:dict[@"postalcode"] forKey:@"postalcode"];
    [obj setValue:[YJYYDistrict districtsWithArray:dict[@"sub"]] forKey:@"districts"];
    
    return obj;
}

+ (NSArray *)citiesWithArray:(NSArray *)array {
    
    NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:array.count];
    
    for (NSDictionary *dict in array) {
        [arrayM addObject:[YJYYCity cityWithDict:dict]];
    }
    
    return arrayM.copy;
}

- (NSString *)description {
    return [self dictionaryWithValuesForKeys:@[@"name", @"postalcode", @"districts"]].description;
}
@end
