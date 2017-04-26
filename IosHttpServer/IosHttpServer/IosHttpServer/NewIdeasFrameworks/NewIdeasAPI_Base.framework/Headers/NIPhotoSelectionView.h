//
//  NIPhotoSelectionView.h
//  NewIdeasAPI_Base
//  图片选择,九宫格选择  (还未完善)
//  Created by 　罗若文 on 16/6/15.
//  Copyright © 2016年 罗若文. All rights reserved.
//

#import <UIKit/UIKit.h>

///回调
typedef void (^NIPhotoSelectionBlock)(id PhotoSelectionView);
typedef void (^NIPhotoSelectionClickBlock)(UIImage * photo);

@interface NIPhotoSelectionView : UIView

///选中得图片列表UIImage的Base64编码字符串列表
@property NSMutableArray * PhotoBase64List;

///选中得图片列表(UIImage)
@property NSMutableArray * listPhoto;

///是否剪裁
@property BOOL allowsEditing;

/// 3x3 九宫格图片添加视图
- (instancetype)initWithFrame:(CGRect)frame everyViewSize:(CGSize)everyViewSize refreshBlock:(NIPhotoSelectionBlock)refreshBlock photoClickBlock:(NIPhotoSelectionClickBlock)photoClickBlock;

/// 3x3 九宫格图片添加视图
- (instancetype)initWithFrame:(CGRect)frame everyViewSize:(CGSize)everyViewSize plistStyleKey:(NSString *)plistStyleKey refreshBlock:(NIPhotoSelectionBlock)refreshBlock photoClickBlock:(NIPhotoSelectionClickBlock)photoClickBlock;

///初始化视图 (视图大小,每个图片按钮的大小,图片按钮的样式,每行几列,总共几个,添加按钮的图片,视图改变的时候触发,点击图片按钮的时候触发为nil的时候是替换图片)
- (instancetype)initWithFrame:(CGRect)frame everyViewSize:(CGSize)everyViewSize plistStyleKey:(NSString *)plistStyleKey row:(int)row photoCount:(int)photoCount defaultImg:(UIImage *)defaultImg refreshBlock:(NIPhotoSelectionBlock)refreshBlock photoClickBlock:(NIPhotoSelectionClickBlock)photoClickBlock;

///打开相册或相机
-(void)openAlbumOrCamera;

#pragma mark - 删除第几张图片
-(void)deletePhoto:(int)index;
@end
