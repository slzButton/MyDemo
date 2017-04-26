//
//  NIKeyChain.h
//  存放系统属性.基本固定的
//  keychain的使用
//  Security.framework
//  Created by 　罗若文 on 15/11/15.
//  Copyright © 2015年 罗若文. All rights reserved.
//

#import <Foundation/Foundation.h>

///keychain的使用
@interface NIKeyChain : NSObject

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service ;

+ (void)save:(NSString *)service data:(id)data ;

+ (id)load:(NSString *)service;

+ (void)delete:(NSString *)service;

@end
