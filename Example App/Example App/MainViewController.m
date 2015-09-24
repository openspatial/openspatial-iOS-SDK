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
                NSLog(@"%d", buttonData.buttonID);
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
        [self.HIDServ subscribeToEvents:name forEventTypes:@[@(OS_BUTTON_EVENT_TAG), @(OS_EULER_ANGLES_TAG)]];
    }
}

- (IBAction)unsubscribe:(id)sender {
    for(NSString* name in [self.HIDServ.connectedPeripherals allKeys]) {
//        [self.HIDServ unsubscribeFromEvents:name forEventTypes:@[@(OS_BUTTON_EVENT_TAG), @(OS_EULER_ANGLES_TAG)]];
        [self.HIDServ unsubscribeFromAllEvents:name];
    }
}
@end