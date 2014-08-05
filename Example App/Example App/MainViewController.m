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
    
    self.xPointerlbl.textColor = [UIColor clearColor];
    self.yPointerlbl.textColor = [UIColor clearColor];
    self.xPose6Dlbl.textColor = [UIColor clearColor];
    self.yPose6Dlbl.textColor = [UIColor clearColor];
    self.zPose6Dlbl.textColor = [UIColor clearColor];
    self.rollPose6Dlbl.textColor = [UIColor clearColor];
    self.pitchPose6Dlbl.textColor = [UIColor clearColor];
    self.yawPose6Dlbl.textColor = [UIColor clearColor];
    self.buttonValue.textColor = [UIColor clearColor];
    self.gestureValue.textColor = [UIColor clearColor];
    self.xPointerValue.textColor = [UIColor clearColor];
    self.yPointerValue.textColor = [UIColor clearColor];
    self.pose6DxValue.textColor = [UIColor clearColor];
    self.pose6DzValue.textColor = [UIColor clearColor];
    self.pose6DyValue.textColor = [UIColor clearColor];
    self.pose6DrollValue.textColor = [UIColor clearColor];
    self.pose6DpitchValue.textColor = [UIColor clearColor];
    self.pose6DyawValue.textColor = [UIColor clearColor];
    
    [super viewDidLoad];
}

-(ButtonEvent *)buttonEventFired: (ButtonEvent *) buttonEvent
{
    NSLog(@"This is the value of button event type from %@", [buttonEvent.peripheral name]);
    switch([buttonEvent getButtonEventType])
    {
        case TOUCH0_DOWN:
            NSLog(@"Touch 0 Down");
            self.buttonValue.text = @"Touch 0 Down";
            break;
        case TOUCH0_UP:
            NSLog(@"Touch 0 Up");
            self.buttonValue.text = @"Touch 0 Up";
            break;
        case TOUCH1_DOWN:
            NSLog(@"Touch 1 Down");
            self.buttonValue.text = @"Touch 1 Down";
            break;
        case TOUCH1_UP:
            NSLog(@"Touch 1 Up");
            self.buttonValue.text = @"Touch 1 Up";
            break;
        case TOUCH2_DOWN:
            NSLog(@"Touch 2 Down");
            self.buttonValue.text = @"Touch 2 Down";
            break;
        case TOUCH2_UP:
            NSLog(@"Touch 2 Up");
            self.buttonValue.text = @"Touch 2 Up";
            break;
        case TACTILE0_DOWN:
            NSLog(@"Tactile 0 Down");
            self.buttonValue.text = @"Tactile 0 Down";
            break;
        case TACTILE0_UP:
            NSLog(@"Tactile 0 Up");
            self.buttonValue.text = @"Tactile 0 Up";
            break;
        case TACTILE1_DOWN:
            NSLog(@"Tactile 1 Down");
            self.buttonValue.text = @"Tactile 1 Down";
            break;
        case TACTILE1_UP:
            NSLog(@"Tactile 1 Up");
            self.gestureValue.text = @"Tactile 1 Up";
            break;
    }
    return nil;
}

-(PointerEvent *)pointerEventFired: (PointerEvent *) pointerEvent
{
    NSLog(@"This is the x value of the pointer event from %@", [pointerEvent.peripheral name]);
    NSLog(@"%hd", [pointerEvent getXValue]);
    
    NSLog(@"This is the y value of the pointer event from %@", [pointerEvent.peripheral name]);
    NSLog(@"%hd", [pointerEvent getYValue]);
    
    NSString *xValString = [NSString stringWithFormat:@"%d", [pointerEvent getXValue]];
    NSString *yValString = [NSString stringWithFormat:@"%d", [pointerEvent getYValue]];

    self.xPointerValue.text = xValString;
    self.yPointerValue.text = yValString;
    
    return nil;
}

-(GestureEvent *)gestureEventFired: (GestureEvent *) gestureEvent
{
    NSLog(@"This is the value of gesture event type from %@", [gestureEvent.peripheral name]);
    switch([gestureEvent getGestureEventType])
    {
        case SWIPE_UP:
            NSLog(@"Gesture Up");
            self.gestureValue.text = @"Gesture Up";
            break;
        case SWIPE_DOWN:
            NSLog(@"Gesture Down");
            self.gestureValue.text = @"Gesture Down";
            break;
        case SWIPE_LEFT:
            NSLog(@"Gesture Left");
            self.gestureValue.text = @"Gesture Left";
            break;
        case SWIPE_RIGHT:
            NSLog(@"Gesture Right");
            self.gestureValue.text = @"Gesture Right";
            break;
        case SLIDER_LEFT:
            NSLog(@"Slider Left");
            self.gestureValue.text = @"Slider Left";
            break;
        case SLIDER_RIGHT:
            NSLog(@"Slider Right");
            self.gestureValue.text = @"Slider Right";
            break;
        case CCW:
            NSLog(@"Counter Clockwise");
            self.gestureValue.text = @"Counter Clockwise";
            break;
        case CW:
            NSLog(@"Clockwise");
            self.gestureValue.text = @"Clockwise";
            break;
    }
    
    return nil;
}

