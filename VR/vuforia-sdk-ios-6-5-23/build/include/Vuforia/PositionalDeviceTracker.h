/*==============================================================================
Copyright (c) 2015-2016 PTC Inc. All Rights Reserved.

Copyright (c) 2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of PTC Inc., registered in the United States and other
countries.

@file
PositionalDeviceTracker.h

@brief
Header file for PositionalDeviceTracker class.
==============================================================================*/
#ifndef _VUFORIA_POSITIONAL_DEVICE_TRACKER_H_
#define _VUFORIA_POSITIONAL_DEVICE_TRACKER_H_

#include <Vuforia/DeviceTracker.h>

namespace Vuforia
{

/// PositionalDeviceTracker class.
/**
 *  The PositionalDeviceTracker tracks a device in the world based 
 *  on the environment. It doesn't require target or anchor to estimate 
 *  the device's position. The position is returned as a 6DOF pose. 
 */
class VUFORIA_API PositionalDeviceTracker : public DeviceTracker
{
public:
    /// Returns the Tracker class' type
    static Type getClassType();
};


} // namespace Vuforia

#endif //_VUFORIA_POSITIONAL_DEVICE_TRACKER_H_
