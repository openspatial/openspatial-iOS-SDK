//
//  GestureEvent.m
//  Open Spatial iOS SDK
//
//  Created by Neel Bhoopalam on 6/9/14.
//  Copyright (c) 2014 Nod Labs. All rights reserved.
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
