/*===============================================================================
Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of PTC Inc., registered in the United States and other 
countries.
===============================================================================*/


#import <UIKit/UIKit.h>

//  Custom button that contains an UIImageView on its center and can be rotated
//  given a UIDeviceOrientation. This class is used on CustomToolbar in order to
//  mimic the iOS camera screen.

@interface CustomButton : UIButton

@property (strong) UIImageView *customImageView;

-(void)rotateWithOrientation:(UIDeviceOrientation)anOrientation;
-(void)setCustomImage:(UIImage *)anImage;

@end
