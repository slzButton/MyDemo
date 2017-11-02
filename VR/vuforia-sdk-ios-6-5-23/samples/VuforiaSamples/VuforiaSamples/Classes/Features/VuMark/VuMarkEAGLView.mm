/*===============================================================================
Copyright (c) 2016 PTC Inc. All Rights Reserved.

Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of PTC Inc., registered in the United States and other 
countries.
===============================================================================*/

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <sys/time.h>

#import <Vuforia/Vuforia.h>
#import <Vuforia/State.h>
#import <Vuforia/Tool.h>
#import <Vuforia/Renderer.h>
#import <Vuforia/TrackableResult.h>
#import <Vuforia/VideoBackgroundConfig.h>

#import <Vuforia/VuMarkTemplate.h>
#import <Vuforia/VuMarkTarget.h>
#import <Vuforia/VuMarkTargetResult.h>

#import "VuMarkEAGLView.h"
#import "Texture.h"
#import "SampleApplicationUtils.h"
#import "SampleApplicationShaderUtils.h"
#import "Teapot.h"
#import "VuMarkUserData.h"

//******************************************************************************
// *** OpenGL ES thread safety ***
//
// OpenGL ES on iOS is not thread safe.  We ensure thread safety by following
// this procedure:
// 1) Create the OpenGL ES context on the main thread.
// 2) Start the Vuforia camera, which causes Vuforia to locate our EAGLView and start
//    the render thread.
// 3) Vuforia calls our renderFrameVuforia method periodically on the render thread.
//    The first time this happens, the defaultFramebuffer does not exist, so it
//    is created with a call to createFramebuffer.  createFramebuffer is called
//    on the main thread in order to safely allocate the OpenGL ES storage,
//    which is shared with the drawable layer.  The render (background) thread
//    is blocked during the call to createFramebuffer, thus ensuring no
//    concurrent use of the OpenGL ES context.
//
//******************************************************************************


namespace {
    // --- Data private to this unit ---

    // Teapot texture filenames
    const char* textureFilenames[] = {
        "vumark_texture.png"
    };
    
    // --- Data private to this unit ---
    double t0 = -1.0f;
    
    float vumarkBorderSize;
    
    const int NUM_OBJECT_INDEX=6; //2 triangles
    
    static const float frameVertices[4 * 3] =
    {
        -0.5f,-0.5f,0.f,
        0.5f,-0.5f,0.f,
        0.5f,0.5f,0.f,
        -0.5f,0.5f,0.f,
    };
    
    static const unsigned short frameIndices[NUM_OBJECT_INDEX] =
    {
        0,1,2, 2,3,0
    };
    
    static const int CIRCLE_NB_VERTICES = 18;
    static float circleVertices[CIRCLE_NB_VERTICES * 3] = {};
    
    
    static UIColor * COLOR_LABEL = [UIColor colorWithRed:170.0f/255.0f green:170.0f/255.0f blue:170.0f/255.0f alpha:1.0f];
    static UIColor * COLOR_ID = [UIColor colorWithRed:74.0f/255.0f green:74.0f/255.0f blue:74.0f/255.0f alpha:1.0f];
    static UIColor * GREEN_COLOR = [UIColor colorWithRed:0.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.8f];
    
    static VuMarkUserData * userData;
}


@interface VuMarkEAGLView (PrivateMethods)

- (void)initShaders;
- (void)createFramebuffer;
- (void)deleteFramebuffer;
- (void)setFramebuffer;
- (BOOL)presentFramebuffer;
- (void)createReticleOverlayView;
- (void)createCardOverlayView;

- (NSString *) convertInstanceIdToHexString:(const Vuforia::InstanceId&) vuMarkId;

@end


@implementation VuMarkEAGLView

@synthesize vapp = vapp;

// You must implement this method, which ensures the view's underlying layer is
// of type CAEAGLLayer
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

#define DEGREES_TO_RADIANS(x) (M_PI * x / 180.0)

