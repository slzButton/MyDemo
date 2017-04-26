//
//  NISendMailView.h
//  NewIdeasAPI_Base
//  发送邮件
//  Created by 　罗若文 on 16/7/14.
//  Copyright © 2016年 罗若文. All rights reserved.
//

#import <MessageUI/MessageUI.h>

#pragma mark - 回调
///回调
typedef void (^NISendMailBlock)(id result);

@interface NISendMailView : MFMailComposeViewController

///回调
@property(nonatomic,copy)NISendMailBlock block;


///初始化方法:标题,内容,收件人(多个),抄送(多个),密送(多个),附件{fileName:data} block{操作结果:发送取消,发送成功,发送失败,邮件被保存} return 可能为nil 不能发送 在跳转前要先判断是否为空
///用[self presentViewController:sm animated:YES completion:nil];方式打开
- (instancetype)initWithTitle:(NSString *)title contentStr:(NSString *)contentStr toRecipients:(NSArray *)toRecipients ccRecipients:(NSArray *)ccRecipients bccRecipients:(NSArray *)bccRecipients attachmentsData:(NSDictionary *)attachmentsData block:(NISendMailBlock)block;

@end
