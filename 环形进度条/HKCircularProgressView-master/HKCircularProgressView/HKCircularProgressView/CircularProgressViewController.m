//
//  CircularProgressViewController.m
//  HKCircularProgressView
//
//  Created by Eric Wang on 13-9-9.
//  Copyright (c) 2013年 Panos Baroudjian. All rights reserved.
//

#import "CircularProgressViewController.h"
#import "HKCircularProgressView.h"
#import <QuartzCore/QuartzCore.h>

@interface CircularProgressViewController ()
@end

@implementation CircularProgressViewController

+ (void)addShadowToView:(UIView *)view
{
    [[view layer] setShadowOffset:CGSizeMake(0, -1)];
    [[view  layer] setShadowColor:[[UIColor darkGrayColor] CGColor]];
    [[view  layer] setShadowRadius:1.0f];
    [[view  layer] setShadowOpacity:0.75f];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.circularProgressView.progressTintColor = [UIColor cyanColor];
    self.circularProgressView.max = 1.0f;
    self.circularProgressView.fillRadiusPx = 25;
    self.circularProgressView.step = 0.1f;
    self.circularProgressView.startAngle = (M_PI * 3) * 0.5;
    self.circularProgressView.translatesAutoresizingMaskIntoConstraints = NO;
    self.circularProgressView.outlineWidth = 1;
    self.circularProgressView.outlineTintColor = [UIColor blackColor];
    self.circularProgressView.endPoint = [[HKCircularProgressEndPointSpike alloc] init];
    
    self.circularProgressView2.animationDuration = 5.0f;
    self.circularProgressView2.fillRadiusPx = 25;
    self.circularProgressView2.progressTintColor = [UIColor magentaColor];
    self.circularProgressView2.translatesAutoresizingMaskIntoConstraints = NO;
    self.circularProgressView2.endPoint = [[HKCircularProgressEndPointRound alloc] init];
    
    self.circularProgressView3.fillRadius = 1;
    self.circularProgressView3.progressTintColor = [UIColor yellowColor];
    self.circularProgressView3.translatesAutoresizingMaskIntoConstraints = NO;
    
    [CircularProgressViewController addShadowToView:self.circularProgressView];
    
    self.concentricProgressView.max = 150;
    self.concentricProgressView.concentricStep = 60;
    self.concentricProgressView.concentricGap = .25;
    self.concentricProgressView.gap = .25;
    self.concentricProgressView.step = 5;
    self.concentricProgressView.progressTintColor = [UIColor cyanColor];
    self.concentricProgressView.outlineTintColor = [UIColor blackColor];
    self.concentricProgressView.outlineWidth = 1;
    self.concentricProgressView.concentricProgressionType = HKConcentricProgressionTypeExcentric;
    
    [[HKCircularProgressView appearance] setAnimationDuration:5];
    
    self.circularProgressView.alwaysDrawOutline = YES;
    self.concentricProgressView.alwaysDrawOutline = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.circularProgressView setCurrent:0.6f
                                 animated:YES];
    [self.circularProgressView2 setCurrent:1.0f
                                  animated:YES];
    [self.circularProgressView3 setCurrent:0.7f
                                  animated:YES];
    [self.concentricProgressView setCurrent:150
                                   animated:YES];
}

- (void)viewDidUnload {
    [self setCircularProgressView2:nil];
    [self setCircularProgressView3:nil];
    [self setCircularProgressView:nil];
    [self setConcentricProgressView:nil];
    [super viewDidUnload];
}
@end
