/*===============================================================================
Copyright (c) 2016-2017 PTC Inc. All Rights Reserved.

Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of PTC Inc., registered in the United States and other 
countries.
===============================================================================*/

#import "TextRecoViewController.h"
#import "VuforiaSamplesAppDelegate.h"
#import <Vuforia/Vuforia.h>
#import <Vuforia/TrackerManager.h>
#import <Vuforia/TextTracker.h>
#import <Vuforia/Trackable.h>
#import <Vuforia/DataSet.h>
#import <Vuforia/CameraDevice.h>

#import "UnwindMenuSegue.h"
#import "PresentMenuSegue.h"
#import "SampleAppMenuViewController.h"
#import "SampleApplicationUtils.h"

@interface TextRecoViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *ARViewPlaceholder;

@end

@implementation TextRecoViewController

@synthesize tapGestureRecognizer, vapp, eaglView;


- (CGRect)getCurrentARViewFrame
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGRect viewFrame = screenBounds;
    
    // If this device has a retina display, scale the view bounds
    // for the AR (OpenGL) view
    if (YES == vapp.isRetinaDisplay) {
        viewFrame.size.width *= [UIScreen mainScreen].nativeScale;
        viewFrame.size.height *= [UIScreen mainScreen].nativeScale;
    }
    return viewFrame;
}

- (void)loadView
{
    // Custom initialization
    self.title = @"Image Targets";
    
    if (self.ARViewPlaceholder != nil) {
        [self.ARViewPlaceholder removeFromSuperview];
        self.ARViewPlaceholder = nil;
    }
    
    flashEnabled = NO;
    
    vapp = [[SampleApplicationSession alloc] initWithDelegate:self];
    
    CGRect viewFrame = [self getCurrentARViewFrame];
    
    eaglView = [[TextRecoEAGLView alloc] initWithFrame:viewFrame appSession:vapp];
    [self setView:eaglView];
    VuforiaSamplesAppDelegate *appDelegate = (VuforiaSamplesAppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.glResourceHandler = eaglView;
    
    // double tap used to also trigger the menu
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(doubleTapGestureAction:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    
    // a single tap will trigger a single autofocus operation
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(autofocus:)];
    if (doubleTap != NULL) {
        [tapGestureRecognizer requireGestureRecognizerToFail:doubleTap];
    }
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureAction:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRight];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissARViewController)
                                                 name:@"kDismissARViewController"
                                               object:nil];

    // we use the iOS notification to pause/resume the AR when the application goes (or come back from) background
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(pauseAR)
     name:UIApplicationWillResignActiveNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(resumeAR)
     name:UIApplicationDidBecomeActiveNotification
     object:nil];

    // initialize AR
    [vapp initAR:Vuforia::GL_20 orientation:self.interfaceOrientation];

    // show loading animation while AR is being initialized
    [self showLoadingAnimation];
}

- (void) pauseAR {
    NSError * error = nil;
    if (![vapp pauseAR:&error]) {
        NSLog(@"Error pausing AR:%@", [error description]);
    }
}

- (void) resumeAR {
    NSError * error = nil;
    if(! [vapp resumeAR:&error]) {
        NSLog(@"Error resuming AR:%@", [error description]);
    }
    [eaglView updateRenderingPrimitives];
    // on resume, we reset the flash
    Vuforia::CameraDevice::getInstance().setFlashTorchMode(false);
    flashEnabled = NO;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.showingMenu = NO;
    
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    NSLog(@"self.navigationController.navigationBarHidden: %s", self.navigationController.navigationBarHidden ? "Yes" : "No");
}

- (void)viewWillDisappear:(BOOL)animated
{
    // on iOS 7, viewWillDisappear may be called when the menu is shown
    // but we don't want to stop the AR view in that case
    if (self.showingMenu) {
        return;
    }
    
    [vapp stopAR:nil];
    
    // Be a good OpenGL ES citizen: now that Vuforia is paused and the render
    // thread is not executing, inform the root view controller that the
    // EAGLView should finish any OpenGL ES commands
    [self finishOpenGLESCommands];
    
    VuforiaSamplesAppDelegate *appDelegate = (VuforiaSamplesAppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.glResourceHandler = nil;
    
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)finishOpenGLESCommands
{
    // Called in response to applicationWillResignActive.  Inform the EAGLView
    [eaglView finishOpenGLESCommands];
}

- (void)freeOpenGLESResources
{
    // Called in response to applicationDidEnterBackground.  Inform the EAGLView
    [eaglView freeOpenGLESResources];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - loading animation

- (void) showLoadingAnimation {
    CGRect indicatorBounds;
    CGRect mainBounds = [[UIScreen mainScreen] bounds];
    int smallerBoundsSize = MIN(mainBounds.size.width, mainBounds.size.height);
    int largerBoundsSize = MAX(mainBounds.size.width, mainBounds.size.height);
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown ) {
        indicatorBounds = CGRectMake(smallerBoundsSize / 2 - 12,
                                     largerBoundsSize / 2 - 12, 24, 24);
    }
    else {
        indicatorBounds = CGRectMake(largerBoundsSize / 2 - 12,
                                     smallerBoundsSize / 2 - 12, 24, 24);
    }
    
    UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc]
                                                  initWithFrame:indicatorBounds];
    
    loadingIndicator.tag  = 1;
    loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [eaglView addSubview:loadingIndicator];
    [loadingIndicator startAnimating];
}

