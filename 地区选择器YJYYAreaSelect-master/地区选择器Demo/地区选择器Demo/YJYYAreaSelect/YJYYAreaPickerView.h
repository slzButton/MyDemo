//
//  YJYYAreaPickerView.h
//  地区选择器Demo
//
//  Created by 远洋 on 2015/10/20.
//  Copyright © 2015年 yuayang. All rights reserved.
//
#import <UIKit/UIKit.h>
@class YJYYProvince,YJYYCity,YJYYDistrict;

@interface YJYYAreaPickerView : UIPickerView
- (instancetype)initWithCompletion:(void (^)(YJYYProvince *province, YJYYCity *city, YJYYDistrict *district))completion;

@end
