//
//  OpenSpatialEvent.h
//  Open Spatial SDK
//
//  Created by Neel Bhoopalam on 5/29/14.
//  Copyright (c) 2014 Neel Bhoopalam. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum OpenSpatialEventType {
    EVENT_3D_ROTATION,
    EVENT_3D_TRANSLATION,
    EVENT_BUTTON,
    EVENT_GESTURE,
    EVENT_POINTER
} OpenSpatialEventType;

@interface OpenSpatialEvent : NSObject
{
    NSInteger timestamp;
}

@property (nonatomic, assign) OpenSpatialEventType myOpenSpatialEventNum;

-(id)init;

-(void)setOpenSpatialEventType:(OpenSpatialEventType)openSpatialEType;

-(OpenSpatialEventType)getOpenSpatialEventType;

@end