- (void) prepareCircleVertices {
    float angleDelta = 360.0 / CIRCLE_NB_VERTICES;
    
    for (int index = 0; index < CIRCLE_NB_VERTICES; index ++) {
        int i = index * 3;
        circleVertices[i]   = (cos(DEGREES_TO_RADIANS(index * angleDelta)) * 0.5);
        circleVertices[i+1] = (sin(DEGREES_TO_RADIANS(index * angleDelta)) * 0.5);
        circleVertices[i+2] = 0.0f;
    }
}
//------------------------------------------------------------------------------
#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame appSession:(SampleApplicationSession *) app
{
    self = [super initWithFrame:frame];
    
    if (self) {
        vapp = app;
        // Enable retina mode if available on this device
        if (YES == [vapp isRetinaDisplay]) {
            [self setContentScaleFactor:[UIScreen mainScreen].nativeScale];
        }
        
        // Load the augmentation textures
        for (int i = 0; i < kNumAugmentationTextures; ++i) {
            augmentationTexture[i] = [[Texture alloc] initWithImageFile:[NSString stringWithCString:textureFilenames[i] encoding:NSASCIIStringEncoding]];
        }

        // Create the OpenGL ES context
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
        // The EAGLContext must be set for each thread that wishes to use it.
        // Set it the first time this method is called (on the main thread)
        if (context != [EAGLContext currentContext]) {
            [EAGLContext setCurrentContext:context];
        }
        
        sampleAppRenderer = [[SampleAppRenderer alloc] initWithSampleAppRendererControl:self deviceMode:Vuforia::Device::MODE_AR stereo:false nearPlane:.01 farPlane:100.0];
        
        // Generate the OpenGL ES texture and upload the texture data for use
        // when rendering the augmentation
        for (int i = 0; i < kNumAugmentationTextures; ++i) {
            GLuint textureID;
            glGenTextures(1, &textureID);
            [augmentationTexture[i] setTextureID:textureID];
            glBindTexture(GL_TEXTURE_2D, textureID);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, [augmentationTexture[i] width], [augmentationTexture[i] height], 0, GL_RGBA, GL_UNSIGNED_BYTE, (GLvoid*)[augmentationTexture[i] pngData]);
        }

        offTargetTrackingEnabled = NO;
        
        [self initShaders];
        
        [self createReticleOverlayView];
        [self createCardOverlayView];
        [self prepareCircleVertices];
        cardViewVisible = false;
        currentVumarkIdOnCard = nil;
        
        [sampleAppRenderer initRendering];
    }
    
    return self;
}


- (void)dealloc
{
    [self deleteFramebuffer];
    
    // Tear down context
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }

    for (int i = 0; i < kNumAugmentationTextures; ++i) {
        augmentationTexture[i] = nil;
    }

    userData = nil;
}


- (void)finishOpenGLESCommands
{
    // Called in response to applicationWillResignActive.  The render loop has
    // been stopped, so we now make sure all OpenGL ES commands complete before
    // we (potentially) go into the background
    if (context) {
        [EAGLContext setCurrentContext:context];
        glFinish();
    }
}


- (void)freeOpenGLESResources
{
    // Called in response to applicationDidEnterBackground.  Free easily
    // recreated OpenGL ES resources
    [self deleteFramebuffer];
    glFinish();
}

- (void) setOffTargetTrackingMode:(BOOL) enabled {
    offTargetTrackingEnabled = enabled;
}

- (double) getCurrentTime {
    static struct timeval tv;
    gettimeofday(&tv, NULL);
    double t = tv.tv_sec + tv.tv_usec/1000000.0;
    return t;
}

- (float) blinkVumark:(bool) reset {
    if (reset || t0 < 0.0f) {
        t0 = [self getCurrentTime];
    }
    if (reset) {
        return 0.0f;
    }
    double time = [self getCurrentTime];
    double delta = (time-t0);
    
    if (delta > 1.0) {
        return 1.0;
    }
    
    if ((delta < 0.3) || ((delta > 0.5) && (delta < 0.8))) {
        return 1.0;
    }
    
    return 0.0;
}


- (void) updateRenderingPrimitives
{
    [sampleAppRenderer updateRenderingPrimitives];
}


//------------------------------------------------------------------------------
#pragma mark - UIGLViewProtocol methods

