//
//  NIFileUtil.h
//  文件操作
//  Created by oyf on 15/10/2.
//  Copyright © 2015年 com.newland. All rights reserved.
//

#import <Foundation/Foundation.h>

///下载文件存放路径
#define NIFileDir ([NSString stringWithFormat:@"%@/files",NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES)[0]])

///文件操作类定义代理
@protocol NIFileUtilDelegate <NSObject>
@optional
///开始下载
-(void)downloadFileRequestStar:(NSInteger)tag;
///下载中
-(void)downloadFileRequestRuning:(float)percent speed:(NSString *)speed tag:(NSInteger)tag;
///下载结束
-(void)downloadFileRequestFinished:(NSData *)data tag:(NSInteger)tag;
///下载错误
-(void)downloadFileRequestFailed:(NSInteger)tag;
@end

///文件操作类
@interface NIFileUtil : NSObject

@property (weak, nonatomic) id<NIFileUtilDelegate> delegate;

/**
 * 下载文件 采用代理
 *
 * @param string aUrl 请求文件地址
 * @param string aSavePath 保存地址  xx/xx
 * @param string aFileName 文件名
  * @param string knowFileSize 文件大小,小于0为不知道
 * @param int aTag tag标识
 */
- (void)downloadFileURL:(NSString *)aUrl savePath:(NSString *)aSavePath fileName:(NSString *)aFileName knowFileSize:(float)knowFileSize tag:(NSInteger)tag;

/**
 * 下载文件 采用block
 *
 * @param string aUrl 请求文件地址
 * @param string aSavePath 保存地址  xx/xx
 * @param string aFileName 文件名
 * @param string knowFileSize 文件大小,小于0为不知道
 * @param int aTag tag标识
 */
-(void)downloadFileURL:(NSString *)aUrl savePath:(NSString *)aSavePath fileName:(NSString *)aFileName knowFileSize:(float)knowFileSize
                   Star:(void (^)())Star
                 Runing:(void (^)(float percent,NSString * speed))Runing
               Finished:(void (^)(NSData * data))Finished
                 Failed:(void (^)())Failed;

///判断文件是否存在 存在yes
+(BOOL)fileIsExist:(NSString * )filePath;

///删除文件
+(void)delFile:(NSString * )filePath;
@end
