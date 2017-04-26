//
//  NISegmentedControl.h
//  UISegmentedControl自定义
//  选择按钮控件
//  Created by 　罗若文 on 15/11/8.
//  Copyright © 2015年 罗若文. All rights reserved.
//

#import <UIKit/UIKit.h>

///回调
typedef void (^NISegmentedControlBlock)(id segmentedControl);

//定义代理
@protocol NISegmentedControlDelegate <NSObject>
@optional
///点击列表的时候
-(void)NISegmentedControlDidClicked:(UIView *)niSegmentedControl tag:(int)tag;
@end

#pragma mark - UISegmentedControl视图
///UISegmentedControl视图  选择按钮控件
@interface NISegmentedControl : UIView

@property (nonatomic,copy) NISegmentedControlBlock block;
@property (weak, nonatomic) id<NISegmentedControlDelegate> delegate;
///选项对应的值.没有对应就直接取title值
@property (nonatomic) NSArray * btnTitleValueList;
@property UISegmentedControl *segmentedControl;

#pragma mark - 要想让Server层能够通过反射机制取值,就要定义name,value.并实现gettingValue和settingValue方法
@property NSString * name;
@property NSString * value;
-(NSString *)gettingValue;
-(void)settingValue:(id)value;
#pragma mark ------------------------------------------------------------------------------------

///初始化函数1
-(instancetype)initWithFrame:(CGRect)frame btnTitleList:(NSArray *)btnTitleList defaultSelected:(int)defaultSelected plistStyleKey:(NSString *)plistStyleKey;
///初始化函数2 delegate
-(instancetype)initWithFrame:(CGRect)frame btnTitleList:(NSArray *)btnTitleList defaultSelected:(int)defaultSelected plistStyleKey:(NSString *)plistStyleKey delegate:(id)delegate;
///初始化函数3 block
-(instancetype)initWithFrame:(CGRect)frame btnTitleList:(NSArray *)btnTitleList defaultSelected:(int)defaultSelected plistStyleKey:(NSString *)plistStyleKey block:(NISegmentedControlBlock)block;

///选择对应的选项
-(void)selectedIndex:(int)index;

///给第index个选项添加覆盖视图
-(void)addCoverView:(UIView *)view index:(int)index;
@end
