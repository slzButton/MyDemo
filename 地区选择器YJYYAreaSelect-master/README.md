# YJYYAreaSelect
一句话集成地区选择器 

使用步骤:

1.将 YJYYAreaSelect文件夹 拖入项目

2.导入头文件 #import "YJYYAreaSelect.h"

3.调用构造方法实现地区选择器:

```
- (instancetype)initWithCompletion:(void (^)(YJYYProvince *province, YJYYCity *city, YJYYDistrict *district))completion;
```

一句话实现地区选择器的功能 参考代码如下:

//直接调用构造方法 设置成UITextField的inputView

```
self.textField.inputView = [[YJYYAreaPickerView alloc]initWithCompletion:^(YJYYProvince *province, YJYYCity *city, YJYYDistrict *district) {

    //这里写你需要执行的代码 如设置UITextField中的省份 城市 或者地区
}];
```



//人总是需要不断的学习和分享 做任何东西肯定会有很多的不足 诚心向大家请教 使用过程中有任何问题可以给我的邮箱发送邮件 
邮件地址:794708907@qq.com

