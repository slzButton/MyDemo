/*===============================================================================
Copyright (c) 2016 PTC Inc. All Rights Reserved.

Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of PTC Inc., registered in the United States and other 
countries.
===============================================================================*/

// ** Include files
#include <math.h>
#include <string.h>
#include <sys/time.h>

#include <Vuforia/Vuforia.h>
#include <Vuforia/CameraDevice.h>
#include <Vuforia/Tool.h>

#include <Vuforia/TrackerManager.h>
#include <Vuforia/ObjectTracker.h>
#include <Vuforia/ImageTargetBuilder.h>

#include <Vuforia/Renderer.h>
#include <Vuforia/VideoBackgroundConfig.h>

#include "RefFreeFrame.h"
#import "SampleApplicationUtils.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


// ** Some helper functions

/// Function used to transition in the range [0, 1]
void transition(float &v0, float inc, float a=0.0f, float b=1.0f)
{
	float vOut = v0 + inc;
	v0 = (vOut < a ? a : (vOut > b ? b : vOut));
}

// ** Constants

bool targetBuilderActive                = false;
bool displayLowQualityWarning           = true;
int targetBuilderCounter                = 1;

// ** Methods

RefFreeFrame::RefFreeFrame() : 
    
    curStatus(STATUS_IDLE), 
    elapsedBadFrame(0.0f),
    lastSuccessTime(0),
    trackableSource(NULL)
  
{
    
}

RefFreeFrame::~RefFreeFrame()
{
    
}


void
RefFreeFrame::init()
{
    trackableSource = NULL;
}

void 
RefFreeFrame::deInit()
{
    Vuforia::TrackerManager& trackerManager = Vuforia::TrackerManager::getInstance();
    Vuforia::ObjectTracker* objectTracker = static_cast<Vuforia::ObjectTracker*>(trackerManager.getTracker(Vuforia::ObjectTracker::getClassType()));
    if(objectTracker != 0)
    {
        Vuforia::ImageTargetBuilder* targetBuilder = objectTracker->getImageTargetBuilder();
        if (targetBuilder && (targetBuilder->getFrameQuality() != Vuforia::ImageTargetBuilder::FRAME_QUALITY_NONE))
        {
            targetBuilder->stopScan();
        }
    }
}

void
RefFreeFrame::initGL(int screenWidth, int screenHeight)
{    
    Vuforia::Renderer &renderer = Vuforia::Renderer::getInstance();
    const Vuforia::VideoBackgroundConfig &vc = renderer.getVideoBackgroundConfig();
    halfScreenSize.data[0] = vc.mSize.data[0] * 0.5f; 
    halfScreenSize.data[1] = vc.mSize.data[1] * 0.5f;
 
    // sets last frame timer
    lastFrameTime = getTimeMS();
    elapsedBadFrame = 0.0f;
}

void
RefFreeFrame::reset()
{
    curStatus = STATUS_IDLE;
    elapsedBadFrame = 0.0f;
}

void
RefFreeFrame::setCreating()
{
    curStatus = STATUS_CREATING;
}

