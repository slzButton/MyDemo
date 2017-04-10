//
//  AppDelegate.m
//  GCDWebServerDemo
//
//  Created by cltx on 2016/10/19.
//  Copyright © 2016年 cltx. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "GCDWebServerURLEncodedFormRequest.h"
#import "GCDWebServerDataRequest.h"
#import "GCDWebServerDataResponse.h"
#import <GCDWebServerErrorResponse.h>
#import <GCDWebServerFileResponse.h>
#import <GCDWebServerStreamedResponse.h>
#import "GCDWebUploader.h"
#import <GCDWebDAVServer.h>


#import "TYDownLoadModel.h"
#import "TYDownLoadDataManager.h"
#import "TYDownloadSessionManager.h"
#import <CoreLocation/CoreLocation.h>
#import <AFNetworking.h>
#import <MJExtension.h>


static inline NSString * AFContentTypeForPathExtension(NSString *extension) {
    NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL);
    NSString *contentType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
    if (!contentType) {
        return @"application/octet-stream";
    } else {
        return contentType;
    }
}

@interface AppDelegate ()<GCDWebUploaderDelegate,GCDWebServerDelegate,CLLocationManagerDelegate>
/**
 @brief  web服务管理者
 */
@property(nonatomic,strong)GCDWebServer *webServer;
/**
 @brief  上传文件管理者
 */
@property(nonatomic,strong)GCDWebUploader *webUploader;

@property(strong,nonatomic)CLLocationManager *locationManager;//位置管理者

@end

@implementation AppDelegate

