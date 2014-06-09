//
//  MainViewController.m
//  Example App
//
//  Created by Neel Bhoopalam on 6/9/14.
//  Copyright (c) 2014 Nod Labs. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    self.HIDServ = [OpenSpatialBluetooth sharedBluetoothServ];
    self.HIDServ.delegate = self;
    
    [super viewDidLoad];
}

-(ButtonEvent *)buttonEventFired: (ButtonEvent *) buttonEvent
{
    NSLog(@"This is the value of button event type from %@", [buttonEvent.peripheral name]);
    NSLog(@"%u", [buttonEvent getButtonEventType]);
    
    return nil;
}

-(PointerEvent *)pointerEventFired: (PointerEvent *) pointerEvent
{
    
    NSLog(@"This is the x value of the pointer event from %@", [pointerEvent.peripheral name]);
    NSLog(@"%hd", [pointerEvent getXValue]);
    
    
    NSLog(@"This is the y value of the pointer event from %@", [pointerEvent.peripheral name]);
    NSLog(@"%hd", [pointerEvent getYValue]);
    
    return nil;
}

-(GestureEvent *)gestureEventFired: (GestureEvent *) gestureEvent
{
    NSLog(@"This is the value of gesture event type from %@", [gestureEvent.peripheral name]);
    NSLog(@"%d", [gestureEvent getGestureEventType]);
    
    return nil;
}

-(RotationEvent *)rotationEventFired:(RotationEvent *)rotationEvent
{
    NSLog(@"This is the x value of the quaternion from %@", [rotationEvent.peripheral name]);
    NSLog(@"%f", [rotationEvent getQuaternion].x);
    
    NSLog(@"This is the y value of the quaternion from %@", [rotationEvent.peripheral name]);
    NSLog(@"%f", [rotationEvent getQuaternion].y);
    
    return nil;
}

- (void) didConnectToNod: (CBPeripheral*) peripheral
{
    self.lastNodPeripheral = peripheral;
}

- (IBAction)subscribeEvents:(UIButton *)sender
{
    [self.HIDServ subscribeToButtonEvents:self.lastNodPeripheral.name];
    [self.HIDServ subscribeToGestureEvents:self.lastNodPeripheral.name];
    [self.HIDServ subscribeToPointerEvents:self.lastNodPeripheral.name];
    [self.HIDServ subscribeToRotationEvents:self.lastNodPeripheral.name];
}

@end
