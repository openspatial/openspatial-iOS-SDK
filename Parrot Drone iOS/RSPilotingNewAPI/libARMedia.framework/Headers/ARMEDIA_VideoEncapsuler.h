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
/*
 * ARMEDIA_VideoEncapsuler.h
 *
 * Created by f.dhaeyer on 29/03/14
 * Copyright 2014 Parrot SA. All rights reserved.
 *
 */
#ifndef _ARMEDAI_VIDEOENCAPSULER_H_
#define _ARMEDAI_VIDEOENCAPSULER_H_
#include <stdio.h>
#include <dirent.h>
#include <libARDiscovery/ARDiscovery.h>

#define ARMEDIA_ENCAPSULER_VIDEO_PATH_SIZE      (256)
#define ARMEDIA_ENCAPSULER_FRAMES_COUNT_LIMIT   (131072)

#define COUNT_WAITING_FOR_IFRAME_AS_AN_ERROR    (0)

#define ARMEDIA_ENCAPSULER_VERSION_NUMBER       (4)
#define ARMEDIA_ENCAPSULER_INFO_PATTERN         "%u:%c:%u|"
#define ARMEDIA_ENCAPSULER_NUM_MATCH_PATTERN    (3)

// File extension for informations files (frame sizes / types)
#define INFOFILE_EXT ".infovid"

#if COUNT_WAITING_FOR_IFRAME_AS_AN_ERROR
#define ARMEDIA_ENCAPSULER_FAILED(errCode) ((errCode) != ARMEDIA_OK)
#define ARMEDIA_ENCAPSULER_SUCCEEDED(errCode) ((errCode) == ARMEDIA_OK)
#else
static inline int ARMEDIA_ENCAPSULER_FAILED (eARMEDIA_ERROR error)
{
    if (ARMEDIA_OK == error ||
        ARMEDIA_ERROR_ENCAPSULER_WAITING_FOR_IFRAME == error)
    {
        return 0;
    }
    return 1;
}
static inline int ARMEDIA_ENCAPSULER_SUCCEEDED (eARMEDIA_ERROR error)
{
    if (ARMEDIA_OK == error ||
        ARMEDIA_ERROR_ENCAPSULER_WAITING_FOR_IFRAME == error)
    {
        return 1;
    }
    return 0;
}
#endif // COUNT_WAITING_FOR_IFRAME_AS_AN_ERROR

typedef enum {
	CODEC_UNKNNOWN = 0,
	CODEC_VLIB,
	CODEC_P264,
	CODEC_MPEG4_VISUAL,
	CODEC_MPEG4_AVC,
    CODEC_MOTION_JPEG
}eARMEDIA_ENCAPSULER_CODEC;

typedef enum
{
	ARMEDIA_ENCAPSULER_FRAME_TYPE_UNKNNOWN = 0,
	ARMEDIA_ENCAPSULER_FRAME_TYPE_I_FRAME,  /* contains SPS & PPS headers */
	ARMEDIA_ENCAPSULER_FRAME_TYPE_P_FRAME,
    ARMEDIA_ENCAPSULER_FRAME_TYPE_JPEG,     /* only type for mjpeg */
	ARMEDIA_ENCAPSULER_FRAME_TYPE_MAX
} eARMEDIA_ENCAPSULER_FRAME_TYPE;

typedef struct ARMEDIA_VideoEncapsuler_t ARMEDIA_VideoEncapsuler_t;

typedef struct {
    uint8_t  video_codec;
    uint32_t frame_size;               /* Amount of data following this PaVE */
    uint32_t frame_number;             /* frame position inside the current stream */
    uint16_t video_width;
    uint16_t video_height;
    uint64_t timestamp;                /* in microseconds */
    uint8_t  frame_type;               /* I-frame, P-frame, JPEG-frame */
    uint8_t* frame;
} ARMEDIA_Frame_Header_t;


/**
 * @brief Callback called when remove_all fixes a media file
 * @param path path of the fixed media
 * @param unused compatibility with academy callbacks
 */
