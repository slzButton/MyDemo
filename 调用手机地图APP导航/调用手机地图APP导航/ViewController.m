//
//  ViewController.m
//  调用手机地图APP导航
//
//  Created by Seasaw on 16/1/11.
//  Copyright © 2016年 Seasaw. All rights reserved.
//

#import "ViewController.h"
#import "JXMapNavigationView.h"

@interface ViewController ()
@property (nonatomic, strong)JXMapNavigationView *mapNavigationView;

@end

@implementation ViewController
- (JXMapNavigationView *)mapNavigationView{
    if (_mapNavigationView == nil) {
        _mapNavigationView = [[JXMapNavigationView alloc]init];
    }
    return _mapNavigationView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
}

//从指定地导航到指定地
//currentLatitude:22.477806  ;:113.902847
// targetLati:22.488260 targetLongi:113.915049
//toName:中海油华英加油站
- (IBAction)button1:(id)sender {
        [self.mapNavigationView showMapNavigationViewFormcurrentLatitude:30.306906 currentLongitute:120.107265 TotargetLatitude:22.488260 targetLongitute:113.915049 toName:@"中海油华英加油站"];
        [self.view addSubview:_mapNavigationView];
}

//从目前位置导航到指定地
// targetLati:22.488260 targetLongi:113.915049
//toName:中海油华英加油站
- (IBAction)button2:(id)sender {
    [self.mapNavigationView showMapNavigationViewWithtargetLatitude:22.488260 targetLongitute:113.915049 toName:@"中海油华英加油站"];
    [self.view addSubview:_mapNavigationView];
}

@end
