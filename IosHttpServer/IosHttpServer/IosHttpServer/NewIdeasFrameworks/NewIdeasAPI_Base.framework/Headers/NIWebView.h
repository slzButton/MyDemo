//
//  NIWebView.h
//  UIWebView的通用类
//  Created by 　罗若文 on 15/12/31.
//  Copyright © 2015年 罗若文. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - 代理
@protocol NIWebViewDelegate <NSObject>
@optional
/**开始加载*/
-(void)NIWebViewStartLoad:(UIView *)niWebView tag:(int)tag;

/**加载结束*/
-(void)NIWebViewFinishLoad:(UIView *)niWebView tag:(int)tag;

/**加载错误*/
-(void)NIWebViewLoadError:(UIView *)niWebView error:(NSError *)error tag:(int)tag;

/**js调用ios返回的结果 html上面调用 objc(xxx)*/
-(void)NIWebViewJsInvokingObjc:(UIView *)niWebView resultList:(NSArray *)resultList tag:(int)tag;
@end

#pragma mark - webview类
/// UIWebView封装类
@interface NIWebView : UIView<UIWebViewDelegate>

@property UIWebView* webView;
@property (weak, nonatomic) id<NIWebViewDelegate> delegate;

///初始化视图
-(id)initWithFrameRect:(CGRect)rect isUserClick:(BOOL)isUserClick tag:(int)tag;
///初始化视图 本地html
-(id)initWithFrameRect:(CGRect)rect Document:(NSString *)docName InvokingJsFun:(NSString *)funStr isUserClick:(BOOL)isUserClick tag:(int)tag;
///初始化视图 在线url
-(id)initWithFrameRect:(CGRect)rect url:(NSString *)urlWeb isUserClick:(BOOL)isUserClick tag:(int)tag;

/**webview加载本地html 或 请求url*/
-(void)loadDocument:(NSString *)docName url:(NSString *)urlWeb;

/**iOS调用js  方法名(参数1,参数2...)*/
-(void)InvokingJsFun:(NSString *)funStr;

/**开启和关闭触摸*/
-(void)openUserClick:(BOOL)isUserClick;

///清除缓存/cookie
-(void)clearCookie;

@end