-(GCDWebServer *)webServer{
    if (_webServer == nil) {
        _webServer = [[GCDWebServer alloc] init];
        _webServer.delegate = self;
    }
    return _webServer;
}
-(UIWindow *)window{
    if (_window == nil) {
        _window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _window.backgroundColor = [UIColor whiteColor];
        [_window makeKeyAndVisible];
    }
    return _window;
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSLog(@"%@",NSHomeDirectory());
    
    // Get the path to the website directory
    NSString* websitePath = [[NSBundle mainBundle] pathForResource:@"carPlayer" ofType:nil];
//     NSString* websitePath = [[NSBundle mainBundle] pathForResource:@"Website" ofType:nil];
    
    // Add a default handler to serve static files (i.e. anything other than HTML files)
    [self.webServer addGETHandlerForBasePath:@"/" directoryPath:websitePath indexFilename:nil cacheAge:3600 allowRangeRequests:YES];
    __weak typeof(self)tempSelf = self;
    // Add an override handler for all requests to "*.html" URLs to do the special HTML templatization
    [self.webServer addHandlerForMethod:@"GET"
                              pathRegex:@"/.*\.html"
                           requestClass:[GCDWebServerRequest class]
                           processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
                               NSLog(@"%@",request.path);
                               return [GCDWebServerFileResponse responseWithFile:[websitePath stringByAppendingPathComponent:request.path]];
                           }];
    
    [self.webServer addHandlerForMethod:@"GET"
                              pathRegex:@"/.*\.mp3"
                           requestClass:[GCDWebServerRequest class]
                           processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
                               NSLog(@"%@",[[NSBundle mainBundle] pathForResource:request.path ofType:nil]);
                               if ([[NSBundle mainBundle] pathForResource:request.path ofType:nil]) {
                                   return [GCDWebServerFileResponse responseWithFile:[[NSBundle mainBundle] pathForResource:request.path ofType:nil]];
                               }else{
                                   return [GCDWebServerErrorResponse responseWithClientError:kGCDWebServerHTTPStatusCode_NotFound message:@"没有"];
                               }
                           }];
    
    [self.webServer addHandlerForMethod:@"GET"
                              pathRegex:@"/.*\.mp4"
                           requestClass:[GCDWebServerRequest class]
                           asyncProcessBlock:^(__kindof GCDWebServerRequest *request, GCDWebServerCompletionBlock completionBlock) {
                               GCDWebServerStreamedResponse *response = [GCDWebServerStreamedResponse response];
                               [response setValue:nil forAdditionalHeader:nil];
                           }];
    
    // Add an override handler to redirect "/" URL to "/index.html"
    [self.webServer addHandlerForMethod:@"GET"
                                   path:@"/"
                           requestClass:[GCDWebServerRequest class]
                           processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
                               return [GCDWebServerResponse responseWithRedirect:[NSURL URLWithString:@"index.html" relativeToURL:request.URL] permanent:YES];
                           }];
    
    //POST
    [self.webServer addHandlerForMethod:@"POST"
                                   path:@"/api"
                           requestClass:[GCDWebServerURLEncodedFormRequest class]
                           processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
                               NSDictionary *arguments = [(GCDWebServerURLEncodedFormRequest *)request arguments];
                               NSLog(@"%@",arguments);
                               NSMutableDictionary *responeDictionary = [NSMutableDictionary dictionaryWithCapacity:1];
                               if (arguments[@"multimediaType"]) {
                                   switch ([arguments[@"multimediaType"] integerValue]) {
                                       case 0:{
                                           [responeDictionary setObject:@[@{@"name":@"yangcong",@"url":[NSString stringWithFormat:@"%@/yangcong.mp3",tempSelf.webServer.serverURL]}] forKey:@"locality"];
                                           [responeDictionary setObject:@[@{@"name":@"你猜猜",@"url":[NSString stringWithFormat:@"%@/version",tempSelf.webServer.serverURL]}] forKey:@"online"];
                                       }
                                           break;
                                       case 1:{
                                           [responeDictionary setObject:@[@{@"name":@"我也不知道是啥",@"url":[NSString stringWithFormat:@"%@%@",tempSelf.webServer.serverURL,@"/1.mp4"]}] forKey:@"online"];
                                       }
                                           break;
                                       default:
                                           break;
                                   }
                               }
                               return [GCDWebServerDataResponse responseWithJSONObject:responeDictionary.mj_JSONObject];
                           }];
    
    [self.webServer addHandlerForMethod:@"GET" pathRegex:@"/.*\.m4a" requestClass:[GCDWebServerRequest class] asyncProcessBlock:^(__kindof GCDWebServerRequest *request, GCDWebServerCompletionBlock completionBlock) {
        NSString *downloadURL1 = @"192.168.4.248:8080/mp3/yangcong1.m4a";
        GCDWebServerStreamedResponse *respone = [GCDWebServerStreamedResponse responseWithContentType:AFContentTypeForPathExtension([request.path pathExtension]) asyncStreamBlock:^(GCDWebServerBodyReaderCompletionBlock completionBlock) {
            
            TYDownloadModel *model = [[TYDownLoadDataManager manager] downLoadingModelForURLString:downloadURL1];
            if (!model) {
                model = [[TYDownloadModel alloc]initWithURLString:downloadURL1];
            }
            [[TYDownLoadDataManager manager] startWithDownloadModel:model progress:^(TYDownloadProgress *progress) {
                
            } state:^(TYDownloadState state, NSString *const filePath, NSError *error) {
                if (state == TYDownloadStateCompleted) {
                    NSData *data = [NSData dataWithContentsOfFile:filePath];
                    NSString *downloadURL2 = @"192.168.4.248:8080/mp3/yangcong2.m4a";
                    TYDownloadModel *model = [[TYDownLoadDataManager manager] downLoadingModelForURLString:downloadURL2];
                    if (!model) {
                        model = [[TYDownloadModel alloc]initWithURLString:downloadURL2];
                    }
                    [[TYDownLoadDataManager manager] startWithDownloadModel:model progress:^(TYDownloadProgress *progress) {
                        
                    } state:^(TYDownloadState state, NSString *const filePath, NSError *error) {
                        if (state == TYDownloadStateCompleted) {
                            NSData *data = [NSData dataWithContentsOfFile:filePath];
                            completionBlock(data,nil);
                        }
                        if (state == TYDownloadStateFailed) {
                            
                        }
                    }];
                    completionBlock(data,nil);
                }
                if (state == TYDownloadStateFailed) {
                    
                }
                
            }];
        }];
        
        completionBlock(respone);
        
    }];
    
    // Start server on port 8080
    [self.webServer startWithOptions:@{GCDWebServerOption_Port:@(8080),GCDWebServerOption_AutomaticallySuspendInBackground:@(NO)} error:nil];
    NSLog(@"webServer Visit %@ in your web browser", self.webServer.serverURL);
    
    self.locationManager=[[CLLocationManager alloc]init];
    if ([[UIDevice currentDevice].systemVersion floatValue]>=8.0)
    {
        //下面两个随便写一个(最好用always)
        //需要在plist文件中添加默认缺省的字段“NSLocationAlwaysUsageDescription”，这个提示是:“允许应用程序在您并未使用该应用程序时访问您的位置吗？”NSLocationAlwaysUsageDescription对应的值是告诉用户使用定位的目的或者是标记。
        [self.locationManager requestAlwaysAuthorization];
    }
    
    //设置定位的精确度（5种）
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    //更新距离，位置信息里面有两种，一个是用户当前位置，这个是时时更新的，在地图上显示为一个蓝色的小点，另一个是didUpdateLocations代理方法中的locations数组里面的位置这个位置信息，在用户当前位置超过下面所设定的值以后才会更新，精确度越高越费电
    //设置筛选器 多少米后进行更新
    self.locationManager.distanceFilter=1.0f;//(10米)
    //距离筛选器设为无(实时更新)
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    //设置代理
    self.locationManager.delegate=self;
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    self.locationManager.allowsBackgroundLocationUpdates = YES;
    //Heading朝向，主要用于检测当前GPS方向角
    [self.locationManager startUpdatingHeading];
    //开启实时更新位置
    [self.locationManager startUpdatingLocation];
    
    MainViewController *mainVC = [MainViewController new];
    mainVC.ip = self.webServer.serverURL.absoluteString;
    self.window.rootViewController = mainVC;
    
    return YES;
}


     
 - (void)webUploader:(GCDWebUploader*)uploader didUploadFileAtPath:(NSString*)path {
     NSLog(@"[UPLOAD] %@", path);
 }
 
 - (void)webUploader:(GCDWebUploader*)uploader didMoveItemFromPath:(NSString*)fromPath toPath:(NSString*)toPath {
     NSLog(@"[MOVE] %@ -> %@", fromPath, toPath);
 }
 
 - (void)webUploader:(GCDWebUploader*)uploader didDeleteItemAtPath:(NSString*)path {
     NSLog(@"[DELETE] %@", path);
 }
 
 - (void)webUploader:(GCDWebUploader*)uploader didCreateDirectoryAtPath:(NSString*)path {
     NSLog(@"[CREATE] %@", path);
 }
