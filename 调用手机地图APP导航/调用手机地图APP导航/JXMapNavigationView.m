//
//  JXMapNavigationView.m
//  LocationBlock
//
//  Created by Seasaw on 16/1/11.
//  Copyright © 2016年 Seasaw. All rights reserved.
//

#import "JXMapNavigationView.h"
#import "CLLocation+YCLocation.h"
@interface JXMapNavigationView()
@property (nonatomic , strong)UIActionSheet *sheet;

@end

@implementation JXMapNavigationView
{
    double _currentLatitude;
    double _currentLongitute;
    double _targetLatitude;
    double _targetLongitute;
    NSString *_name;
    CLLocationManager *_manager;
}

-(id)init{
    self = [super init];
    if (self) {
    }
    return self;
}
- (UIActionSheet *)sheet{
    if (_sheet == nil) {
        _sheet = [[UIActionSheet alloc]init];
    }
    return _sheet;
}
+(NSArray *)checkHasOwnApp{
    NSArray *mapSchemeArr = @[@"comgooglemaps://",@"iosamap://navi",@"baidumap://map/",@"qqmap://"];
    
    NSMutableArray *appListArr = [[NSMutableArray alloc] initWithObjects:@"苹果原生地图", nil];
    
    for (int i = 0; i < [mapSchemeArr count]; i++) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[mapSchemeArr objectAtIndex:i]]]]) {
            if (i == 0) {
                [appListArr addObject:@"google地图"];
            }else if (i == 1){
                [appListArr addObject:@"高德地图"];
            }else if (i == 2){
                [appListArr addObject:@"百度地图"];
            }else if (i == 3){
                [appListArr addObject:@"腾讯地图"];
            }
        }
    }
    
    return appListArr;
}
- (void)showMapNavigationViewFormcurrentLatitude:(double)currentLatitude currentLongitute:(double)currentLongitute TotargetLatitude:(double)targetLatitude targetLongitute:(double)targetLongitute toName:(NSString *)name{
  
    CLLocation *from = [[CLLocation alloc]initWithLatitude:currentLatitude longitude:currentLongitute];
    CLLocation *fromLoction = [from locationMarsFromEarth];
    _currentLatitude = fromLoction.coordinate.latitude;
    _currentLongitute = fromLoction.coordinate.longitude;
    _targetLatitude = targetLatitude;
    _targetLongitute = targetLongitute;
    _name = name;
    NSArray *appListArr = [JXMapNavigationView checkHasOwnApp];
    NSString *sheetTitle = [NSString stringWithFormat:@"导航到 %@",name];
    if ([appListArr count] == 1) {
        _sheet = [[UIActionSheet alloc] initWithTitle:sheetTitle delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:appListArr[0], nil];
    }else if ([appListArr count] == 2) {
        _sheet = [[UIActionSheet alloc] initWithTitle:sheetTitle delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:appListArr[0],appListArr[1], nil];
    }else if ([appListArr count] == 3){
        _sheet = [[UIActionSheet alloc] initWithTitle:sheetTitle delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:appListArr[0],appListArr[1],appListArr[2], nil];
    }else if ([appListArr count] == 4){
        _sheet = [[UIActionSheet alloc] initWithTitle:sheetTitle delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:appListArr[0],appListArr[1],appListArr[2],appListArr[3], nil];
    }else if ([appListArr count] == 5){
        _sheet = [[UIActionSheet alloc] initWithTitle:sheetTitle delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:appListArr[0],appListArr[1],appListArr[2],appListArr[3],appListArr[4], nil];
    }
    _sheet.actionSheetStyle = UIActionSheetStyleDefault;
    
    [_sheet showInView:self];
    
}
- (void)remove{
    [_sheet removeFromSuperview];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    NSString *name = _name;
    float ios_version=[[[UIDevice currentDevice] systemVersion] floatValue];
    NSString *btnTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if (buttonIndex == 0) {
        if (ios_version < 6.0) {//ios6 调用goole网页地图
            NSString *urlString = [[NSString alloc]
                                   initWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f&dirfl=d",
                                   _currentLatitude,_currentLongitute,_targetLatitude,_targetLongitute];
            
            NSURL *aURL = [NSURL URLWithString:urlString];
            //打开网页google地图
            [[UIApplication sharedApplication] openURL:aURL];
        }else{//起点
            CLLocationCoordinate2D from = CLLocationCoordinate2DMake(_currentLatitude, _currentLongitute);
            MKMapItem *currentLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:from addressDictionary:nil]];
            currentLocation.name = @"我的位置";
            
            //终点
            CLLocationCoordinate2D to = CLLocationCoordinate2DMake(_targetLatitude, _targetLongitute);
            MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:to addressDictionary:nil]];
            NSLog(@"网页google地图:%f,%f",to.latitude,to.longitude);
            toLocation.name = name;
            NSArray *items = [NSArray arrayWithObjects:currentLocation, toLocation, nil];
            NSDictionary *options = @{
                                      MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving,
                                      MKLaunchOptionsMapTypeKey:
                                          [NSNumber numberWithInteger:MKMapTypeStandard],
                                      MKLaunchOptionsShowsTrafficKey:@YES
                                      };
            
            //打开苹果自身地图应用
            [MKMapItem openMapsWithItems:items launchOptions:options];
        }
    }
    if ([btnTitle isEqualToString:@"google地图"]) {
        NSString *urlStr = [NSString stringWithFormat:@"comgooglemaps://?saddr=%.8f,%.8f&daddr=%.8f,%.8f&directionsmode=transit",_currentLatitude,_currentLongitute,_targetLatitude,_targetLongitute];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
    }else if ([btnTitle isEqualToString:@"高德地图"]){
        NSString *urlString = [[NSString stringWithFormat:@"iosamap://path?sourceApplication=applicationName&sid=BGVIS1&slat=%f&slon=%f&sname=%@&did=BGVIS2&dlat=%f&dlon=%f&dname=%@&dev=0&m=0&t=0",_currentLatitude,_currentLongitute,@"我的位置",_targetLatitude,_targetLongitute,_name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *r = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:r];
        //        NSLog(@"%@",_lastAddress);
        
    }else if ([btnTitle isEqualToString:@"腾讯地图"]){
        NSString *urlStr = [NSString stringWithFormat:@"qqmap://map/routeplan?type=drive&fromcoord=%f,%f&tocoord=%f,%f&policy=1",_currentLatitude,_currentLongitute,_targetLatitude,_targetLongitute];
        NSURL *r = [NSURL URLWithString:urlStr];
        [[UIApplication sharedApplication] openURL:r];
    }else if([btnTitle isEqualToString:@"百度地图"])
    {

        CLLocation *from = [[CLLocation alloc]initWithLatitude:_currentLatitude longitude:_currentLongitute];
        CLLocation *fromLoction = [from locationBaiduFromMars];
        CLLocation *to = [[CLLocation alloc]initWithLatitude:_targetLatitude longitude:_targetLongitute];
        CLLocation *toLoction = [to locationBaiduFromMars];

        NSString *stringURL = [NSString stringWithFormat:@"baidumap://map/direction?origin=%f,%f&destination=%f,%f&&mode=driving",fromLoction.coordinate.latitude,fromLoction.coordinate.longitude,toLoction.coordinate.latitude,toLoction.coordinate.longitude];
        NSURL *url = [NSURL URLWithString:stringURL];
        [[UIApplication sharedApplication] openURL:url];
    }
}
- (void)showMapNavigationViewWithtargetLatitude:(double)targetLatitude targetLongitute:(double)targetLongitute toName:(NSString *)name{
    [self startLocation];
    _targetLatitude = targetLatitude;
    _targetLongitute = targetLongitute;
    _name = name;
}
//获取经纬度
-(void)startLocation
{
    if([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)
    {
        _manager=[[CLLocationManager alloc]init];
        _manager.delegate=self;
        _manager.desiredAccuracy = kCLLocationAccuracyBest;
        [_manager requestAlwaysAuthorization];
        _manager.distanceFilter=100;
        [_manager startUpdatingLocation];
    }
    else
    {
        UIAlertView *alvertView=[[UIAlertView alloc]initWithTitle:@"提示" message:@"需要开启定位服务,请到设置->隐私,打开定位服务" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alvertView show];
    }
    
}
#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [manager stopUpdatingLocation];
//    CLLocation *marLoction = [newLocation locationMarsFromEarth];
    [self showMapNavigationViewFormcurrentLatitude:newLocation.coordinate.latitude currentLongitute:newLocation.coordinate.longitude TotargetLatitude:_targetLatitude targetLongitute:_targetLongitute toName:_name];
    
}
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    [self stopLocation];
    
}
-(void)stopLocation
{
    _manager = nil;
}
@end