// Draw the current frame using OpenGL
//
// This method is called by Vuforia when it wishes to render the current frame to
// the screen.
//
// *** Vuforia will call this method periodically on a background thread ***
- (void)renderFrameVuforia
{
    if (! vapp.cameraIsStarted) {
        return;
    }
    
    [sampleAppRenderer renderFrameVuforia];
}


- (void)renderFrameWithState:(const Vuforia::State &)state projectMatrix:(Vuforia::Matrix44F &)projectionMatrix
{
    [self setFramebuffer];
    
    // Clear colour and depth buffers
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Render video background and retrieve tracking state
    [sampleAppRenderer renderVideoBackground];
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    // We disable depth testing for rendering translucent augmentations;
    // note: for opaque 3D object rendering, depth testing should typically be enabled.
    glDisable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    
    
    int indexVuMarkToDisplay = -1;
    
    if (state.getNumTrackableResults() > 1) {
        CGFloat minimumDistance = FLT_MAX;
        const Vuforia::CameraCalibration& cameraCalibration = Vuforia::CameraDevice::getInstance().getCameraCalibration();
        const Vuforia::Vec2F screenSize = cameraCalibration.getSize();
        const Vuforia::Vec2F screenCenter = Vuforia::Vec2F(screenSize.data[0] / 2.0f, screenSize.data[1] / 2.0f);
        
        for (int i = 0; i < state.getNumTrackableResults(); ++i) {
            // Get the trackable
            const Vuforia::TrackableResult* result = state.getTrackableResult(i);
            
            if (result->isOfType(Vuforia::VuMarkTargetResult::getClassType()))
            {
                Vuforia::Vec3F point = Vuforia::Vec3F(0.0, 0.0, 0.0);
                
                Vuforia::Vec2F projection = Vuforia::Tool::projectPoint(cameraCalibration, result->getPose(), point);
                
                CGFloat distance = [self distanceSquared:projection to:screenCenter];
                
                if (distance < minimumDistance) {
                    minimumDistance = distance;
                    indexVuMarkToDisplay = i;
                }
            }
        }
        
    }

    bool gotVuMark = false;
    
    for (int i = 0; i < state.getNumTrackableResults(); ++i) {
        // Get the trackable
        const Vuforia::TrackableResult* result = state.getTrackableResult(i);
        
        if (result->isOfType(Vuforia::VuMarkTargetResult::getClassType()))
        {
            // this boolean teels if the current VuMrk is the 'main' one i.w the one closest to the center or the only one
            bool isMainVumark = ((indexVuMarkToDisplay < 0) || (indexVuMarkToDisplay == i));
            
            const Vuforia::VuMarkTargetResult* vmtResult = static_cast< const Vuforia::VuMarkTargetResult*>(result);
            const Vuforia::VuMarkTarget& vmtar = vmtResult->getTrackable();
            const Vuforia::VuMarkTemplate& vmtmp = vmtar.getTemplate();
            const Vuforia::InstanceId& instanceId = vmtar.getInstanceId();
            
            // we initialize the user data structure with this first VuMark
            if (! userData) {
                CGFloat width = vmtar.getSize().data[0];
                CGFloat height = vmtar.getSize().data[1];
                vumarkBorderSize = width / 32.0;
                userData = [[VuMarkUserData alloc]initWithUserData:vmtmp.getVuMarkUserData() vuMarkSize:CGSizeMake(width, height)];
            }
            
            gotVuMark = true;
            
            if (isMainVumark) {
                NSString * vumarkIdValue = [self convertInstanceIdToString:instanceId];
                NSString * vumarkIdType = [self getInstanceIdType:instanceId];
                
                NSLog(@"[%@] : %@", vumarkIdType, vumarkIdValue);
                
                // if the vumark has changed, we hide the card
                // and reset the animation
                if (! [vumarkIdValue isEqualToString:currentVumarkIdOnCard]) {
                    [self blinkVumark:true];
                    [self hideCard];
                }
                const Vuforia::Image & instanceImage = vmtar.getInstanceImage();
                [self updateVumarkID:vumarkIdValue andType:vumarkIdType andImage:&instanceImage];
            }
            Vuforia::Matrix44F poseMatrix = Vuforia::Tool::convertPose2GLMatrix(result->getPose());
            
            // OpenGL 2
            Vuforia::Matrix44F modelViewProjection;
            
            glUseProgram(shaderProgramID);
            
            if (userData) {
                
                // Step 1: we draw the segments of the contour by stretching a square
                glVertexAttribPointer(vertexHandle, 3, GL_FLOAT, GL_FALSE, 0,
                                      (const GLvoid*) &frameVertices[0]);
                
                glEnableVertexAttribArray(vertexHandle);
                
                for(int idx = 0; idx < [userData nbSegments]; idx++) {
                    Vuforia::Matrix44F modelViewMatrix = poseMatrix;
                    [userData modelViewMatrix:modelViewMatrix forSegmentIdx:idx width:vumarkBorderSize];
                    SampleApplicationUtils::multiplyMatrix(&projectionMatrix.data[0], &modelViewMatrix.data[0], &modelViewProjection.data[0]);

                    glUniformMatrix4fv(mvpMatrixHandle, 1, GL_FALSE,
                                       (const GLfloat*)&modelViewProjection.data[0]);
                    glUniform1f(calphaHandle, isMainVumark ? [self blinkVumark:false] : 1.0);
                    
                    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT,
                                   (const GLvoid*) &frameIndices[0]);
                    
                }
                glDisableVertexAttribArray(vertexHandle);
                
                // Step 2: we draw a plain circle at the beginning of each segment
                glVertexAttribPointer(vertexHandle, 3, GL_FLOAT, GL_FALSE, 0,
                                      (const GLvoid*) &circleVertices[0]);
                
                glEnableVertexAttribArray(vertexHandle);
                
                
                // Add a translation to recenter the augmentation
                // on the VuMark center, w.r.t. the origin
                Vuforia::Vec2F origin = vmtmp.getOrigin();
                float translX = -origin.data[0];
                float translY = -origin.data[1];
                SampleApplicationUtils::translatePoseMatrix(translX, translY, 0.0, &poseMatrix.data[0]);
                
                for(int idx = 0; idx < [userData nbSegments]; idx++) {
                    Vuforia::Matrix44F modelViewMatrix = poseMatrix;
                    [userData modelViewMatrix:modelViewMatrix forSegmentStart:idx width:vumarkBorderSize];
                    SampleApplicationUtils::multiplyMatrix(&projectionMatrix.data[0], &modelViewMatrix.data[0], &modelViewProjection.data[0]);
                    
                    glUniformMatrix4fv(mvpMatrixHandle, 1, GL_FALSE,
                                       (const GLfloat*)&modelViewProjection.data[0]);
                    glUniform1f(calphaHandle, isMainVumark ? [self blinkVumark:false] : 1.0);
                    
                    glDrawArrays(GL_TRIANGLE_FAN, 0, CIRCLE_NB_VERTICES);
                    
                }
                glDisableVertexAttribArray(vertexHandle);
            }

            SampleApplicationUtils::checkGlError("EAGLView renderFrameVuforia");
        }
    }

    if(gotVuMark) {
        // if we have a detection, let's make sure
        // the card is visible
        [self showCard];
    } else {
        // we reset the state of the animation so that
        // it triggers next time a vumark is detected
        [self blinkVumark:true];
        // we also reset the value of the current value of the vumark on card
        // so that we hide and show the mumark if we redetect the same vumark
        currentVumarkIdOnCard = nil;
    }
    
    glDisable(GL_BLEND);
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
    
    [self presentFramebuffer];
}

