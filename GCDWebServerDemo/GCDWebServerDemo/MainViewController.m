//
//  MainViewController.m
//  GCDWebServerDemo
//
//  Created by cltx on 2016/10/19.
//  Copyright © 2016年 cltx. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()


@end

@implementation MainViewController



- (void)viewDidLoad {
     [super viewDidLoad];
     
     
     UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0.0, 100, UIScreen.mainScreen.bounds.size.width, 100.0)];
     [self.view addSubview:label];
     label.text = self.ip;
     label.textColor = [UIColor blackColor];
     label.backgroundColor = [UIColor whiteColor];
     label.textAlignment = NSTextAlignmentCenter;
     label.numberOfLines = 0;
     
     
     
     
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
