//
//  GCVCommon.h
//  GCanvas
//
//  Created by Alibaba on 16/7/29.
//  Copyright © 2016年 alibaba. All rights reserved.
//
#ifndef GCVLog_h
#define GCVLog_h

#import <Foundation/Foundation.h>


#pragma mark - LOG begin


#ifdef DEBUG
#define ENABLE_GCVLOG
#endif

#define GCVLOG_UNDO(...)

#ifdef ENABLE_GCVLOG
#define GCVLOG_METHOD GCVLOG_D
#define GCVLOG_METHOD_LIMIT(count, fmt, ...) {static int limit = count; if (limit-- > 0) {GCVLOG_METHOD(fmt, __VA_ARGS__)}};
#define GCVLOG_LINE GCVLOG_METHOD(@"[line:%d] ", __LINE__);
#define GCVLOG_BEGIN GCVLOG_METHOD(@"begin>>>");
#define GCVLOG_END   GCVLOG_METHOD(@"end<<<");
#define VS_CHECKGL {GLint error = glGetError(); if (error) { GCVLOG_METHOD(@"glerror=(0x%x)", error)}}

#define GCVLOG_FUNC(level, fmt, ...) [GCVLog writeLog:level funcName:__FUNCTION__ format:fmt, ##__VA_ARGS__];
#define GCVLOG_D(fmt, ...) GCVLOG_FUNC(GCVLogLevelDebug, fmt, ##__VA_ARGS__);
#define GCVLOG_I(fmt, ...) GCVLOG_FUNC(GCVLogLevelInfo, fmt, ##__VA_ARGS__);
#define GCVLOG_W(fmt, ...) GCVLOG_FUNC(GCVLogLevelWarn, fmt, ##__VA_ARGS__);
#define GCVLOG_E(fmt, ...) GCVLOG_FUNC(GCVLogLevelError, fmt, ##__VA_ARGS__);
#else
#define GCVLOG_METHOD(...)
#define GCVLOG_METHOD_LIMIT
#define GCVLOG_LINE
#define GCVLOG_BEGIN
#define GCVLOG_END
#define VS_CHECKGL

#define GCVLOG_D(...)
#define GCVLOG_I(...)
#define GCVLOG_W(...)
#define GCVLOG_E(...)
#endif


typedef NS_ENUM(NSInteger, GCVLogLevel) {
    GCVLogLevelDebug = 0,
    GCVLogLevelInfo,
    GCVLogLevelWarn,
    GCVLogLevelError
};

extern int g_GCVLOG_LEVEL;//0-debug;1-info;2-warn;3-error; default is debug;


#pragma mark - LOG end

@interface GCVLog : NSObject


+ (void) writeLog:(GCVLogLevel)logLevel funcName:(const char *)funcName format: (NSString *)fmt, ...;
@end



#endif /* GCVLog_h */