- (CGFloat) distanceSquared:(Vuforia::Vec2F) p1 to:(Vuforia::Vec2F) p2 {
    return (CGFloat) (pow(p1.data[0] - p2.data[0], 2.0) + pow(p1.data[1] - p2.data[1], 2.0));
}

- (void)configureVideoBackgroundWithViewWidth:(float)viewWidth andHeight:(float)viewHeight
{
    [sampleAppRenderer configureVideoBackgroundWithViewWidth:viewWidth andHeight:viewHeight];
}

//------------------------------------------------------------------------------
#pragma mark - OpenGL ES management

- (void)initShaders
{
    shaderProgramID = [SampleApplicationShaderUtils createProgramWithVertexShaderFileName:@"Simple.vertsh"
                                                   fragmentShaderFileName:@"SimpleWithColor.fragsh"];

    if (0 < shaderProgramID) {
        vertexHandle = glGetAttribLocation(shaderProgramID, "vertexPosition");
        normalHandle = glGetAttribLocation(shaderProgramID, "vertexNormal");
        textureCoordHandle = glGetAttribLocation(shaderProgramID, "vertexTexCoord");
        mvpMatrixHandle = glGetUniformLocation(shaderProgramID, "modelViewProjectionMatrix");
        texSampler2DHandle  = glGetUniformLocation(shaderProgramID,"texSampler2D");
        calphaHandle  = glGetUniformLocation(shaderProgramID,"calpha");
    }
    else {
        NSLog(@"Could not initialise augmentation shader");
    }
}