-(RotationEvent *)rotationEventFired:(RotationEvent *)rotationEvent
{
    NSLog(@"This is the x value of the quaternion from %@", [rotationEvent.peripheral name]);
    NSLog(@"%f", rotationEvent.x);
    NSString *xValStringPose6D = [NSString stringWithFormat:@"%f", rotationEvent.x];
    self.pose6DxValue.text = xValStringPose6D;
    
    NSLog(@"This is the y value of the quaternion from %@", [rotationEvent.peripheral name]);
    NSLog(@"%f", rotationEvent.y);
    NSString *yValStringPose6D = [NSString stringWithFormat:@"%f", rotationEvent.y];
    self.pose6DyValue.text = yValStringPose6D;

    NSLog(@"This is the z value of the quaternion from %@", [rotationEvent.peripheral name]);
    NSLog(@"%f", rotationEvent.z);
    NSString *zValStringPose6D = [NSString stringWithFormat:@"%f", rotationEvent.z];
    self.pose6DzValue.text = zValStringPose6D;

    NSLog(@"This is the roll value of the quaternion from %@", [rotationEvent.peripheral name]);
    NSLog(@"%f", rotationEvent.roll);
    NSString *rollValStringPose6D = [NSString stringWithFormat:@"%f", rotationEvent.roll];
    self.pose6DrollValue.text = rollValStringPose6D;

    NSLog(@"This is the pitch value of the quaternion from %@", [rotationEvent.peripheral name]);
    NSLog(@"%f", rotationEvent.pitch);
    NSString *pitchValStringPose6D = [NSString stringWithFormat:@"%f", rotationEvent.pitch];
    self.pose6DpitchValue.text = pitchValStringPose6D;

    NSLog(@"This is the yaw value of the quaternion from %@", [rotationEvent.peripheral name]);
    NSLog(@"%f", rotationEvent.yaw);
    NSString *yawValStringPose6D = [NSString stringWithFormat:@"%f", rotationEvent.yaw];
    self.pose6DyawValue.text = yawValStringPose6D;
    
    return nil;
}

- (void) didConnectToNod: (CBPeripheral*) peripheral
{
    self.lastNodPeripheral = peripheral;
    [self subscribeEvents];
}

- (IBAction)buttonEvents:(UIButton *)sender {
    if(self.buttonValue.textColor == [UIColor clearColor])
    {
            self.buttonValue.textColor = [UIColor blackColor];
    }
    else
    {
            self.buttonValue.textColor = [UIColor clearColor];
    }
}

- (IBAction)gestureEvents:(UIButton *)sender {
    if(self.gestureValue.textColor == [UIColor clearColor])
    {
        self.gestureValue.textColor = [UIColor blackColor];
    }
    else
    {
        self.gestureValue.textColor = [UIColor clearColor];
    }
}

- (IBAction)pointerEvents:(UIButton *)sender {
    if(self.xPointerValue.textColor == [UIColor clearColor])
    {
        self.xPointerValue.textColor = [UIColor blackColor];
        self.yPointerValue.textColor = [UIColor blackColor];
        self.xPointerlbl.textColor = [UIColor blackColor];
        self.yPointerlbl.textColor = [UIColor blackColor];
    }
    else
    {
        self.xPointerValue.textColor = [UIColor clearColor];
        self.yPointerValue.textColor = [UIColor clearColor];
        self.xPointerlbl.textColor = [UIColor clearColor];
        self.yPointerlbl.textColor = [UIColor clearColor];
    }
}

- (IBAction)pose6DEvents:(UIButton *)sender {
    if(self.pose6DxValue.textColor == [UIColor clearColor])
    {
        self.pose6DxValue.textColor = [UIColor blackColor];
        self.pose6DzValue.textColor = [UIColor blackColor];
        self.pose6DyValue.textColor = [UIColor blackColor];
        self.pose6DrollValue.textColor = [UIColor blackColor];
        self.pose6DpitchValue.textColor = [UIColor blackColor];
        self.pose6DyawValue.textColor = [UIColor blackColor];
    
        self.xPose6Dlbl.textColor = [UIColor blackColor];
        self.yPose6Dlbl.textColor = [UIColor blackColor];
        self.zPose6Dlbl.textColor = [UIColor blackColor];
        self.rollPose6Dlbl.textColor = [UIColor blackColor];
        self.pitchPose6Dlbl.textColor = [UIColor blackColor];
        self.yawPose6Dlbl.textColor = [UIColor blackColor];
    }
    else
    {
        self.pose6DxValue.textColor = [UIColor clearColor];
        self.pose6DzValue.textColor = [UIColor clearColor];
        self.pose6DyValue.textColor = [UIColor clearColor];
        self.pose6DrollValue.textColor = [UIColor clearColor];
        self.pose6DpitchValue.textColor = [UIColor clearColor];
        self.pose6DyawValue.textColor = [UIColor clearColor];
        
        self.xPose6Dlbl.textColor = [UIColor clearColor];
        self.yPose6Dlbl.textColor = [UIColor clearColor];
        self.zPose6Dlbl.textColor = [UIColor clearColor];
        self.rollPose6Dlbl.textColor = [UIColor clearColor];
        self.pitchPose6Dlbl.textColor = [UIColor clearColor];
        self.yawPose6Dlbl.textColor = [UIColor clearColor];
    }
}

- (void)subscribeEvents
{
    [self.HIDServ subscribeToButtonEvents:self.lastNodPeripheral.name];
    [self.HIDServ subscribeToGestureEvents:self.lastNodPeripheral.name];
    [self.HIDServ subscribeToPointerEvents:self.lastNodPeripheral.name];
    [self.HIDServ subscribeToRotationEvents:self.lastNodPeripheral.name];
}

@end
