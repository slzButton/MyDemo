//
//  ViewController.h
//  ImageFilter
//
//  Created by 冀秋羽 on 15/7/22.
//  Copyright (c) 2015年 冀秋羽. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditImageController.h"

@interface ViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate>{
    
    EditImageController * editImageController;
}
@property(nonatomic,strong)UIImagePickerController * imagePickerVC;
@property(nonatomic,strong)UIImage * editImage;

- (IBAction)openCamera:(id)sender;

@end

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com