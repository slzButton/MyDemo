//
//  NIFileViewer.h
//  简单的文件查看器
//  Created by 　罗若文 on 16/4/13.
//  Copyright © 2016年 罗若文. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>

///简单的文件查看器
@interface NIFileViewer : QLPreviewController

///初始化 文件路径
///用[self presentViewController:sm animated:YES completion:nil];方式打开
-(instancetype)initWithPath:(NSString *)urlPath;

@end