typedef void (*ARMEDIA_VideoEncapsuler_Callback)(const char *path, int unused);

#ifdef AC_VIDEOENC
/**
 * @brief Create a new ARMedia encapsuler
 * @warning This function allocate memory
 * @post ARMEDIA_VideoEncapsuler_Delete() must be called to delete the codecs manager and free the memory allocated.
 * @param[out] error pointer on the error output.
 * @return Pointer on the new Manager
 * @see ARMEDIA_VideoEncapsuler_Delete()
 */
ARMEDIA_VideoEncapsuler_t* ARMEDIA_VideoEncapsuler_New(const char *videoPath, int fps, char* uuid, char* runDate, eARDISCOVERY_PRODUCT product, eARMEDIA_ERROR *error);
#endif

/**
 * @brief Delete the Manager
 * @warning This function free memory
 * @param manager address of the pointer on the Manager
 * @see ARMEDIA_VideoEncapsuler_New()
 */
void ARMEDIA_VideoEncapsuler_Delete(ARMEDIA_VideoEncapsuler_t **encapsuler);

/**
 * Add a slice to an encapsulated video
 * The actual writing of the video will start on the first given I-Frame slice. (after that, each frame will be written)
 * The first I-Frame slice will be used to get the video codec, height and width of the video
 * @brief Add a new slice to a video
 * @param encapsuler ARMedia video encapsuler created by ARMEDIA_VideoEncapsuler_new()
 * @param slice Pointer to slice data
 * @return Possible return values are in eARMEDIA_ERROR
 */
eARMEDIA_ERROR ARMEDIA_VideoEncapsuler_AddSlice (ARMEDIA_VideoEncapsuler_t *encapsuler, ARMEDIA_Frame_Header_t *frameHeader);

/**
 * Compute, write and close the video
 * This can take some time to complete
 * @param encapsuler ARMedia video encapsuler created by ARMEDIA_VideoEncapsuler_new()
 */
eARMEDIA_ERROR ARMEDIA_VideoEncapsuler_Finish (ARMEDIA_VideoEncapsuler_t **encapsuler);

/**
 * Abort a video recording
 * This will delete all created files
 * @param video pointer to your video_encapsuler pointer (will be set to NULL by call)
 */
eARMEDIA_ERROR ARMEDIA_VideoEncapsuler_Cleanup (ARMEDIA_VideoEncapsuler_t **encapsuler);

/**
 * Set the current GPS position for further recordings
 * @param latitude current latitude
 * @param longitude current longitude
 * @param altitude current altitude
 */
void ARMEDIA_VideoEncapsuler_SetGPSInfos (ARMEDIA_VideoEncapsuler_t* encapsuler, double latitude, double longitude, double altitude);

/**
 * Try fo fix an MP4 infovid file.
 * @param infoFilePath Full path to the .infovid file.
 * @return 1 on success, 0 on failure
 */
int  ARMEDIA_VideoEncapsuler_TryFixInfoFile (const char *infoFilePath);

/**
 * Add atom in file.
 * @param FILE video file descriptor. The file descriptor MUST BE OPENED WITH APPEND OPTION
 * @param eARDISCOVERY_PRODUCT for the product to add in Atom
 * @param const char for the video date to add in Atom
 * @return 1 on success, 0 on failure
 */
int ARMEDIA_VideoEncapsuler_addPVATAtom (FILE *videoFile, eARDISCOVERY_PRODUCT product, const char *videoDate);

/**
 * Change run_date and media_date atom in file.
 * @param FILE video file descriptor. The file descriptor MUST BE OPENED WITH READING AND WRITING OPTION
 * @param const char for the date set on run_date and media_date in Atom
 * @return 1 on success, 0 on failure
 */
int ARMEDIA_VideoEncapsuler_changePVATAtomDate (FILE *videoFile, const char *videoDate);


#endif // _ARDRONE_VIDEO_ENCAPSULER_H_
