//
//  GCanvasPlugin.h
//  Pods
//
//  Created by Alibaba on 16/8/19.
//
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@protocol GCVImageLoaderProtocol;

@interface GCanvasPlugin : NSObject

- (void)setFrame:(CGRect)frame;

- (void)setFrame:(CGRect)frame withClearColor:(UIColor*)color;

- (void)addCommands:(NSArray*)commands;

- (void)execCommands;

- (void)removeCommands;

- (void)releaseManager;

- (void)addTextureId:(NSUInteger)tid withAppId:(NSUInteger)aid width:(NSUInteger)width height:(NSUInteger)height;

- (void)setImageLoader:(id<GCVImageLoaderProtocol>)loader;

- (void)setDevicePixelRatio:(double)ratio;

- (void)setContextType:(int)contextType;

- (void)setClearColor:(UIColor*)color;

@end