- (void)createFramebuffer
{
    if (context) {
        // Create default framebuffer object
        glGenFramebuffers(1, &defaultFramebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
        
        // Create colour renderbuffer and allocate backing store
        glGenRenderbuffers(1, &colorRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
        
        // Allocate the renderbuffer's storage (shared with the drawable object)
        [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
        GLint framebufferWidth;
        GLint framebufferHeight;
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &framebufferWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &framebufferHeight);
        
        // Create the depth render buffer and allocate storage
        glGenRenderbuffers(1, &depthRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, framebufferWidth, framebufferHeight);
        
        // Attach colour and depth render buffers to the frame buffer
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
        
        // Leave the colour render buffer bound so future rendering operations will act on it
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    }
}


- (void)deleteFramebuffer
{
    if (context) {
        [EAGLContext setCurrentContext:context];
        
        if (defaultFramebuffer) {
            glDeleteFramebuffers(1, &defaultFramebuffer);
            defaultFramebuffer = 0;
        }
        
        if (colorRenderbuffer) {
            glDeleteRenderbuffers(1, &colorRenderbuffer);
            colorRenderbuffer = 0;
        }
        
        if (depthRenderbuffer) {
            glDeleteRenderbuffers(1, &depthRenderbuffer);
            depthRenderbuffer = 0;
        }
    }
}


- (void)setFramebuffer
{
    // The EAGLContext must be set for each thread that wishes to use it.  Set
    // it the first time this method is called (on the render thread)
    if (context != [EAGLContext currentContext]) {
        [EAGLContext setCurrentContext:context];
    }
    
    if (!defaultFramebuffer) {
        // Perform on the main thread to ensure safe memory allocation for the
        // shared buffer.  Block until the operation is complete to prevent
        // simultaneous access to the OpenGL context
        [self performSelectorOnMainThread:@selector(createFramebuffer) withObject:self waitUntilDone:YES];
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
}


- (BOOL)presentFramebuffer
{
    // setFramebuffer must have been called before presentFramebuffer, therefore
    // we know the context is valid and has been set for this (render) thread
    
    // Bind the colour render buffer and present it
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    
    return [context presentRenderbuffer:GL_RENDERBUFFER];
}

- (NSString *) convertInstanceIdToString:(const Vuforia::InstanceId&) instanceId {
    switch(instanceId.getDataType()) {
        case Vuforia::InstanceId::BYTES:
            return [self convertInstanceIdForBytes:instanceId];
        case Vuforia::InstanceId::STRING:
            return [self convertInstanceIdForString:instanceId];
        case Vuforia::InstanceId::NUMERIC:
            return [self convertInstanceIdForNumeric:instanceId];
        default:
            return @"Unknown";
    }
    
}

- (NSString *) convertInstanceIdForBytes:(const Vuforia::InstanceId&) instanceId
{
    const size_t MAXLEN = 100;
    char buf[MAXLEN];
    const char * src = instanceId.getBuffer();
    size_t len = instanceId.getLength();
    
    static const char* hexTable = "0123456789abcdef";
    
    if (len * 2 + 1 > MAXLEN) {
        len = (MAXLEN - 1) / 2;
    }
    
    // Go in reverse so the string is readable left-to-right.
    size_t bufIdx = 0;
    for (int i = (int)(len - 1); i >= 0; i--)
    {
        char upper = hexTable[(src[i] >> 4) & 0xf];
        char lower = hexTable[(src[i] & 0xf)];
        buf[bufIdx++] = upper;
        buf[bufIdx++] = lower;
    }
    
    // null terminate the string.
    buf[bufIdx] = 0;
    
    return [NSString stringWithCString:buf encoding:NSUTF8StringEncoding];
}

- (NSString *) convertInstanceIdForString:(const Vuforia::InstanceId&) instanceId
{
    const char * src = instanceId.getBuffer();
    return [NSString stringWithUTF8String:src];
}

- (NSString *) convertInstanceIdForNumeric:(const Vuforia::InstanceId&) instanceId
{
    unsigned long long value = instanceId.getNumericValue();
    return[NSString stringWithFormat:@"%ld", value];
}

- (NSString *) getInstanceIdType:(const Vuforia::InstanceId&) instanceId
{
    switch(instanceId.getDataType()) {
        case Vuforia::InstanceId::BYTES:
            return @"Bytes";
        case Vuforia::InstanceId::STRING:
            return @"String";
        case Vuforia::InstanceId::NUMERIC:
            return @"Numeric";
        default:
            return @"Unknown";
    }
}


- (void)createReticleOverlayView
{
    CGRect myframe = [[UIScreen mainScreen] applicationFrame];
    
    CGFloat dimRecticle = myframe.size.width / 2;
    CGFloat deltaX = dimRecticle / 2;
    CGFloat deltaY = (myframe.size.height - dimRecticle) / 2;
    
    myframe.origin.x += deltaX;
    myframe.origin.y += deltaY;
    myframe.size.height = dimRecticle;
    myframe.size.width = dimRecticle;
    
    
    UIImage* image = [UIImage imageNamed:@"reticle"];
    
    UIImageView * iv = [[UIImageView alloc] initWithFrame: myframe];
    iv.image = image;
    [self addSubview:iv];
}

- (void)createCardOverlayView
{
    CGRect myframe = [[UIScreen mainScreen] applicationFrame];
    
    padding = 10.0f;
    
    CGFloat cardHeight = 120.0f;
    CGFloat cardWidth = myframe.size.width - (2.0 * padding);
    textLabelHeight = 32.0;
    
    
    // we keep the frames to display/hide
    // the card
    cardFrameVisible = myframe;
    cardFrameVisible.origin.x = padding;
    cardFrameVisible.origin.y = myframe.size.height - cardHeight - padding;
    cardFrameVisible.size.height = cardHeight;
    cardFrameVisible.size.width = cardWidth;
    
    cardFrameHidden = cardFrameVisible;
    cardFrameHidden.origin.y += cardHeight + padding;
    
    cardView = [[UIView alloc] initWithFrame:cardFrameHidden];
    [cardView setBackgroundColor:[UIColor whiteColor]];
    // rounded cornners
    cardView.layer.masksToBounds = YES;
    cardView.layer.cornerRadius = 8;
    cardView.userInteractionEnabled = YES;
    [cardView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapCard:)]];
    
    [self addSubview:cardView];
    
    UIImage* image = [UIImage imageNamed:@"card_info"];
    CGFloat imgHeight = image.size.height;
    CGFloat imgWidth = image.size.width;
    CGFloat maxImgHeight = cardHeight - 2.0 * padding;
    if (imgHeight > maxImgHeight){
        imgWidth *= maxImgHeight / imgHeight;
        imgHeight = maxImgHeight;
    }
    
    vuMarkImage = [[UIImageView alloc] initWithFrame: CGRectMake(padding, (cardHeight - imgHeight) / 2.0, imgWidth, imgHeight)];
    vuMarkImage.contentMode = UIViewContentModeScaleAspectFit;
    vuMarkImage.image = image;
    [cardView addSubview:vuMarkImage];
    
    CGFloat startX = imgWidth + (2.0 * padding);

    // dimension of the box in which we want to display the text
    textBoxWidth = cardWidth - startX - padding;
    textBoxHeight = cardHeight - 2.0 * padding;
    
    // the dimension & position of the following frames are
    // not relevant at that time as they will depend on the text actually displayed
    // (see method: updateVumarkID:(NSString *)vuMarkId andType:(NSString *) vuMarkType )
    cardTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(startX, 10 , textBoxWidth, textLabelHeight)];
    cardTypeLabel.numberOfLines = 0;
    cardTypeLabel.textColor = COLOR_LABEL;
    cardTypeLabel.text = @"";
    
    [cardView addSubview:cardTypeLabel];
    
    cardIdLabel = [[UILabel alloc] initWithFrame:CGRectMake(startX, 40, textBoxWidth, textLabelHeight)];
    cardIdLabel.numberOfLines = 0;
    cardIdLabel.textColor = COLOR_ID;
    cardIdLabel.text = @"";
    
    [cardView addSubview:cardIdLabel];
}

