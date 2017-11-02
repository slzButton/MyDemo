/*===============================================================================
Copyright (c) 2016 PTC Inc. All Rights Reserved.

Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of PTC Inc., registered in the United States and other 
countries.
===============================================================================*/



#import <UIKit/UIKit.h>

#import <Vuforia/UIGLViewProtocol.h>

#import "Texture.h"
#import "SampleApplicationSession.h"
#import "WordlistView.h"
#import "SampleGLResourceHandler.h"
#import "SampleAppRenderer.h"

static const int kNumAugmentationTextures = 1;


// EAGLView is a subclass of UIView and conforms to the informal protocol
// UIGLViewProtocol
@interface TextRecoEAGLView : UIView <UIGLViewProtocol, SampleGLResourceHandler, SampleAppRendererControl> {
@private
    // OpenGL ES context
    EAGLContext *context;
    
    // The OpenGL ES names for the framebuffer and renderbuffers used to render
    // to this view
    GLuint defaultFramebuffer;
    GLuint colorRenderbuffer;
    GLuint depthRenderbuffer;

    // Shader handles
    GLuint lineShaderProgramID;
    GLint mvpMatrixHandle;
    GLint lineOpacityHandle;
    GLint lineColorHandle;
    GLint vertexHandle;
    
    int ROICenterX;
    int ROICenterY;
    int ROIWidth;
    int ROIHeight;
    
    // Texture used when rendering augmentation
    Texture* augmentationTexture[kNumAugmentationTextures];
    
    SampleAppRenderer *sampleAppRenderer;
}

@property (nonatomic, weak) SampleApplicationSession * vapp;

- (id)initWithFrame:(CGRect)frame appSession:(SampleApplicationSession *) app;
- (void)finishOpenGLESCommands;
- (void)freeOpenGLESResources;
- (void)createTextOverlayView;
- (void)setRoiWidth:(int) width height:(int)height centerX:(int)centerX centerY:(int)centerY;
- (void)configureVideoBackgroundWithViewWidth:(float)viewWidth andHeight:(float)viewHeight;
- (void) updateRenderingPrimitives;

@end