- (void) hideLoadingAnimation {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIActivityIndicatorView *loadingIndicator = (UIActivityIndicatorView *)[eaglView viewWithTag:1];
        [loadingIndicator removeFromSuperview];
    });
}


#pragma mark - SampleApplicationControl

- (bool) doInitTrackers {
    // Initialize the text tracker
    Vuforia::TrackerManager& trackerManager = Vuforia::TrackerManager::getInstance();
    
    // Image Tracker...
    Vuforia::Tracker* trackerBase = trackerManager.initTracker(Vuforia::TextTracker::getClassType());
    if (trackerBase == NULL)
    {
        NSLog(@"Failed to initialize TextTracker.");
        return NO;
    }
    NSLog(@"Successfully initialized TextTracker.");
    return YES;
}

- (bool) doLoadTrackersData {
    Vuforia::TrackerManager& trackerManager = Vuforia::TrackerManager::getInstance();
    Vuforia::TextTracker* textTracker = static_cast<Vuforia::TextTracker*>(trackerManager.getTracker(Vuforia::TextTracker::getClassType()));
    
    if (NULL != textTracker) {
        Vuforia::WordList* wordList = textTracker->getWordList();
        NSString* wordListFile = @"Vuforia-English-word.vwl";
        // Load the word list
        if (false == wordList->loadWordList([wordListFile cStringUsingEncoding:NSASCIIStringEncoding], Vuforia::STORAGE_APPRESOURCE)) {
            NSLog(@"failed to load word list");
            return NO;
        }
    }
    else {
        NSLog(@"failed to get TEXT_TRACKER");
        return NO;
    }
    return YES;
}

- (bool) doStartTrackers {
    Vuforia::TrackerManager& trackerManager = Vuforia::TrackerManager::getInstance();
    Vuforia::Tracker* tracker = trackerManager.getTracker(Vuforia::TextTracker::getClassType());
    if (NULL != tracker) {
        if (true == tracker->start()) {
            NSLog(@"successfully started tracker");
        }
        else {
            NSLog(@"failed to start tracker");
            return NO;
        }
    }
    else {
        NSLog(@"failed to get the tracker from the tracker manager");
        return NO;
    }
    return YES;
}

- (void) prepareROI {
    // Get the default video mode
    Vuforia::CameraDevice& cameraDevice = Vuforia::CameraDevice::getInstance();
    Vuforia::VideoMode videoMode = cameraDevice.getVideoMode(Vuforia::CameraDevice::MODE_DEFAULT);
    
    [eaglView createTextOverlayView];
    
    // Text tracking region of interest
    CGRect viewFrame = [self getCurrentARViewFrame];
    int width = viewFrame.size.width;
    int height = viewFrame.size.height;
    
    Vuforia::Vec2I loupeCenter(0, 0);
    Vuforia::Vec2I loupeSize(0, 0);
    
    bool isIPad = NO;
    
    if (UIUserInterfaceIdiomPad == [[UIDevice currentDevice] userInterfaceIdiom]) {
        isIPad = YES;
    }
    
    // scale multiplier is used to prevent ROI border from
    // being hidden underneath transparent background
    CGFloat scale = [UIScreen mainScreen].nativeScale;
    
    // width of margin is:
    // 5% of the width of the screen for a phone
    // 20% of the width of the screen for a tablet
    int marginWidth = isIPad ? (width * 20) / 100 : (width * 5) / 100;
    
    // loupe height is:
    // 16% of the screen height for a phone
    // 10% of the screen height for a tablet
    int loupeHeight = isIPad ? (height * 10) / 100 - (scale * 2) : (height * 16) / 100 - (scale * 2);
    
    // lopue width takes the width of the screen minus 2 margins
    int loupeWidth = width - (2 * marginWidth);
    
    // Region of interest geometry
    ROICenterX = width / 2;
    ROICenterY = marginWidth + (loupeHeight / 2);
    ROIWidth = loupeWidth;
    ROIHeight = loupeHeight;
    
    // conversion to camera coordinates
    SampleApplicationUtils::screenCoordToCameraCoord(ROICenterX, ROICenterY, ROIWidth, ROIHeight,
                                                     width, height, videoMode.mWidth, videoMode.mHeight,
                                                     &loupeCenter.data[0], &loupeCenter.data[1], &loupeSize.data[0], &loupeSize.data[1]);
    
    [eaglView setRoiWidth:ROIWidth height:ROIHeight centerX:ROICenterX centerY:ROICenterY];
    
    Vuforia::TextTracker* textTracker = (Vuforia::TextTracker*)Vuforia::TrackerManager::getInstance().getTracker(Vuforia::TextTracker::getClassType());
    
    if (textTracker != 0)
    {
        Vuforia::RectangleInt roi(loupeCenter.data[0] - loupeSize.data[0] / 2, loupeCenter.data[1] - loupeSize.data[1] / 2, loupeCenter.data[0] + loupeSize.data[0] / 2, loupeCenter.data[1] + loupeSize.data[1] / 2);
        textTracker->setRegionOfInterest(roi, roi, Vuforia::TextTracker::REGIONOFINTEREST_UP_IS_9_HRS);
    }
}

