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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    self.HIDServ = [OpenSpatialBluetooth sharedBluetoothServ];
    self.HIDServ.delegate = self;
    self.subscribeToEvents.enabled = NO;
    [super viewDidLoad];
}

-(void)buttonEventFired: (ButtonEvent *) buttonEvent {
    NSLog(@"This is the value of button event type from %@", [buttonEvent.peripheral name]);
    switch([buttonEvent getButtonEventType]) {
        case TOUCH0_DOWN:
            NSLog(@"Touch 0 Down");
            break;
        case TOUCH0_UP:
            NSLog(@"Touch 0 Up");
            break;
        case TOUCH1_DOWN:
            NSLog(@"Touch 1 Down");
            break;
        case TOUCH1_UP:
            NSLog(@"Touch 1 Up");
            break;
        case TOUCH2_DOWN:
            NSLog(@"Touch 2 Down");
            break;
        case TOUCH2_UP:
            NSLog(@"Touch 2 Up");
            break;
        case TACTILE0_DOWN:
            NSLog(@"Tactile 0 Down");
            break;
        case TACTILE0_UP:
            NSLog(@"Tactile 0 Up");
            break;
        case TACTILE1_DOWN:
            NSLog(@"Tactile 1 Down");
            break;
        case TACTILE1_UP:
            NSLog(@"Tactile 1 Up");
            break;
    }
}

-(void)position2DEventFired:(Position2DEvent *)position2DEvent {
    NSLog(@"x value of the Position 2D event from %@: %hd", position2DEvent.peripheral.name, position2DEvent.xVal);
    NSLog(@"y value of the Position 2D event from %@: %hd", position2DEvent.peripheral.name, position2DEvent.yVal);
}

-(void) gestureEventFired: (GestureEvent *) gestureEvent {
    NSLog(@"This is the value of gesture event type from %@", [gestureEvent.peripheral name]);
    switch([gestureEvent getGestureEventType]) {
        case SWIPE_UP:
            NSLog(@"Gesture Up");
            break;
        case SWIPE_DOWN:
            NSLog(@"Gesture Down");
            break;
        case SWIPE_LEFT:
            NSLog(@"Gesture Left");
            break;
        case SWIPE_RIGHT:
            NSLog(@"Gesture Right");
            break;
        case SLIDER_LEFT:
            NSLog(@"Slider Left");
            break;
        case SLIDER_RIGHT:
            NSLog(@"Slider Right");
            break;
        case CCW:
            NSLog(@"Counter Clockwise");
            break;
        case CW:
            NSLog(@"Clockwise");
            break;
    }
}

-(void) pose6DEventFired:(Pose6DEvent *)pose6DEvent {
    NSLog(@"Pose 6D Event Fired from %@: xQuaternionVal:%f, yQuaternionVal:%f, zQuaternionVal:%f, rollQuaternionVal: %f, pitchQuaternionVal:%f, yawQuaternionVal:%f",
          pose6DEvent.peripheral.name, pose6DEvent.x, pose6DEvent.y, pose6DEvent.z,
          pose6DEvent.roll, pose6DEvent.pitch, pose6DEvent.yaw);
}

-(void) motion6DEventFired:(Motion6DEvent *)motion6DEvent {
    NSLog(@"Motion 6D Event Fired:: xAccel:%f, yAccel:%f, zAccel:%f, xGyro: %f, yGyro:%f, zGyro:%f",
          motion6DEvent.xAccel, motion6DEvent.yAccel,
          motion6DEvent.zAccel,
          motion6DEvent.xGyro, motion6DEvent.yGyro, motion6DEvent.zGyro);
}

- (void) didConnectToNod: (CBPeripheral*) peripheral {
    NSLog(@"connected %@",peripheral);
    self.subscribeToEvents.enabled = YES;
}

-(void)didDisconnectFromNod:(NSString *)peripheral {
    self.subscribeToEvents.enabled = NO;
}

-(void)openSpatialDataFired:(OpenSpatialData *)openSpatialData {
    switch (openSpatialData.dataType) {
        case OS_BUTTON_EVENT_TAG: {
            ButtonData* buttonData = (ButtonData *) openSpatialData;
            if(buttonData.buttonState == UP) {
                NSLog(@"Button Up");
            }
            if(buttonData.buttonState == DOWN) {
                NSLog(@"Button Down");
            }
            break;
        }
        case OS_RELATIVE_XY_TAG: {
            RelativeXYData* relativeXYData = (RelativeXYData *) openSpatialData;
//            NSLog(@"X:%d   Y:%d", relativeXYData.x, relativeXYData.y);
            break;
        }
            
        case OS_EULER_ANGLES_TAG: {
            EulerData* eulerData = (EulerData *) openSpatialData;
//            NSLog(@"Roll: %f", eulerData.roll);
            break;
        }
    }
}


- (IBAction)subscribeEvents:(UIButton *)sender {
    for(NSString* name in [self.HIDServ.connectedPeripherals allKeys]) {
        NSMutableArray* events = [[NSMutableArray alloc] initWithObjects:@(OS_BUTTON_EVENT_TAG), @(OS_EULER_ANGLES_TAG), nil];
        [self.HIDServ subscribeToEvents:name forEventTypes:events];
    }
}
- (IBAction)unsubscribe:(id)sender {
    for(NSString* name in [self.HIDServ.connectedPeripherals allKeys]) {
//        [self.HIDServ unsubscribeFromEvents:name forEventTypes:[[NSMutableArray alloc] initWithObjects:@(OS_BUTTON_EVENT_TAG), @(OS_EULER_ANGLES_TAG), nil]];
        [self.HIDServ unsubscribeFromAllEvents:name];
    }
}

@end