//
//  GCVFont.h
//  GCanvas
//
//  Created by Alibaba on 16/10/27.
//  Copyright © 2016年 alibaba. All rights reserved.
//
#ifndef GCVFont_h
#define GCVFont_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <CoreText/CoreText.h>
#import "GCVLog.h"
#include "GCVCommonDef.h"


typedef struct {
    float x, y, w, h;
    unsigned short textureIndex;
    float tx, ty, tw, th;
} EJFontGlyphInfo;


typedef struct {
    unsigned short textureIndex;
    CGGlyph glyph;
    float xpos;
    EJFontGlyphInfo *info;
} EJFontGlyphLayout;

typedef struct {
    float width;
    float ascent;
    float descent;
} EJTextMetrics;


@interface EJFontLayout : NSObject
@property (nonatomic, strong) NSData *glyphLayout;
@property (nonatomic, assign) EJTextMetrics metrics;
@property (nonatomic, assign) NSInteger glyphCount;
@end



@interface GCVFont : NSObject 


+ (instancetype)sharedInstance;

- (void)resetWithFontStyle:(const char *)fontStyle isStroke:(BOOL)isStroke;

- (EJFontLayout *)getLayoutForString:(NSString *)string;

- (unsigned short)createGlyph:(CGGlyph)glyph
                     withFont:(CTFontRef)font
                    glyphInfo:(EJFontGlyphInfo *)glyphInfo;

-(CGPoint)adjustTextPenPoint:(CGPoint)srcPoint
                   textAlign:(EJTextAlign)textAlign
                    baseLine:(EJTextBaseline)baseLine
                     metrics:(EJTextMetrics)metrics;

@end

#endif /* GCVFont_h */


