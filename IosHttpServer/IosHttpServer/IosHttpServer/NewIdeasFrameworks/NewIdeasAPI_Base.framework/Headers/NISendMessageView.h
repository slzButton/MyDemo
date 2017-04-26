//
//  NISendMessageView.h
//  发短信
//  Created by 　罗若文 on 16/4/12.
//  Copyright © 2016年 罗若文. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#pragma mark - 回调
///回调
typedef void (^NISendMessageBlock)(id result);

///发送短信类
@interface NISendMessageView : MFMessageComposeViewController

///回调
@property(nonatomic,copy)NISendMessageBlock block;

///初始化:内容 电话 block{操作结果:发送取消,发送成功,发送失败,没有发送}  return 可能为nil 不能发送 在跳转前要先判断是否为空
///用[self presentViewController:sm animated:YES completion:nil];方式打开
-(instancetype)initWithMessage:(NSString *)body phoneCode:(NSString *)phoneCode block:(NISendMessageBlock)block;

///初始化:内容 多个电话 附件 block{操作结果:发送取消,发送成功,发送失败,没有发送}  return 可能为nil 不能发送 在跳转前要先判断是否为空
///发送带附件的短信  attachmentsData {fileName:data}
///用[self presentViewController:sm animated:YES completion:nil];方式打开
-(instancetype)initWithMessage:(NSString *)body phoneCodes:(NSArray *)phoneCodes attachmentsData:(NSDictionary *)attachmentsData block:(NISendMessageBlock)block;

///设置消息的标题(好像没效果)
-(void)setMessageTitle:(NSString *)msgTitle;
@end
