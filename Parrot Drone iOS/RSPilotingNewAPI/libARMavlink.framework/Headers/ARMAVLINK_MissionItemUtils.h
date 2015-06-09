/*
    Copyright (C) 2014 Parrot SA

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in
      the documentation and/or other materials provided with the 
      distribution.
    * Neither the name of Parrot nor the names
      of its contributors may be used to endorse or promote products
      derived from this software without specific prior written
      permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
    OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED 
    AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
    OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
    OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
    SUCH DAMAGE.
*/
/**
 * @file ARMAVLINK_MissionItemUtils.h
 * @brief Mavlink Mission item utils
 * @date 14/05/2014
 * @author djavan.bertrand@parrot.com
 */
#ifndef _ARMAVLINK_MISSIONITEMUTILS_h
#define _ARMAVLINK_MISSIONITEMUTILS_h

#include <libARMavlink/ARMAVLINK_Error.h>
#include <mavlink/common/mavlink.h>

/**
 * @brief Fill a mission item with the given params and the default params
 * @param[out] missionItem : pointer on the mission item to fill
 * @param[in] param1 : Radius in which the MISSION is accepted as reached, in meters
 * @param[in] param2 : Time that the MAV should stay inside the PARAM1 radius before advancing, in milliseconds
 * @param[in] param3 : For LOITER command MISSIONs: Orbit to circle around the MISSION, in meters. If positive the orbit direction should be clockwise, if negative the orbit direction should be counter-clockwise.
 * @param4[in] : For NAV and LOITER command MISSIONs: Yaw orientation in degrees, [0..360] 0 = NORTH
 * @param[in] latitude : the latitude of the mission item
 * @param[in] latitude : the latitude of the mission item
 * @param[in] longitude : the longitude of the mission item
 * @param[in] altitude : the altitude of the mission item
 * @param[in] command : the command of the mission item
 * @param[in] seq : the seq of the mission item
 * @param[in] frame : The coordinate system of the MISSION. see MAV_FRAME in mavlink_types.h
 * @param[in] current : false:0, true:1
 * @param[in] autocontinue : autocontinue to next wp
 * @return ARMAVLINK_OK if operation went well, the enum description of the error otherwise
 */
eARMAVLINK_ERROR ARMAVLINK_MissionItemUtils_CreateMavlinkMissionItemWithAllParams(mavlink_mission_item_t* missionItem, float param1, float param2, float param3, float param4, float latitude, float longitude, float altitude, int command, int seq,  int frame, int current, int autocontinue);

/**
 * @brief Fill a nav mission item with the given params and the default params
 * @param[out] missionItem : pointer on the mission item to fill
 * @param[in] latitude : the latitude of the mission item
 * @param[in] longitude : the longitude of the mission item
 * @param[in] altitude : the altitude of the mission item
 * @param[in] yaw : the yaw of the mission item
 * @return ARMAVLINK_OK if operation went well, the enum description of the error otherwise
 */
eARMAVLINK_ERROR ARMAVLINK_MissionItemUtils_CreateMavlinkNavWaypointMissionItem(mavlink_mission_item_t* missionItem, float latitude, float longitude, float altitude, float yaw);

/**
 * @brief Fill a land mission item with the given params and the default params
 * @param[out] missionItem : pointer on the mission item to fill
 * @param[in] latitude : the latitude of the mission item
 * @param[in] longitude : the longitude of the mission item
 * @param[in] altitude : the altitude of the mission item
 * @param[in] yaw : the yaw of the mission item
 * @return ARMAVLINK_OK if operation went well, the enum description of the error otherwise
 */
eARMAVLINK_ERROR ARMAVLINK_MissionItemUtils_CreateMavlinkLandMissionItem(mavlink_mission_item_t* missionItem, float latitude, float longitude, float altitude, float yaw);

/**
 * @brief Fill a takeoff mission item with the given params and the default params
 * @param[out] missionItem : pointer on the mission item to fill
 * @param[in] latitude : the latitude of the mission item
 * @param[in] longitude : the longitude of the mission item
 * @param[in] altitude : the altitude of the mission item
 * @param[in] yaw : the yaw of the mission item
 * @param[in] pitch : desired pitch
 * @return ARMAVLINK_OK if operation went well, the enum description of the error otherwise
 */
eARMAVLINK_ERROR ARMAVLINK_MissionItemUtils_CreateMavlinkTakeoffMissionItem(mavlink_mission_item_t* missionItem, float latitude, float longitude, float altitude, float yaw, float pitch);

/**
 * @brief Fill a change speed mission item with the given params and the default params
 * @param[out] missionItem : pointer on the mission item to fill
 * @param[in] groundSpeed : 1 if ground speed, 0 if airspeed
 * @param[in] speed : the speed of the mission item
 * @param[in] throttle : throttle in percent, -1 indicates no changes
 * @return ARMAVLINK_OK if operation went well, the enum description of the error otherwise
 */
eARMAVLINK_ERROR ARMAVLINK_MissionItemUtils_CreateMavlinkChangeSpeedMissionItem(mavlink_mission_item_t* missionItem, int groundSpeed, float speed, float throttle);

eARMAVLINK_ERROR ARMAVLINK_MissionItemUtils_CreateMavlinkVideoStartCapture(mavlink_mission_item_t* missionItem, int cameraId, float framesPerSeconds, float resolution);

eARMAVLINK_ERROR ARMAVLINK_MissionItemUtils_CreateMavlinkVideoStopCapture(mavlink_mission_item_t* missionItem);

eARMAVLINK_ERROR ARMAVLINK_MissionItemUtils_CreateMavlinkImageStartCapture(mavlink_mission_item_t* missionItem,float period,float imagesCount,float resolution);

eARMAVLINK_ERROR ARMAVLINK_MissionItemUtils_CreateMavlinkImageStopCapture(mavlink_mission_item_t* missionItem);

eARMAVLINK_ERROR ARMAVLINK_MissionItemUtils_CreateMavlinkCreatePanorama(mavlink_mission_item_t* missionItem,float horizontalAngle,float verticalAngle,float horizontalRotationSpeed,float verticalRotationSpeed);

eARMAVLINK_ERROR ARMAVLINK_MissionItemUtils_CreateMavlinkDelay(mavlink_mission_item_t* missionItem,float duration);
#endif
