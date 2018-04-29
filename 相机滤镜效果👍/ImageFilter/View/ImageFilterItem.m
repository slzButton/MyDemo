//
//  ImageFilterItem.m
//  ImageFilter
//
//  Created by 冀秋羽 on 15/7/22.
//  Copyright (c) 2015年 冀秋羽. All rights reserved.
//

#import "ImageFilterItem.h"

@implementation ImageFilterItem


- (IBAction)btn_itemClick:(id)sender {
    if (_iconClick) {
        _iconClick();
    }
}
@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com