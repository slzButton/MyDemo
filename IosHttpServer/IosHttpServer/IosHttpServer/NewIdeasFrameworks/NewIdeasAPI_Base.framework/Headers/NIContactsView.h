//
//  NIContactsView.h
//  联系人视图
//  Created by 　罗若文 on 16/4/11.
//  Copyright © 2016年 罗若文. All rights reserved.
//

#import <UIKit/UIKit.h>
//联系人
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#pragma mark - 回调
///回调
typedef void (^NIContactsBlock)(id result);

///获取联系人类
@interface NIContactsView : ABPeoplePickerNavigationController

///回调
@property(nonatomic,copy)NIContactsBlock block;

///初始化,回调中可以得到电话号码  用[self presentViewController:sm animated:YES completion:nil];方式打开
-(instancetype)init_block:(NIContactsBlock)block;
@end