- (void) onInitARDone:(NSError *)initError {
    [self hideLoadingAnimation];
    
    if (initError == nil) {
        NSError * error = nil;
        [vapp startAR:Vuforia::CameraDevice::CAMERA_DIRECTION_BACK error:&error];
        
        [eaglView updateRenderingPrimitives];
        
        [self performSelectorOnMainThread:@selector(prepareROI) withObject:nil waitUntilDone:YES];
    } else {
        NSLog(@"Error initializing AR:%@", [initError description]);
        
        dispatch_async( dispatch_get_main_queue(), ^{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[initError localizedDescription]
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        });
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kDismissARViewController" object:nil];
}

- (void)dismissARViewController
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)configureVideoBackgroundWithViewWidth:(float)viewWidth andHeight:(float)viewHeight
{
    [eaglView configureVideoBackgroundWithViewWidth:(float)viewWidth andHeight:(float)viewHeight];
}

- (void) onVuforiaUpdate: (Vuforia::State *) state {    
}

- (bool) doStopTrackers {
    // Stop the tracker
    Vuforia::TrackerManager& trackerManager = Vuforia::TrackerManager::getInstance();
    Vuforia::Tracker* tracker = trackerManager.getTracker(Vuforia::TextTracker::getClassType());
    
    if (NULL == tracker) {
        NSLog(@"ERROR: failed to get the tracker from the tracker manager");
        return NO;
    }
    tracker->stop();
    NSLog(@"successfully stopped tracker");
    return YES;
}

- (bool) doUnloadTrackersData {
    return YES;
}

- (bool) doDeinitTrackers {
    Vuforia::TrackerManager& trackerManager = Vuforia::TrackerManager::getInstance();
    trackerManager.deinitTracker(Vuforia::TextTracker::getClassType());
    return YES;
    
}

- (void)autofocus:(UITapGestureRecognizer *)sender
{
    [self performSelector:@selector(cameraPerformAutoFocus) withObject:nil afterDelay:.4];
}

- (void)cameraPerformAutoFocus
{
    Vuforia::CameraDevice::getInstance().setFocusMode(Vuforia::CameraDevice::FOCUS_MODE_TRIGGERAUTO);
}


- (void)doubleTapGestureAction:(UITapGestureRecognizer*)theGesture
{
    if (!self.showingMenu) {
        [self performSegueWithIdentifier: @"PresentMenu" sender: self];
    }
}

- (void)swipeGestureAction:(UISwipeGestureRecognizer*)gesture
{
    if (!self.showingMenu) {
        [self performSegueWithIdentifier:@"PresentMenu" sender:self];
    }
}


#pragma mark - menu delegate protocol implementation

- (BOOL) menuProcess:(NSString *)itemName value:(BOOL)value
{
    return false;
}

- (void) menuDidExit
{
    self.showingMenu = NO;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue isKindOfClass:[PresentMenuSegue class]]) {
        UIViewController *dest = [segue destinationViewController];
        if ([dest isKindOfClass:[SampleAppMenuViewController class]]) {
            self.showingMenu = YES;
            
            SampleAppMenuViewController *menuVC = (SampleAppMenuViewController *)dest;
            menuVC.menuDelegate = self;
            menuVC.sampleAppFeatureName = @"Text Reco";
            menuVC.dismissItemName = @"Vuforia Samples";
            menuVC.backSegueId = @"BackToTextReco";
        }
    }
}

@end
