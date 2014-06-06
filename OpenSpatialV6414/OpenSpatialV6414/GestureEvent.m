//
//  GestureEvent.m
//  Open Spatial SDK
//
//  Created by Neel Bhoopalam on 5/29/14.
//  Copyright (c) 2014 Neel Bhoopalam. All rights reserved.
//

#import "GestureEvent.h"

@implementation GestureEvent

-(void)setGestureEventType:(GestureEventType)gestureEType
{
    self.myGestureEventNum = gestureEType;
}

-(GestureEventType)getGestureEventType
{
    return self.myGestureEventNum;
}

@end
