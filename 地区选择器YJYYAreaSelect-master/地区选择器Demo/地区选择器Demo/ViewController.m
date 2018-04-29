//
//  ViewController.m
//  地区选择器Demo
//
//  Created by 远洋 on 2015/10/20.
//  Copyright © 2015年 yuayang. All rights reserved.
//

#import "ViewController.h"
#import "YJYYAreaSelect.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *provinceLable;

@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *districtLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //下面的代码是防止循环引用
    __weak typeof(self) weakSelf = self;
    
    //直接调用构造方法 设置成UITextField的inputView
    self.textField.inputView = [[YJYYAreaPickerView alloc]initWithCompletion:^(YJYYProvince *province, YJYYCity *city, YJYYDistrict *district) {
        //设置省份
        weakSelf.provinceLable.text = province.name;
        //设置城市
        weakSelf.cityLabel.text = city.name;
        //设置地区
        weakSelf.districtLabel.text = district.name;
        //设置textField文本
        weakSelf.textField.text = [NSString stringWithFormat:@"%@--%@--%@",province.name,city.name,district.name];
    }];
    //记得设置第一响应者 
    [self.textField becomeFirstResponder];
}


@end
