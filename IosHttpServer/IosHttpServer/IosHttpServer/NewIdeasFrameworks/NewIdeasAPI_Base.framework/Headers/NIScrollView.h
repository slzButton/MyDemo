//
//  NIScrollView.h
//  视图的轮播
//  Created by 　罗若文 on 15/11/22.
//  Copyright © 2015年 罗若文. All rights reserved.
//

#import <UIKit/UIKit.h>

///定义视图滑动代理
@protocol NIScrollViewDelegate <NSObject>
@optional
////点击视图的时候触发
-(void)NIScrollViewDidClicked:(UIView *)niScrollView index:(NSUInteger)index tag:(int)tag;
///手势滑动后  视图当前是第几张 从1开始: 1234
-(void)NIScrollViewNum:(UIView *)niScrollView index:(NSUInteger)index tag:(int)tag;
///开始滑动
-(void)NIScrollViewBegin:(UIView *)niScrollView tag:(int)tag;
@end

///视图的轮播
@interface NIScrollView : UIView<UIScrollViewDelegate>

///滑动视图代理
@property (weak, nonatomic) id<NIScrollViewDelegate> delegate;

///-(id)initWithFrameRect:视图位置大小 VeiwArray:视图列表 CycleTime:自动滚动时间0为不自动滚动  isScroll:是否要循环图片(默认不循环) isVertical:是否要垂直(默认水平);
///如果是要获取项目中得图片,且要循环滚动,请使用loadProjectImage方法获取项目图片.
-(id)initWithFrameRect:(CGRect)rect VeiwArray:(NSArray *)VeiwArray CycleTime:(float)time  isScroll:(BOOL)isScroll isVertical:(BOOL)isVertical tag:(int)tag;

@end
