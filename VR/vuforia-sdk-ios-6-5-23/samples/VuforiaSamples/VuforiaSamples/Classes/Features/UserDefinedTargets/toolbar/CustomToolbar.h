/*===============================================================================
Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of PTC Inc., registered in the United States and other 
countries.
===============================================================================*/


#import <UIKit/UIKit.h>
#import "CustomToolbarDelegateProtocol.h"
#import "CustomButton.h"

//  CustomToolbar is used to mimic the iOS camera screen.
//  It contains a cancelButton that can be hidden and an actionImage that rotates according to
//  the device orientation. To get feedback from the buttons tapped you have to set a delegate that
//  implements CustomToolbarDelegateProtocol

@interface CustomToolbar : UIView

@property (strong) CustomButton *actionButton;
@property (strong) UIButton *cancelButton;
@property (strong) UIImageView *backgroundImageView;
@property (strong) UIImage *actionImage;
@property (weak) id <CustomToolbarDelegateProtocol> delegate;
@property (assign) BOOL isCancelButtonHidden;
@property (assign) BOOL shouldRotateActionButton;

@end
