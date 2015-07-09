//
//  ButtonEvent.m
//  Open Spatial iOS SDK
//
//  Created by Neel Bhoopalam on 6/9/14.
//  Copyright (c) 2014 Nod Labs. All rights reserved.
//

#import "ButtonEvent.h"

@implementation ButtonEvent

-(void)setButtonEventType:(ButtonEventType)buttonEType
{
    self.eventNum = buttonEType;
}

-(ButtonEventType)getButtonEventType
{
    return self.eventNum;
}

@end