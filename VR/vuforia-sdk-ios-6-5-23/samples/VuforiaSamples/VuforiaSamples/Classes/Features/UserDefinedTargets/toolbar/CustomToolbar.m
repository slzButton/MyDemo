/*===============================================================================
Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.
 
Confidential and Proprietary - Qualcomm Connected Experiences, Inc.
Vuforia is a trademark of PTC Inc., registered in the United States and other 
countries.
===============================================================================*/


#import "CustomToolbar.h"

#define CANCELBUTTON_LEFTMARGIN 10
#define CANCELBUTTON_HEIGHT 32
#define CANCELBUTTON_WIDTH 62

#define ACTIONBUTTON_HEIGHT 42
#define ACTIONBUTTON_WIDTH 100

@implementation CustomToolbar

@synthesize delegate, shouldRotateActionButton;
@synthesize backgroundImageView;
@synthesize cancelButton;
@synthesize actionButton;
@synthesize actionImage;

#pragma mark - Private

-(void)addBackground
{
    UIImage *backgroundImage = [UIImage imageNamed:@"custom_toolbar_texture.png"];
    backgroundImage = [backgroundImage stretchableImageWithLeftCapWidth:0 topCapHeight:0];

    CGRect backgrounImageViewFrame = CGRectMake(0,
                                                0,
                                                self.frame.size.width,
                                                self.frame.size.height);
    backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    backgroundImageView.frame = backgrounImageViewFrame;
    [self addSubview:backgroundImageView];
}

-(void)addCancelButton
{
    CGRect cancelButtonFrame = CGRectMake(CANCELBUTTON_LEFTMARGIN,
                                          (self.frame.size.height - CANCELBUTTON_HEIGHT)/2,
                                          CANCELBUTTON_WIDTH,
                                          CANCELBUTTON_HEIGHT);
    
    cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = cancelButtonFrame;
    
    //  Set title
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateHighlighted];
    
    //  Set font
    cancelButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    cancelButton.titleLabel.shadowColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.8];
    cancelButton.titleLabel.shadowOffset = CGSizeMake(1, 1);
    cancelButton.hidden = YES;
    
    //  Set background on normal state
    UIImage *backgroundImageNormal = [UIImage imageNamed:@"button_cancel.png"];
    backgroundImageNormal = [backgroundImageNormal stretchableImageWithLeftCapWidth:5 topCapHeight:5];
    [cancelButton setBackgroundImage:backgroundImageNormal forState:UIControlStateNormal];
    
    //  Set background on highlight state
    UIImage *backgroundImageHighlighted = [UIImage imageNamed:@"button_cancel_pressed.png"];
    backgroundImageHighlighted = [backgroundImageHighlighted stretchableImageWithLeftCapWidth:5 topCapHeight:5];
    [cancelButton setBackgroundImage:backgroundImageHighlighted forState:UIControlStateHighlighted];
    
    //  Set action
    [cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:cancelButton];
}

-(void)addActionButton
{
    CGRect actionButtonFrame = CGRectMake((self.frame.size.width - ACTIONBUTTON_WIDTH)/2,
                                          (self.frame.size.height - ACTIONBUTTON_HEIGHT)/2,
                                          ACTIONBUTTON_WIDTH,
                                          ACTIONBUTTON_HEIGHT);
    
    actionButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    actionButton.frame = actionButtonFrame;
    
    UIImage *backgroundImage = [UIImage imageNamed:@"button_main.png"];
    backgroundImage = [backgroundImage stretchableImageWithLeftCapWidth:20 topCapHeight:18];
    [actionButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];

    UIImage *addImage = [UIImage imageNamed:@"icon_camera.png"];
    [actionButton setCustomImage:addImage];
    
    [actionButton addTarget:self action:@selector(actionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:actionButton];    
}

#pragma mark - Notifications

-(void)orientationDidChange:(NSNotification *)aNotification
{
    //  It only rotates if you set shouldRotateActionButton property to YES
    if (shouldRotateActionButton)
    {
        [actionButton rotateWithOrientation:[[UIDevice currentDevice] orientation]];
    }
}

#pragma mark - Properties

-(void)setIsCancelButtonHidden:(BOOL)isCancelButtonHidden
{
    cancelButton.hidden = isCancelButtonHidden;
}

-(BOOL)isCancelButtonHidden
{
    return cancelButton.hidden;
}

-(UIImage *)actionImage
{
    return actionImage;
}

-(void)setActionImage:(UIImage *)newActionImage
{
    if (actionImage != newActionImage)
    {
        actionImage = newActionImage;
        [actionButton setCustomImage:actionImage];
    }
}

#pragma mark - Actions

-(void)cancelButtonPressed:(id)sender
{
    NSLog(@"#DEBUG cancelButtonPressed");
    [delegate cancelButtonWasPressed];
}

-(void)actionButtonPressed:(id)sender
{
    [delegate actionButtonWasPressed];
}

#pragma mark - Public

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        //  Add toolbar texture
        [self addBackground];
        
        //  Add Cancel button
        [self addCancelButton];
        
        //  Add Action button
        [self addActionButton];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationDidChange:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
