//
//  ButtonEvent.m
//  Open Spatial SDK
//
//  Created by Neel Bhoopalam on 5/29/14.
//  Copyright (c) 2014 Neel Bhoopalam. All rights reserved.
//

#import "ButtonEvent.h"

@implementation ButtonEvent

-(void)setButtonEventType:(ButtonEventType)buttonEType
{
    self.myButtonEventNum = buttonEType;
}

-(ButtonEventType)getButtonEventType
{
    return self.myButtonEventNum;
}

@end