/**
 *  This method is called whenever a file has been downloaded.
 */
 - (void)webUploader:(GCDWebUploader*)uploader didDownloadFileAtPath:(NSString*)path{
     NSLog(@"[DOWNLOAD] %@", path);
 }
 
/**
 *  This method is called after the server has successfully started.
 */
 - (void)webServerDidStart:(GCDWebServer*)server{
     
 }
 
/**
 *  This method is called after the Bonjour registration for the server has
 *  successfully completed.
 *
 *  Use the "bonjourServerURL" property to retrieve the Bonjour address of the
 *  server.
 */
 - (void)webServerDidCompleteBonjourRegistration:(GCDWebServer*)server{
     
 }
 
/**
 *  This method is called after the NAT port mapping for the server has been
 *  updated.
 *
 *  Use the "publicServerURL" property to retrieve the public address of the
 *  server.
 */
 - (void)webServerDidUpdateNATPortMapping:(GCDWebServer*)server{
     
 }
 
/**
 *  This method is called when the first GCDWebServerConnection is opened by the
 *  server to serve a series of HTTP requests.
 *
 *  A series of HTTP requests is considered ongoing as long as new HTTP requests
 *  keep coming (and new GCDWebServerConnection instances keep being opened),
 *  until before the last HTTP request has been responded to (and the
 *  corresponding last GCDWebServerConnection closed).
 */
 - (void)webServerDidConnect:(GCDWebServer*)server{
     
 }
 
/**
 *  This method is called when the last GCDWebServerConnection is closed after
 *  the server has served a series of HTTP requests.
 *
 *  The GCDWebServerOption_ConnectedStateCoalescingInterval option can be used
 *  to have the server wait some extra delay before considering that the series
 *  of HTTP requests has ended (in case there some latency between consecutive
 *  requests). This effectively coalesces the calls to -webServerDidConnect:
 *  and -webServerDidDisconnect:.
 */
 - (void)webServerDidDisconnect:(GCDWebServer*)server{
     
 }
 
/**
 *  This method is called after the server has stopped.
 */
 - (void)webServerDidStop:(GCDWebServer*)server{
     
 }

#pragma -mark locationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"locations=%@",locations);
    //CLLocation是位置类,主要的属性有经纬度，海拔，移动速度等
    CLLocation *loc=[locations lastObject];
    NSLog(@"lat=%f,lon=%f",loc.coordinate.latitude,loc.coordinate.longitude);
    //------------------位置解析（ios5以后）---------------------
    CLGeocoder *geocoder=[[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:loc
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       for (CLPlacemark *place in placemarks)//for-in快速枚举
                       {
                           //里面还有很多位置信息的属性，这里只列举这么多，剩下的可以点到API里面去看一下
                           NSLog(@"name=%@",place.name);//位置名
                           NSLog(@"thoroughfare=%@",place.thoroughfare);//街道名
                           NSLog(@"sunthoroughfare=%@",place.subThoroughfare);//子街道
                           NSLog(@"locality=%@",place.locality);//市
                           NSLog(@"sublocality=%@",place.subLocality);//区
                           NSLog(@"conutry=%@",place.country);//国家
                       }
                   }];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    // NSLog(@"---newheading=%@",newHeading);
    int magneticheading=(int)newHeading.magneticHeading;//磁航道，于地理北极夹角为0
    
    //    NSLog(@"magneticheading=%d",magneticheading);
    //定位方向的精确度
    NSLog(@"headingAccuracy=%f",newHeading.headingAccuracy);
    //获得定位的时间
    NSLog(@"timestamp=%@",newHeading.timestamp);
    NSLog(@"description=%@",newHeading.description);
    
    if ((0<magneticheading&&magneticheading<45)||(315<magneticheading&&magneticheading<360))
    {
        NSLog(@"magneticheading=%d",magneticheading);
        NSLog(@"现在你的手机朝向为北");
    }
    else if (45<magneticheading&&magneticheading<=135)
    {
        NSLog(@"现在你的手机朝向为东");
    }
    else if(135<magneticheading&&magneticheading<=225)
    {
        NSLog(@"现在你的手机朝向为南");
    }
    else
    {
        NSLog(@"现在你的手机朝向为西");
    }
    
}

@end
