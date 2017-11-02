/*===============================================================================
 Copyright (c) 2016 PTC Inc. All Rights Reserved.
 
 Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.
 
 Vuforia is a trademark of PTC Inc., registered in the United States and other
 countries.
 ===============================================================================*/
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Vuforia/Vuforia.h>
#import <Vuforia/Matrices.h>

@interface VuMarkUserData : NSObject

- (id)initWithUserData:(const char *) userData vuMarkSize:(CGSize) size;

- (NSUInteger) nbSegments;

- (void) modelViewMatrix:(Vuforia::Matrix44F&) modelViewMatrix forSegmentIdx:(int) idx width:(float) width;
- (void) modelViewMatrix:(Vuforia::Matrix44F &) modelViewMatrix forSegmentStart:(int) idx width:(float) width;

@end
