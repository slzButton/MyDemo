//
//  ViewController.m
//  TestMongoose
//
//  Created by user on 15/5/13.
//  Copyright (c) 2015年 JenuryCheng. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:imgView];
    
    NSString *home = NSHomeDirectory();
    NSString *temp = [home stringByAppendingPathComponent:@"tmp"];
    UIImage *img = [UIImage imageNamed:@"test"];
    NSData *data = UIImageJPEGRepresentation(img, 1);

    NSString *path = [temp stringByAppendingPathComponent:@"test.jpg"];
    [data writeToFile:path atomically:YES];
    
    NSURL *url = [NSURL URLWithString:@"http://127.0.0.1:8080/tmp/test.jpg"];
    NSData *getData = [NSData dataWithContentsOfURL:url];
    UIImage *getImg = [UIImage imageWithData:getData];
    imgView.image = getImg;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
