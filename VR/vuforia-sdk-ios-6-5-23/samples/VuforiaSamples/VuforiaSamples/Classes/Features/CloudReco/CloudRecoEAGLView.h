/*===============================================================================
Copyright (c) 2016 PTC Inc. All Rights Reserved.

Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of PTC Inc., registered in the United States and other 
countries.
===============================================================================*/


#import <UIKit/UIKit.h>

#import <Vuforia/UIGLViewProtocol.h>
#import <Vuforia/TrackableResult.h>
#import <Vuforia/Vectors.h>

#import "Texture.h"
#import "SampleApplicationSession.h"
#import "SampleGLResourceHandler.h"
#import "SampleAppRenderer.h"


// structure to point to an object to be drawn
@interface Object3D : NSObject

@property (nonatomic) unsigned int numVertices;
@property (nonatomic) const float *vertices;
@property (nonatomic) const float *normals;
@property (nonatomic) const float *texCoords;

@property (nonatomic) unsigned int numIndices;
@property (nonatomic) const unsigned short *indices;

@property (nonatomic) Texture *texture;

@end


@class CloudRecoViewController;

static const int kNumAugmentationTextures = 1;


// EAGLView is a subclass of UIView and conforms to the informal protocol
// UIGLViewProtocol
@interface CloudRecoEAGLView : UIView <UIGLViewProtocol, SampleGLResourceHandler, SampleAppRendererControl> {
@private
    // OpenGL ES context
    EAGLContext *context;
    
    // The OpenGL ES names for the framebuffer and renderbuffers used to render
    // to this view
    GLuint defaultFramebuffer;
    GLuint colorRenderbuffer;
    GLuint depthRenderbuffer;
    
    // Shader handles
    GLuint shaderProgramID;
    GLint vertexHandle;
    GLint normalHandle;
    GLint textureCoordHandle;
    GLint mvpMatrixHandle;
    GLint texSampler2DHandle;
    
    // Texture used when rendering augmentation
    Texture* augmentationTexture[kNumAugmentationTextures];

    BOOL offTargetTrackingEnabled;
    
    SampleAppRenderer *sampleAppRenderer;
}

@property (nonatomic, weak) SampleApplicationSession * vapp;
@property (nonatomic, weak) CloudRecoViewController * viewController;


- (id)initWithFrame:(CGRect)frame appSession:(SampleApplicationSession *) app viewController:(CloudRecoViewController *) viewController;
- (void)finishOpenGLESCommands;
- (void)freeOpenGLESResources;
- (void)configureVideoBackgroundWithViewWidth:(float)viewWidth andHeight:(float)viewHeight;
- (void) updateRenderingPrimitives;

@end
