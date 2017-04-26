//
//  NIDes3Util.h
//  
//  加密算法
//  Created by 　罗若文 on 15/11/3.
//  Copyright © 2015年 罗若文. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIDrviceUtil.h"

#define NIgIv [NIDrviceUtil readSettingsPlist:@"DESede" key:@"DESede_initVec"]
#define NIDESede_KEY [NIDrviceUtil readSettingsPlist:@"DESede"  key:@"DESede_KEY"]

///des3加密算法
@interface NIDes3Util : NSObject

/// 加密方法
+ (NSString*)encrypt:(NSString*)plainText;

/// 解密方法
+ (NSString*)decrypt:(NSString*)encryptText;

@end
