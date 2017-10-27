//
//  CLLocation+YCLocation.h
//


#import <CoreLocation/CoreLocation.h>

@interface CLLocation (YCLocation)

//从地图坐标转化到火星坐标
- (CLLocation*)locationMarsFromEarth;

//从火星坐标转化到百度坐标
- (CLLocation*)locationBaiduFromMars;

//从百度坐标到火星坐标
- (CLLocation*)locationMarsFromBaidu;

//从火星坐标到地图坐标
//- (CLLocation*)locationEarthFromMars; // 未实现

@end
