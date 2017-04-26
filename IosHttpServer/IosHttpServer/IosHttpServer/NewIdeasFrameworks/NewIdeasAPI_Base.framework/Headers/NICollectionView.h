//
//  NICollectionView.h
//  封装UICollectionView
//  Created by 　罗若文 on 16/3/30.
//  Copyright © 2016年 罗若文. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - 定义代理
///定义布局代理
@protocol NICollectionViewDelegate <NSObject>
@optional
////点击视图的时候触发
-(void)NICollectionViewDidClicked:(UIView *)niCollectionView index:(NSUInteger)index tag:(int)tag;
@end

///封装UICollectionView类
@interface NICollectionView : UIView

@property (weak, nonatomic) id<NICollectionViewDelegate> delegate;

@property UICollectionView * collectionView;    //

- (instancetype)initWithFrame:(CGRect)frame;

///按顺序排列视图
- (instancetype)initWithFrame:(CGRect)frame listViews:(NSArray *)listViews CollectionStyle:(UICollectionViewScrollDirection)CollectionStyle;

///按顺序排列视图(平均排列,几宫格样式)
- (instancetype)initWithFrame:(CGRect)frame listViews:(NSArray *)listViews everyViewSize:(CGSize)everyViewSize row:(int)row;

///设置视图为几宫格的样式
-(void)setViewGrid:(BOOL)isGrid;

///设置布局的方向 : UICollectionViewScrollDirectionVertical,UICollectionViewScrollDirectionHorizontal
-(void)setCollectionView_Style:(UICollectionViewScrollDirection)CollectionStyle;

///设置cell的边框和边框颜色
-(void)setViewBorderWidth:(float)width borderColor:(UIColor *)borderColor;

///刷新布局
-(void)reloadCollection;

///添加单个视图
-(void)addView:(UIView *)view;

///刷新视图列表
-(void)refreshListViews:(NSArray *)listViews;

///获取视图列表
-(NSMutableArray *)getListViews;

///返回最前面
-(void)topClick;
@end