- (void) updateVumarkID:(NSString *)vuMarkId andType:(NSString *) vuMarkType andImage:(const Vuforia::Image *) instanceImage {
    // we don;t update right away the value of the vumark as
    // the card will be first dismissed. The show card method
    // will get the value and display it only at the end of the animation
    // so that the disappearing card keeps the old value
    currentVumarkIdOnCard = [vuMarkId copy];
    
    cardTypeLabel.text = vuMarkType;
    
    CGFloat label1Height = [self adjustLabelForText:vuMarkType withWidth:textBoxWidth inLabel:cardTypeLabel]; // cardTypeLabel.frame.size.height;
    CGFloat label2Height = [self adjustLabelForText:vuMarkId withWidth:textBoxWidth inLabel:cardIdLabel];
    
    CGFloat topY = padding + (textBoxHeight - (label1Height + label2Height)) / 2;
    
    CGRect frame = cardTypeLabel.frame;
    frame.origin.y = topY;
    cardTypeLabel.frame = frame;
    
    frame = cardIdLabel.frame;
    frame.origin.y = topY + label1Height;
    cardIdLabel.frame = frame;
    
    vuMarkImage.image = [self createUIImage:instanceImage];
}

- (CGFloat) adjustLabelForText:(NSString *)text withWidth:(CGFloat) width inLabel:(UILabel *) label
{
    CGSize maxLabelSize = CGSizeMake(width, FLT_MAX);
    
    CGRect rect = [text boundingRectWithSize:maxLabelSize
                                     options:NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading
                                  attributes:@{NSFontAttributeName:label.font}
                                     context:nil];
    
    //adjust the label the the new height.
    CGRect updatedFrame = label.frame;
    updatedFrame.size.height = rect.size.height;
    label.frame = updatedFrame;
    return rect.size.height;
}


