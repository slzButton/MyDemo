/*===============================================================================
 Copyright (c) 2016 PTC Inc. All Rights Reserved.
 
 Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.
 
 Vuforia is a trademark of PTC Inc., registered in the United States and other
 countries.
 ===============================================================================*/
#import "VuMarkUserData.h"
#define NANOSVG_IMPLEMENTATION 1
#import "nanosvg.h"
#import "SampleApplicationUtils.h"

@interface UserDataPoint : NSObject
@property (nonatomic, readwrite) CGFloat x;
@property (nonatomic, readwrite) CGFloat y;
@end

@implementation UserDataPoint
@end


@interface UserDataSegment : NSObject
@property (nonatomic, readwrite) UserDataPoint * p0;
@property (nonatomic, readwrite) UserDataPoint * p1;
@property (nonatomic, readwrite) UserDataPoint * center;
@property (nonatomic, readwrite) CGFloat angle;
@property (nonatomic, readwrite) CGFloat length;

- (void) prepare;
@end

@implementation UserDataSegment

- (void) prepare {
    UserDataPoint * center = [[UserDataPoint alloc]init];
    center.x = (self.p1.x + self.p0.x) / 2;
    center.y = (self.p1.y + self.p0.y) / 2;
    self.center = center;
    
    self.angle = atan2f(self.p1.y - self.p0.y, self.p1.x - self.p0.x);
    self.angle = self.angle / M_PI * 180.0;
    
    CGFloat xDist = (self.p1.x - self.p0.x);
    CGFloat yDist = (self.p1.y - self.p0.y);
    self.length= sqrt((xDist * xDist) + (yDist * yDist));
    
//    self.length = hypotf(self.p1.x - self.p0.x, self.p1.y - self.p0.y);
}

@end


@interface VuMarkUserData ()

@property (nonatomic, readwrite) NSMutableArray * segments;

@end


@implementation VuMarkUserData

- (id)initWithUserData:(const char *) userData vuMarkSize:(CGSize) size {
    self = [super init];
    
    NSLog(@"userData:%s\n", userData);
    
    if (self) {
        _segments = [[NSMutableArray alloc]init];
        
        NSVGimage * image;
        NSVGshape* shape;
        NSVGpath* path;
        
        image = nsvgParse((char *)userData, "px", 96);
        NSLog(@"size: %f x %f\n", image->width, image->height);
        
        for (shape = image->shapes; shape != NULL; shape = shape->next) {
            for (path = shape->paths; path != NULL; path = path->next) {
                for (int i = 0; i < path->npts  - 1; i += 3) {
                    float* p = &path->pts[i*2];
                    // NSLog(@"(%d) p[%d] %7.2f, %7.2f, %7.2f, %7.2f, %7.2f, %7.2f, %7.2f, %7.2f",path->closed, i, p[0],p[1], p[2],p[3], p[4],p[5], p[6],p[7]);
                    
                    UserDataPoint * p0 = [self mkUserDataPointWithP0:p[0] P1:p[1] inImage:image vuMarkSize:size];
                    UserDataPoint * p1 = [self mkUserDataPointWithP0:p[6] P1:p[7] inImage:image vuMarkSize:size];

                    UserDataSegment * segment = [[UserDataSegment alloc]init];
                    segment.p0 = p0;
                    segment.p1 = p1;
                    [segment prepare];
                    [_segments addObject:segment];
                }
            }
        }
        nsvgDelete(image);
    }
    return self;
}

- (UserDataPoint *) mkUserDataPointWithP0:(float) p0 P1:(float) p1 inImage:(NSVGimage *) image vuMarkSize:(CGSize) size{
    float x = p0 - (image->width / 2.0);
    float y = (image->height /2.0)- p1;
    
    UserDataPoint * point = [[UserDataPoint alloc]init];
    point.x = (x / image->width) * size.width;
    point.y = (y / image->height) * size.height;
    
    return point;
}

- (NSUInteger) nbSegments {
    return [_segments count];
}

// we build the model view matric for the segment (streched square)
- (void) modelViewMatrix:(Vuforia::Matrix44F &) modelViewMatrix forSegmentIdx:(int) idx width:(float) width{
    UserDataSegment * segment = (UserDataSegment *)[_segments objectAtIndex:idx];
    UserDataPoint * point = segment.center;
    
    SampleApplicationUtils::translatePoseMatrix(point.x, point.y, 0.0,
                                                &modelViewMatrix.data[0]);
    SampleApplicationUtils::rotatePoseMatrix(segment.angle, 0.0, 0.0, 1.0,
                                             &modelViewMatrix.data[0]);
    
    SampleApplicationUtils::scalePoseMatrix(segment.length, width, width,
                         &modelViewMatrix.data[0]);
}

// we build the model view matrix for the starting point of the segment (sphere)
- (void) modelViewMatrix:(Vuforia::Matrix44F &) modelViewMatrix forSegmentStart:(int) idx width:(float) width{
    UserDataSegment * segment = (UserDataSegment *)[_segments objectAtIndex:idx];
    UserDataPoint * point = segment.p0;
    
    SampleApplicationUtils::translatePoseMatrix(point.x, point.y, 0.0,
                                                &modelViewMatrix.data[0]);
    SampleApplicationUtils::scalePoseMatrix(width, width, width,
                                            &modelViewMatrix.data[0]);
    
}

@end


