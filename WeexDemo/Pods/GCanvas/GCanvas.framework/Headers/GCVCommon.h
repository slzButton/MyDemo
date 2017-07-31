//
//  GCVCommon.h
//  GCanvas
//
//  Created by Alibaba on 16/7/29.
//  Copyright © 2016年 alibaba. All rights reserved.
//
#ifndef GCVCommon_h
#define GCVCommon_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <CoreText/CoreText.h>
#import "GCVLog.h"


#define GCVWeakSelf    __weak __typeof(self) weakSelf = self;
#define GCVStrongSelf  __strong __typeof(weakSelf) strongSelf = weakSelf;
#define GCVStrongSelfSafe  GCVStrongSelf;if (!strongSelf) return;


#define GCVSharedInstanceIMP \
static id sharedInstance = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
sharedInstance = [[self alloc] init]; \
}); \
return sharedInstance;

//图片下载
typedef void(^GCVLoadImageCompletion)(UIImage *image, NSError *error, BOOL finished, NSURL *imageURL);
@protocol GCVImageLoaderProtocol
- (void)loadImage:(NSURL*)url completed:(GCVLoadImageCompletion)completion;
@end


@interface GCVImageCache : NSObject
@property(nonatomic, strong) UIImage* image;
@property(nonatomic, assign) GLuint textureId;
@end


@interface GCVCommon : NSObject

@property(nonatomic, weak) id<GCVImageLoaderProtocol> imageLoader;

+ (instancetype)sharedInstance;

+ (GLuint)bindTexture:(UIImage *)image;

+ (void)textImage2D:(GLenum)target withImage:(UIImage *)image;

- (void)addPreLoadImage:(NSString *)imageStr completion:(void (^)(GCVImageCache*))completion;

- (GCVImageCache *)fetchLoadImage:(NSString *)imageStr;

- (void)clearLoadImageDict;

- (BOOL)hadPreLoadImage;


@end


#endif /* GCVCommon_h */