- (void) onTapCard:(UITapGestureRecognizer *)sender {
    [self hideCard];
}

// show the card
- (void) showCard {
    if (cardViewVisible) {
        return;
    }
    NSString * value = currentVumarkIdOnCard;
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         cardView.frame = cardFrameVisible;
                     }
                     completion:^(BOOL finished){
                         cardViewVisible = true;
                         cardIdLabel.text = value;
                     }];
}

- (void) hideCard {
    if (! cardViewVisible) {
        return;
    }
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         cardView.frame = cardFrameHidden;
                     }
                     completion:^(BOOL finished){
                          cardViewVisible = false;
                     }];
}

- (UIImage *)createUIImage:(const Vuforia::Image *)vuforiaImage
{
    int width = vuforiaImage->getWidth();
    int height = vuforiaImage->getHeight();
    int bitsPerComponent = 8;
    int bitsPerPixel = Vuforia::getBitsPerPixel(Vuforia::RGBA8888);
    int bytesPerRow = vuforiaImage->getBufferWidth() * bitsPerPixel / bitsPerComponent;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, vuforiaImage->getPixels(), Vuforia::getBufferSize(width, height, Vuforia::RGBA8888), NULL);
    
    CGImageRef imageRef = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpaceRef);
    CGImageRelease(imageRef);
    
    return image;
}


@end
