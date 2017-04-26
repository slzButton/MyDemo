//
//  NIImage.h
//  NewIdeasBasicsProject
//
//  Created by 　罗若文 on 16/4/22.
//  Copyright © 2016年 罗若文. All rights reserved.
//

#import <UIKit/UIKit.h>
///本地图片保存路径
#define NIImageDir ([NSString stringWithFormat:@"%@/images",NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask,YES)[0]])

///图片设置常用类
@interface NIImage : UIImage

///对指定的UI控件进行截图
+ (UIImage*) captureView:(UIView*)targetView;

///截取屏幕
+ (UIImage*) captureScreen;

///竖着拼接多张图片
+ (UIImage*) addImages:(NSMutableArray *)imageArr;

///根据颜色返回图片
+(UIImage*) imageWithColor:(UIColor*)color;

///获取本地图片
+(UIImage*)loadLocalImage:(NSString*)imageName;

///获取项目图片
+(UIImage *)loadProjectImage:(NSString *)imageName;

///根据图片名获取图片
+(UIImage *)imageNamed:(NSString *)imageName;

///根据图片名和大小获取图片
+(UIImage *)imageNamed:(NSString *)imageName imageWidth:(float)width imageHeight:(float)height;

///根据图片名和大小获取图片
+(UIImage *)imageNamed:(NSString *)imageName targetSize:(CGSize)targetSize;

///保存到相册
+(void) saveToPhotosAlbum:(UIImage *)image;

///保存图片-- NIImageDir
+ (BOOL) saveImage:(UIImage *)image imgName:(NSString *)imgName;

///保存图片到Documents下
+ (void) saveToDocuments:(UIImage *)image fileName:(NSString*)fileName;

///定义一个方法用户“挖取”图片的指定区域
+ (UIImage*) imageAtRect:(UIImage *)image rect:(CGRect)rect;

/** 保持图片纵横比例缩放，最短边必须匹配targetSize的大小
 可能有一条边的长度会超过targetSize制定的大小*/
+ (UIImage *) imageByScalingAspectToMinSize:(UIImage *)image targetSize:(CGSize)targetSize;

///直接缩放，不管比例问题
+ (UIImage *) imageByScalingToSize:(UIImage *)image targetSize:(CGSize)targetSize;

///对图片按弧度执行旋转
+ (UIImage *) imageRotateByRadians:(UIImage *)image radians:(CGFloat)radians;

///对图片按角度执行旋转
+ (UIImage *)imageRotateByDegrees:(UIImage *)image degrees:(CGFloat)degrees;

///图片转成base64字符串
+(NSString *)ImageToString:(UIImage *)image;

///将base64字符串转成图片
+(UIImage *)ImageWithString:(NSString *)base64String;
@end