void RefFreeFrame::updateUIState(Vuforia::ImageTargetBuilder * targetBuilder, Vuforia::ImageTargetBuilder::FRAME_QUALITY frameQuality)
{
    // ** Elapsed time
    unsigned long elapsedTimeMS = getTimeMS() - lastFrameTime;
    lastFrameTime += elapsedTimeMS;
    
    // these are time-dependent values used for transitions in the range [0, 1]
    float transitionTenSecond = elapsedTimeMS * 0.0001f;
    
	STATUS newStatus(curStatus);
    
	switch (curStatus)
	{
        case STATUS_IDLE:
			if (frameQuality != Vuforia::ImageTargetBuilder::FRAME_QUALITY_NONE)
				newStatus = STATUS_SCANNING;
            
            break;
            
		case STATUS_SCANNING:
			switch (frameQuality)
            {
                // bad target quality, render the frame white until a match is made, then go to green
                case Vuforia::ImageTargetBuilder::FRAME_QUALITY_LOW:
                    
                    elapsedBadFrame += transitionTenSecond;
                    
                    if (elapsedBadFrame >= 1)
                    {
                        NSLog(@"Can't find a target for 10 seconds");
                        elapsedBadFrame=0;
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"kBadFrameQuality" object:nil];                    
                    break;
                    
                // good target, switch to green
                case Vuforia::ImageTargetBuilder::FRAME_QUALITY_MEDIUM:                    
                case Vuforia::ImageTargetBuilder::FRAME_QUALITY_HIGH:
                    
                    elapsedBadFrame=0;
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"kGoodFrameQuality" object:nil];
                    break;
                
                case Vuforia::ImageTargetBuilder::FRAME_QUALITY_NONE:
                default:
                    //  Do nothing
                    break;
            }
            break;
            
		case STATUS_CREATING:
        {
            // check for new result
            // if found, set to success, success time and:
            Vuforia::TrackableSource* newTrackableSource = targetBuilder->getTrackableSource();
            if (newTrackableSource != NULL)
            {
                newStatus = STATUS_SUCCESS;
                lastSuccessTime = lastFrameTime;
                trackableSource = newTrackableSource;
                targetBuilder->stopScan();
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kTrackableCreated" object:nil];
            }
        }
            break;
        default:
            break;
	}
    
	curStatus = newStatus;
}

void
RefFreeFrame::render()
{
    // ** Get the image tracker
    Vuforia::TrackerManager& trackerManager = Vuforia::TrackerManager::getInstance();
    Vuforia::ObjectTracker* objectTracker = static_cast<Vuforia::ObjectTracker*>(trackerManager.getTracker(Vuforia::ObjectTracker::getClassType()));
    
    if(objectTracker != 0)
    {
        // Get the frame quality from the target builder
        Vuforia::ImageTargetBuilder* targetBuilder = objectTracker->getImageTargetBuilder();
        Vuforia::ImageTargetBuilder::FRAME_QUALITY frameQuality = targetBuilder->getFrameQuality();
        
        // Update the UI internal state variables
        updateUIState(targetBuilder, frameQuality);
        
        if (curStatus == STATUS_SUCCESS)
        {
            curStatus = STATUS_IDLE;
            
            NSLog(@"Built target, reactivating dataset with new target");
            // activate the dataset with the new target added
            //imageTracker->activateDataSet(activeDataSet);
            restartTracker();
        }
    } else {
        NSLog(@"object Tracker is null");
    }

    SampleApplicationUtils::checkGlError("RefFreeFrame render");
}

unsigned long
RefFreeFrame::getTimeMS()
{
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return tv.tv_sec * 1000 + tv.tv_usec / 1000;
}


bool 
RefFreeFrame::startImageTargetBuilder()
{
    NSLog(@"RefFreeFrame startImageTargetBuilder()");
        
    Vuforia::TrackerManager& trackerManager = Vuforia::TrackerManager::getInstance();
    Vuforia::ObjectTracker* objectTracker = static_cast<Vuforia::ObjectTracker*>(trackerManager.getTracker(Vuforia::ObjectTracker::getClassType()));
    if(objectTracker != 0)
    {
        Vuforia::ImageTargetBuilder* targetBuilder = objectTracker->getImageTargetBuilder();
        
        if (targetBuilder)
        {
            // if needed, stop the target builder
            
            if (targetBuilder->getFrameQuality() != Vuforia::ImageTargetBuilder::FRAME_QUALITY_NONE)
                targetBuilder->stopScan();
            
            objectTracker->stop();
            
            targetBuilder->startScan();
        }
    }
    else {
        NSLog(@"object Tracker is null");
        return false;
    }
    
    return true;
}


