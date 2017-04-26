//
//  ViewController.m
//  IosHttpServer
//
//  Created by 　罗若文 on 16/6/24.
//  Copyright © 2016年 罗若文. All rights reserved.
//

#import "ViewController.h"
#import <NewIdeasAPI_LocHttpServer/NewIdeasAPI_LocHttpServer.h>
#import <NewIdeasAPI_Base/NewIdeasAPI_Base.h>

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIButton *localhost;
@property (strong, nonatomic) IBOutlet UIButton *loaclhost_1;
@property (strong, nonatomic) IBOutlet UIButton *localhost_login;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage * img=[NIImage imageNamed:@"objective-c的架构图.jpg"];
    NSData * imageData=UIImagePNGRepresentation(img);
    [NIHTTPServer setActionResponseData:imageData action:@"/img.jpg"];
    
    id imgData=[NIImage ImageToString:img];
    //局域网内可以用浏览器访问http://手机ip:端口/1/1.do  得到该数据
    [NIHTTPServer setActionResponseHtml:[NSString stringWithFormat:@"<html><head><title>objective-c的架构图</title></head><body><h1>objective-c的架构图</h1><p>架构图:</p><image src=\"data:image/jpg;base64,%@\"></body></html>",imgData] action:@"/1/1.do"];

    
    //局域网内可以用浏览器访问http://手机ip:端口/login.do  得到该数据
    [NIHTTPServer setActionResponseJson:@"这边可以设置/login.do路径下可以得到的字符串" action:@"/login.do"];
    
    //这方法可以设置在请求本机http服务的时候,在Response返回数据之前执行testHttp方法
    [NIHTTPServer setMethodForHTTPServer:@selector(testHttp:) methodObject:self];
}


-(void)testHttp:(NSString *)action{
    //这边可以拦截action,判断做对应的操作,可以控制对应的action要返回的动态数据
    if([@"/" isEqualToString:action]){
        //同步请求数据
        NSString *dataUrl = [NSString stringWithFormat:@"https://git.oschina.net/luoruowen/LRWplist/raw/master/Mbomc.plist"];
        dataUrl = [dataUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:dataUrl];
        NSString *responseString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        //将数据放入到
        [NIHTTPServer setActionResponseJson:responseString action:action];
    }
}

- (IBAction)localhost:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://127.0.0.1:8080/"]];
}

- (IBAction)loaclhost_1:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://127.0.0.1:8080/1/1.do"]];
}

- (IBAction)localhost_login:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://127.0.0.1:8080/login.do"]];
}

- (IBAction)imgBtn:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://127.0.0.1:8080/img.jpg"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *)analysisHtmlImage:(NSString *)htmlstr{
    
    [NIString regexToList:htmlstr regex:@""];
    
    
    return @"";
}

@end
