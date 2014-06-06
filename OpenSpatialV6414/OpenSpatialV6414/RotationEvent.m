//
//  RotationEvent.m
//  Open Spatial SDK
//
//  Created by Neel Bhoopalam on 5/29/14.
//  Copyright (c) 2014 Neel Bhoopalam. All rights reserved.
//

#import "RotationEvent.h"

@implementation RotationEvent

-(void)setQuaternion:(CMQuaternion)tempQuat
{
    self.quat = tempQuat;
}

-(CMQuaternion)getQuaternion
{
    return self.quat;
}

@end