bool 
RefFreeFrame::stopImageTargetBuilder()
{
    NSLog(@"RefFreeFrame stopImageTargetBuilder()");
    
    Vuforia::TrackerManager& trackerManager = Vuforia::TrackerManager::getInstance();
    Vuforia::ObjectTracker* objectTracker = static_cast<Vuforia::ObjectTracker*>(trackerManager.getTracker(Vuforia::ObjectTracker::getClassType()));
    
    if(objectTracker)
    {
        Vuforia::ImageTargetBuilder* targetBuilder = objectTracker->getImageTargetBuilder();
        if (targetBuilder)
        {
            if (targetBuilder->getFrameQuality() != Vuforia::ImageTargetBuilder::FRAME_QUALITY_NONE)
            {
                targetBuilder->stopScan();
                targetBuilder = NULL;
                
                reset();
               
                Vuforia::TrackerManager& trackerManager = Vuforia::TrackerManager::getInstance();
                Vuforia::ObjectTracker* objectTracker = static_cast<Vuforia::ObjectTracker*>(trackerManager.getTracker(Vuforia::ObjectTracker::getClassType()));
                
                objectTracker->start();
            }
        }
        else
          return false;
    }
    
    return true;
}


bool
RefFreeFrame::isImageTargetBuilderRunning()
{
    Vuforia::TrackerManager& trackerManager = Vuforia::TrackerManager::getInstance();
    Vuforia::ObjectTracker* objectTracker = static_cast<Vuforia::ObjectTracker*>(trackerManager.getTracker(Vuforia::ObjectTracker::getClassType()));
    
    if (objectTracker)
    {
        Vuforia::ImageTargetBuilder* targetBuilder = objectTracker->getImageTargetBuilder();
        if (targetBuilder)
        {
            bool frameQualityOK = targetBuilder->getFrameQuality() != Vuforia::ImageTargetBuilder::FRAME_QUALITY_NONE;
            if (!frameQualityOK) {
                NSLog(@"Insufficient frame quality.");
            }
            return frameQualityOK;
        }
    }
    return false;
}


void
RefFreeFrame::
startBuild()
{
    Vuforia::TrackerManager& trackerManager = Vuforia::TrackerManager::getInstance();
    Vuforia::ObjectTracker* objectTracker = static_cast<Vuforia::ObjectTracker*>(trackerManager.getTracker(Vuforia::ObjectTracker::getClassType()));
    
    if (objectTracker)
    {
        Vuforia::ImageTargetBuilder* targetBuilder = objectTracker->getImageTargetBuilder();
        if (targetBuilder)
        {
            char name[128];
            do
            {
                snprintf(name, sizeof(name), "UserTarget-%d", targetBuilderCounter++);
                NSLog(@"TRYING %s", name);
            }
            while (!targetBuilder->build(name, 320.0));
            
            setCreating();
            
            if (displayLowQualityWarning) {
                //  Display an alertView if the quality is low
                Vuforia::ImageTargetBuilder::FRAME_QUALITY frameQuality = targetBuilder->getFrameQuality();
                if (frameQuality == Vuforia::ImageTargetBuilder::FRAME_QUALITY_LOW)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Low Quality Image"
                                                                            message:@"The image has very little detail, please try another."
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles: nil];
                        [alertView show];
                    });
                }
            }
        }
    }
}


bool RefFreeFrame::hasNewTrackableSource()
{
    return (trackableSource != NULL);
}

Vuforia::TrackableSource* RefFreeFrame::getNewTrackableSource()
{
    Vuforia::TrackableSource * result = trackableSource;
    trackableSource = NULL;
    return result;
}


void RefFreeFrame::restartTracker()
{
    Vuforia::TrackerManager& trackerManager = Vuforia::TrackerManager::getInstance();
    Vuforia::ObjectTracker* objectTracker = static_cast<Vuforia::ObjectTracker*>(trackerManager.getTracker(Vuforia::ObjectTracker::getClassType()));
    
    objectTracker->start();
}
