//
//  CircularProgressViewController.h
//  HKCircularProgressView
//
//  Created by Eric Wang on 13-9-9.
//  Copyright (c) 2013年 Panos Baroudjian. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HKCircularProgressView;
@class HKConcentricProgressView;
@interface CircularProgressViewController : UIViewController

@property (weak, nonatomic) IBOutlet HKCircularProgressView *circularProgressView;
@property (weak, nonatomic) IBOutlet HKCircularProgressView *circularProgressView2;
@property (weak, nonatomic) IBOutlet HKCircularProgressView *circularProgressView3;
@property (weak, nonatomic) IBOutlet HKCircularProgressView *concentricProgressView;

@end
