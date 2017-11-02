/*===============================================================================
Copyright (c) 2016 PTC Inc. All Rights Reserved.

Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of PTC Inc., registered in the United States and other 
countries.
===============================================================================*/

#ifndef _VUFORIA_REFFREEFRAME_GL_H_
#define _VUFORIA_REFFREEFRAME_GL_H_

// Include files
#import <Vuforia/Tool.h>
#import <Vuforia/DataSet.h>
#import <Vuforia/ImageTarget.h>
#include <Vuforia/Vuforia.h>
#include <Vuforia/CameraDevice.h>
#include <Vuforia/Tool.h>
#include <Vuforia/TrackerManager.h>
#include <Vuforia/ImageTargetBuilder.h>
#include <Vuforia/Renderer.h>
#include <Vuforia/VideoBackgroundConfig.h>

// Forward declarations

/// A utility class for the RefFree frame.
class RefFreeFrame
{
public:

    /// Constructor
    RefFreeFrame();

    /// Destructor.
    ~RefFreeFrame();

    /// Initializes the class (uses assets, need to be called from an Activity
    void init();

     /// Initializes (OpenGL-dependent and camera-dependent!!!) - Call when there's a valid GL context
    void initGL(int screenWidth, int screenHeight);

    /// Deinitilizes the class
    void deInit();

    /// Updates the states and renders the hints, depending on the current status of the tracker
    void render();

    /// Resets the curStatus to IDLE
    void reset();
    
    /// Sets the state to CREATING
    void setCreating();
    
    bool stopImageTargetBuilder();
    
    bool isImageTargetBuilderRunning();
    
    bool startImageTargetBuilder();
    
    void startBuild();
    
    /// Checks if a new trackable source is available
    bool hasNewTrackableSource();
    
    /// Retreives the available trackable source, returns NULL if the trackable has already been retreived
    Vuforia::TrackableSource* getNewTrackableSource();
    
    void restartTracker();
    
protected:
    /// Get the time in milliseconds
    unsigned long getTimeMS();
    
    
    /// The following methods rely on the internal state of this class
    /// when they are called.  Take care if extracting their functionality
    /// that you properly set up the enviroment.
    
    /// Updates the UI state in the render method
    void updateUIState(Vuforia::ImageTargetBuilder * targetBuilder, Vuforia::ImageTargetBuilder::FRAME_QUALITY frameQuality);
    
    /// Renders the scanning state view finder according to the result
    void renderScanningViewfinder(Vuforia::ImageTargetBuilder::FRAME_QUALITY quality);
      
    /**
     * Enum to decribe the status of the UI showing the target 
     * creation state. 
     *  
     * IDLE - No target is currently being created 
     * SCANNING - Show the "Scanning UI", this uses frame quality info 
     *            from the SDK to give feedback to the user as to how
     *            good a target their current frame is.
     * CREATING - While in this state the SDK is creating the target 
     *            requested by the app layer.
     * SUCCESS - This state indicates that target creation was successful.
     */
    enum STATUS { STATUS_IDLE, STATUS_SCANNING, STATUS_CREATING, STATUS_SUCCESS };
    STATUS curStatus;
    
    /// Half of the screen size, used often in the rendering pipeline
    Vuforia::Vec2F halfScreenSize;
    
    float elapsedBadFrame;
    
    /// Keep track of the time between frames for color transitions
    unsigned long lastFrameTime;
    unsigned long lastSuccessTime;
    
     /// The latest trackable source to be extracted from the Target Builder
    Vuforia::TrackableSource* trackableSource;
   
};


#endif //_VUFORIA_REFFREEFRAME_H_
