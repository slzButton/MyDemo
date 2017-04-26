//
//  NILayoutView.h
//  线性布局
//  Created by 　罗若文 on 16/3/29.
//  Copyright © 2016年 罗若文. All rights reserved.
//
//

#import <UIKit/UIKit.h>

#pragma mark - 类型定义
typedef NS_ENUM(NSInteger, NILayoutStyle) {
    ///垂直
    NILayoutStyleVertical,
    ///水平
    NILayoutStyleHorizontal
};

#pragma mark - 定义代理
///定义布局代理
@protocol NILayoutViewDelegate <NSObject>
@optional
///布局滑动的时候
-(void)NILayoutViewDidScroll:(UIView *)niLayoutView contentOffset:(CGPoint)contentOffset tag:(int)tag;
@end

#pragma mark - 布局视图
///布局视图(默认是垂直方向)
@interface NILayoutView : UIView

@property (weak, nonatomic) id<NILayoutViewDelegate> delegate;

@property UIScrollView * layout;

///初始化设置
-(instancetype)initWithFrame:(CGRect)frame listViews:(NSArray *)listViews LayoutStyle:(NILayoutStyle)LayoutStyle;

///初始化设置
-(instancetype)initWithFrame:(CGRect)frame;

///设置布局的方向
-(void)setLayout_Style:(NILayoutStyle)LayoutStyle;

///刷新布局
-(void)reloadLayout;

///刷新布局 是否改变位置
-(void)reloadLayoutWithChangePosition:(BOOL)yesOrNo;

///刷新布局
-(void)reloadLayout:(CGRect)frame;

///刷新布局 是否改变位置
-(void)reloadLayout:(CGRect)frame isChangePosition:(BOOL)yesOrNo;

///刷新视图列表
-(void)refreshListViews:(NSArray *)listViews;

///获取视图列表  说明:视图列表中tag=10001的是间隔视图
-(NSMutableArray *)getListViews;

///获取该视图相对屏幕的位置大小
-(CGRect)getViewRect:(UIView *)view;

///添加头部视图
-(void)addHeaderView:(UIView *)headerView;

///删除头部视图
-(void)delHeaderView;

///添加脚部视图
-(void)addFooterView:(UIView *)footerView;

///删除脚部视图
-(void)delFooterView;

///返回最前面
-(void)topClick;

///添加间隔  interval:间隔的长度
-(void)addInterval:(float)interval;

///添加单个视图
-(void)addView:(UIView *)view;

@end
