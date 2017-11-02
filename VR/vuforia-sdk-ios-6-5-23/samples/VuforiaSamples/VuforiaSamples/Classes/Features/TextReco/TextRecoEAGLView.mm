/*===============================================================================
Copyright (c) 2016-2017 PTC Inc. All Rights Reserved.

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
#import <Vuforia/VideoBackgroundConfig.h>
#import <Vuforia/TrackableResult.h>
#import <Vuforia/WordResult.h>

#import "TextRecoEAGLView.h"
#import "Texture.h"
#import "SampleApplicationUtils.h"
#import "SampleApplicationShaderUtils.h"
#import "Quad.h"


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
    
    const int MAX_WORD_LENGTH = 255;
    const int MAX_NB_WORDS = 132;

    // used to draw the ROI
    float roiVertices[] =
    {
        -0.5, -0.5, 0.0,    0.5, -0.5, 0.0,    0.5, 0.5, 0.0,    -0.5, 0.5, 0.0
    };

    
    struct WordDesc
    {
        char text[MAX_WORD_LENGTH];
        int Ax,Ay; // Upper left corner
        int Bx,By; // Lower right corner
    };
    
    
    static const int kNumQuadTextRecoObjectIndices = 8;
    
    static const float quadTextRecoVertices[] =
    {
        -0.5, -0.5, 0.0, 0.5, -0.5, 0.0, 0.5, 0.5, 0.0, -0.5, 0.5, 0.0,
    };
    
    static const unsigned short quadTextRecoIndices[] =
    {
        0, 1, 1, 2, 2, 3, 3, 0
    };


}


@interface TextRecoEAGLView ()

// View containing the list of detected words
@property (nonatomic, strong) WordlistView *wordlistView;

- (void)initShaders;
- (void)createFramebuffer;
- (void)deleteFramebuffer;
- (void)setFramebuffer;
- (BOOL)presentFramebuffer;

@end


@implementation TextRecoEAGLView

@synthesize vapp, wordlistView;

// You must implement this method, which ensures the view's underlying layer is
// of type CAEAGLLayer
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}


//------------------------------------------------------------------------------
#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame  appSession:(SampleApplicationSession *) app
{
    self = [super initWithFrame:frame];
    
    if (self) {
        vapp = app;
        
        // Enable retina mode if available on this device
        if (YES == [vapp isRetinaDisplay]) {
            [self setContentScaleFactor:[UIScreen mainScreen].nativeScale];
        }
        
        // Create the OpenGL ES context
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
        // The EAGLContext must be set for each thread that wishes to use it.
        // Set it the first time this method is called (on the main thread)
        if (context != [EAGLContext currentContext]) {
            [EAGLContext setCurrentContext:context];
        }
        
        sampleAppRenderer = [[SampleAppRenderer alloc] initWithSampleAppRendererControl:self deviceMode:Vuforia::Device::MODE_AR stereo:false nearPlane:1 farPlane:5000];
        
        [self initShaders];
        
        [sampleAppRenderer initRendering];
    }
    
    return self;
}

- (void)createTextOverlayView
{
    // Create the word list view
    wordlistView = [[WordlistView alloc] initWithFrame:self.frame];
    [self addSubview:wordlistView];
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
    
    wordlistView = nil;
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

- (void) setRoiWidth:(int) width height:(int)height centerX:(int)centerX centerY:(int)centerY {
    ROICenterX = centerX;
    ROICenterY = centerY;
    ROIWidth = width;
    ROIHeight = height;
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
    
    // Render the video background
    [sampleAppRenderer renderVideoBackground];
    
    glEnable(GL_DEPTH_TEST);
    // We must detect if background reflection is active and adjust the culling direction.
    // If the reflection is active, this means the pose matrix has been reflected as well,
    // therefore standard counter clockwise face culling will result in "inside out" models.
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    // Array of words discovered
    WordDesc WordsFound[MAX_NB_WORDS];
    int NbWordsFound = 0;
    
    // Did we find any trackables this frame?
    for (int tIdx = 0; tIdx < state.getNumTrackableResults(); tIdx++)
    {
        // Get the trackable:
        const Vuforia::TrackableResult* result = state.getTrackableResult(tIdx);
        Vuforia::Matrix44F modelViewMatrix = Vuforia::Tool::convertPose2GLMatrix(result->getPose());
        
        Vuforia::Vec2F wordBoxSize(0, 0);
        
        if (result->isOfType(Vuforia::WordResult::getClassType()))
        {
            const Vuforia::WordResult* wordResult = (const Vuforia::WordResult*) result;
        	// Get the word
            const Vuforia::Word& word = wordResult->getTrackable();
            const Vuforia::Obb2D& obb = wordResult->getObb();
            wordBoxSize = word.getSize();
        	if (word.getStringU())
            {
                // in portrait, the obb coordinate is based on
            	// a 0,0 position being in the upper right corner
            	// with :
            	// X growing from top to bottom and
            	// Y growing from right to left
            	//
            	// we convert those coordinates to be more natural
            	// with our application:
            	// - 0,0 is the upper left corner
            	// - X grows from left to right
            	// - Y grows from top to bottom
                float wordx = - obb.getCenter().data[1];
                float wordy = obb.getCenter().data[0];
                
            	// Convert the string to 7bit ASCII (if possible)
                char* stringA = 0;
                if (unicodeToAscii(word, stringA))
                {
                    // Store the word
                    if (NbWordsFound < MAX_NB_WORDS)
                    {
                        struct WordDesc * word =  & WordsFound[NbWordsFound];
                        NbWordsFound++;
                        strncpy(word->text, stringA, MAX_WORD_LENGTH - 1);
                        word->text[MAX_WORD_LENGTH - 1] = '\0';
                        word->Ax = wordx - (int)(wordBoxSize.data[0] / 2);
                        word->Ay = wordy - (int)(wordBoxSize.data[1] / 2);
                        word->Bx = wordx + (int)(wordBoxSize.data[0] / 2);
                        word->By = wordy + (int)(wordBoxSize.data[1] / 2);
                    }
                    
                    delete[] stringA;
                }
            }
        }
        else
        {
        	NSLog(@"Unexpected detection");
        }
        
        
        
        Vuforia::Matrix44F modelViewProjection;
        
        SampleApplicationUtils::translatePoseMatrix(0.0f, 0.0f, 0.0f,&modelViewMatrix.data[0]);
        SampleApplicationUtils::scalePoseMatrix(wordBoxSize.data[0], wordBoxSize.data[1], 1.0f,&modelViewMatrix.data[0]);
        SampleApplicationUtils::multiplyMatrix(&projectionMatrix.data[0],&modelViewMatrix.data[0] ,&modelViewProjection.data[0]);
        
        glUseProgram(lineShaderProgramID);
        
        glLineWidth(2.0f);
        
        glVertexAttribPointer(vertexHandle, 3, GL_FLOAT, GL_FALSE, 0,(const GLvoid*) &quadTextRecoVertices[0]);
        
        glEnableVertexAttribArray(vertexHandle);
        
        glUniform1f(lineOpacityHandle, 1.0f);
        glUniform3f(lineColorHandle, 1.0f, 0.447f, 0.0f);
        glUniformMatrix4fv(mvpMatrixHandle, 1, GL_FALSE,(GLfloat*)&modelViewProjection.data[0] );
        
        glDrawElements(GL_LINES, kNumQuadTextRecoObjectIndices, GL_UNSIGNED_SHORT,(const GLvoid*) &quadTextRecoIndices[0]);
        
        // Disable the vertex array handle
        glDisableVertexAttribArray(vertexHandle);
        
        glLineWidth(1.0f);
        
        // Unbind shader program
        glUseProgram(0);
        
        SampleApplicationUtils::checkGlError("TextReco renderFrame");
    }
    
    // Draw the region of interest
    [self drawRegionOfInterestWithCenterX:ROICenterX centerY:ROICenterY width:ROIWidth height:ROIHeight];

     
    SampleApplicationUtils::checkGlError("TextReco renderFrame - post-drawROI");
    
    glDisable(GL_BLEND);
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
    
    // Update the display
    [self presentFramebuffer];
    
    // Display any words that have been found, in the word list view
    DisplayWords* displayWords = [[DisplayWords alloc] init];
    
    if (NbWordsFound > 0) {
		// Order the words per line and left to right
    	qsort(& WordsFound[0], NbWordsFound, sizeof(struct WordDesc), wordDescCompare);
        
    	for (int i = 0 ; i < NbWordsFound ; i++) {
            struct WordDesc * word =  & WordsFound[i];
            NSString* temp =[NSString stringWithUTF8String:word->text];
            [displayWords->words appendString:temp];
            [displayWords->words appendString:@"\n"];
    	}
        
        displayWords->count = NbWordsFound;
    }
    
    // Update the word list
    if (wordlistView != nil) {
        [wordlistView setWordsToDisplay:displayWords];
    }
}

- (void)configureVideoBackgroundWithViewWidth:(float)viewWidth andHeight:(float)viewHeight
{
    [sampleAppRenderer configureVideoBackgroundWithViewWidth:viewWidth andHeight:viewHeight];
}

//------------------------------------------------------------------------------
#pragma mark - Private methods

//------------------------------------------------------------------------------
#pragma mark - OpenGL ES management

- (void)initShaders
{
    lineShaderProgramID = [SampleApplicationShaderUtils createProgramWithVertexShaderFileName:@"Line.vertsh"
                                                                   fragmentShaderFileName:@"Line.fragsh"];
    
    //lineShaderProgramID = SampleApplicationUtils::createProgramFromBuffer(lineVertexShader, lineFragmentShader);
    
    if (0 < lineShaderProgramID) {
        vertexHandle = glGetAttribLocation(lineShaderProgramID, "vertexPosition");
        mvpMatrixHandle = glGetUniformLocation(lineShaderProgramID, "modelViewProjectionMatrix");
        lineOpacityHandle = glGetUniformLocation(lineShaderProgramID, "opacity");
        lineColorHandle = glGetUniformLocation(lineShaderProgramID, "color");
    }
    else {
        NSLog(@"Could not initialise shader");
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


- (void) drawRegionOfInterestWithCenterX:(float) center_x centerY:(float) center_y width:(float)width height:(float) height
{
    // assumption is that center_x, center_y, width and height are given here in screen coordinates (screen pixels)
    // Region of interest projection matrix
    static float ROIOrthoProjMatrix[16];
    static bool done = false;
    
    // Calculate the region of interest projection matrix only once
    if (false == done) {
        // Obtain screen size
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        
        screenWidth *= [UIScreen mainScreen].nativeScale;
        screenHeight *= [UIScreen mainScreen].nativeScale;
    
        int posX = 0;
        int posY = 0;
        int sizeX = screenWidth;
        int sizeY = screenHeight;
        
        if (sizeX == 0 || sizeY == 0) {
            // viewport size might have not been configured yet
            // skip one frame
            return;
        }
        
        SampleApplicationUtils::setOrthoMatrix(0.0f, sizeX, sizeY, 0.0f, -1.0f, 1.0f, ROIOrthoProjMatrix);
        
        // compute coordinates
        float minX = center_x - width / 2;
        float maxX = center_x + width / 2;
        float minY = center_y - height / 2;
        float maxY = center_y + height / 2;
        
        // Update vertex coordinates of ROI rectangle
        roiVertices[0] = minX - posX;
        roiVertices[1] = minY - posY;
        roiVertices[2] = 0;
        
        roiVertices[3] = maxX - posX;
        roiVertices[4] = minY - posY;
        roiVertices[5] = 0;
        
        roiVertices[6] = maxX - posX;
        roiVertices[7] = maxY - posY;
        roiVertices[8] = 0;
        
        roiVertices[9] = minX - posX;
        roiVertices[10] = maxY - posY;
        roiVertices[11] = 0;
        
        done = true;
    }
    
    glUseProgram(lineShaderProgramID);
    glLineWidth(3.0f);
    
    glVertexAttribPointer(vertexHandle, 3, GL_FLOAT, GL_FALSE, 0, roiVertices);
    glEnableVertexAttribArray(vertexHandle);
    
    glUniform1f(lineOpacityHandle, 1.0f);
    glUniform3f(lineColorHandle, 0.0f, 1.0f, 0.0f);//R,G,B
    
    glUniformMatrix4fv(mvpMatrixHandle, 1, GL_FALSE, ROIOrthoProjMatrix);
    
    // Then, we issue the render call
    glDrawElements(GL_LINES, kNumQuadTextRecoObjectIndices, GL_UNSIGNED_SHORT,(const GLvoid*) &quadTextRecoIndices[0]);
    glDisableVertexAttribArray(vertexHandle);
    glLineWidth(1.0f);
    glUseProgram(0);
}


//------------------------------------------------------------------------------
#pragma mark - Helper functions
                                     
// Support functionality for converting a Unicode string to an ASCII 7bit string
bool unicodeToAscii(const Vuforia::Word& word, char*& asciiString)
{
    // Quick check if this string can be represented as ASCII. If the number
    // of code units in the string is not equal the number of characters, then
    // there are characters in this string that need two units to be represented
    // and thus cannot be represented in ASCII
    if (word.getLength() != word.getNumCodeUnits())
        return false;
    
    // Check if any individual character is outside the ASCII range
    const Vuforia::UInt16* stringU = word.getStringU();
    for (int c = 0; c < word.getLength(); ++c)
        if (stringU[c] > 127)
            return false;
    
    // Create new string and convert
    char* stringA = new char[word.getLength()+1];
    for (int c = 0; c < word.getLength(); ++c)
        stringA[c] = (char) stringU[c];
    stringA[word.getLength()] = '\0';
    
    // Done
    asciiString = stringA;
    return true;
}
                             
                             
// here 0,0 is the upper left corner
// X grows from left to right
// Y grows from top to bottom
int wordDescCompare(const void * o1, const void * o2)
{
    const WordDesc * w1 = (const WordDesc *)o1;
    const WordDesc * w2 = (const WordDesc *)o2;
    int ret = 0;
    
    // we check first if both words are on the same line
    // both words are said to be on the same line if the
    // mid point (on Y axis) of the first point
    // is between the values of the second point
    int mid1Y = (w1->Ay + w1->By) / 2;
    
    if ((mid1Y < w2->By) && (mid1Y > w2->Ay))
    {
        // words are on the same line
        ret = w1->Ax - w2->Ax;
    }
    else
    {
        // words on different line
        ret = w1->Ay - w2->Ay;
    }
    
    return ret;
}
                             




@end
