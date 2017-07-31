//
//  GCVFont.h
//  GCanvas
//
//  Created by Alibaba on 16/10/27.
//  Copyright © 2016年 alibaba. All rights reserved.
//
#ifndef GCVCommonDef_h
#define GCVCommonDef_h
//该文件的作用是为了让cpp和m文件都可以引用，避免将所有文件都改成mm


typedef enum {
    kEJTextBaselineAlphabetic = 0, // for Western fonts: Default. The text baseline is the normal alphabetic baseline
    kEJTextBaselineMiddle, // The text baseline is the middle of the em square
    kEJTextBaselineTop, // The text baseline is the top of the em square
    kEJTextBaselineHanging, // for Indian fonts : The text baseline is the hanging baseline
    kEJTextBaselineBottom,  // The text baseline is the bottom of the bounding box
    kEJTextBaselineIdeographic // for CJK fonts: The text baseline is the ideographic baseline
} EJTextBaseline;

typedef enum {
    kEJTextAlignStart = 0, // Default. The text baseline is the normal alphabetic baseline
    kEJTextAlignEnd, // The text ends at the specified position
    kEJTextAlignLeft, // The text starts at the specified position
    kEJTextAlignCenter, // The center of the text is placed at the specified position
    kEJTextAlignRight // The text ends at the specified position
} EJTextAlign;

#endif /* GCVCommonDef_h */


